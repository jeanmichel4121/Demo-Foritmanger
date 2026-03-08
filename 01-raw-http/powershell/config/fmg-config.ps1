<#
.SYNOPSIS
    Loads FortiManager configuration from .env file

.DESCRIPTION
    This script loads environment variables from the .env file
    located at project root. These variables are used by all
    other scripts in the PowerShell section.

.EXAMPLE
    . .\config\fmg-config.ps1
    Write-Host "Connecting to $env:FMG_HOST"
#>

# Path to .env file (at project root)
$envFile = Join-Path $PSScriptRoot "..\..\..\.env"

# Fallback: look in current or parent folder
if (-not (Test-Path $envFile)) {
    $envFile = Join-Path $PSScriptRoot "..\..\.env"
}
if (-not (Test-Path $envFile)) {
    $envFile = ".\.env"
}

if (Test-Path $envFile) {
    Write-Verbose "Loading configuration from $envFile"

    Get-Content $envFile | ForEach-Object {
        # Ignore empty lines and comments
        if ($_ -match '^([^#][^=]+)=(.*)$') {
            $name = $matches[1].Trim()
            $value = $matches[2].Trim()

            # Remove quotes if present
            $value = $value -replace '^["'']|["'']$', ''

            # Set environment variable
            [Environment]::SetEnvironmentVariable($name, $value, "Process")
        }
    }

    Write-Verbose "Configuration loaded:"
    Write-Verbose "  FMG_HOST: $env:FMG_HOST"
    Write-Verbose "  FMG_ADOM: $env:FMG_ADOM"
} else {
    Write-Warning @"
.env file not found!
Create .env file at project root with:

FMG_HOST=192.168.1.100
FMG_PORT=443
FMG_USERNAME=api_admin
FMG_PASSWORD=your_password
FMG_ADOM=root
FMG_VERIFY_SSL=false
"@
}

# Convenience variables
$script:FMG_BASE_URL = "https://$($env:FMG_HOST):$($env:FMG_PORT)/jsonrpc"
$script:FMG_ADOM = if ($env:FMG_ADOM) { $env:FMG_ADOM } else { "root" }

# Disable SSL verification if requested (lab only!)
if ($env:FMG_VERIFY_SSL -eq "false") {
    if ($PSVersionTable.PSVersion.Major -ge 7) {
        # PowerShell 7+
        $PSDefaultParameterValues['Invoke-RestMethod:SkipCertificateCheck'] = $true
        $PSDefaultParameterValues['Invoke-WebRequest:SkipCertificateCheck'] = $true
    } else {
        # Windows PowerShell 5.1
        Add-Type @"
using System.Net;
using System.Security.Cryptography.X509Certificates;
public class TrustAllCertsPolicy : ICertificatePolicy {
    public bool CheckValidationResult(
        ServicePoint srvPoint, X509Certificate certificate,
        WebRequest request, int certificateProblem) {
        return true;
    }
}
"@
        [System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
    }
}
