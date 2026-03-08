<#
.SYNOPSIS
    Test connection with API Key (Bearer Token)

.DESCRIPTION
    This script tests connection to FortiManager using an API Key.
    With Bearer token, no explicit login/logout is needed.

.EXAMPLE
    .\login-bearer.ps1
    # Returns FMG info if connection succeeds

.NOTES
    Requires FMG_API_KEY in .env
    Available since FortiManager 7.2.2+
#>

# Load configuration
. "$PSScriptRoot\..\config\fmg-config.ps1"

# Check API Key
if (-not $env:FMG_API_KEY) {
    Write-Warning @"
FMG_API_KEY is not defined in .env

To use Bearer token:
1. On FortiManager: System Settings > Admin > Administrators
2. Create admin with type 'API User'
3. Generate an API Key
4. Add FMG_API_KEY=<your_key> to .env
"@
    return $null
}

# Build a test request (read system status)
$payload = @{
    id = 1
    method = "get"
    params = @(
        @{
            url = "/sys/status"
        }
    )
}

$jsonPayload = $payload | ConvertTo-Json -Depth 10

# Headers with Bearer token
$headers = @{
    "Content-Type" = "application/json"
    "Authorization" = "Bearer $($env:FMG_API_KEY)"
}

# URL
$uri = "https://$($env:FMG_HOST):$($env:FMG_PORT)/jsonrpc"

Write-Host "Testing Bearer connection to $env:FMG_HOST..." -ForegroundColor Cyan

try {
    $response = Invoke-RestMethod -Uri $uri -Method Post -Body $jsonPayload -Headers $headers

    # Check status
    $status = $response.result[0].status
    if ($status.code -ne 0) {
        Write-Error "Connection failed: $($status.message)"
        Write-Host "Verify that API Key is valid and admin has required permissions."
        return $null
    }

    # Show FMG info
    $data = $response.result[0].data

    Write-Host "`nBearer connection successful!" -ForegroundColor Green
    Write-Host "`nFortiManager Info:" -ForegroundColor Cyan
    Write-Host "  Hostname: $($data.Hostname)"
    Write-Host "  Version:  $($data.Version)"
    Write-Host "  Serial:   $($data.Serial)"
    Write-Host "  Admin:    $($data.Admin)"

    # With Bearer token, no session to return
    Write-Host "`nNo session required with Bearer token." -ForegroundColor DarkGray
    Write-Host "Use scripts directly without login/logout."

    return $true

} catch {
    Write-Error "Connection error: $_"
    return $null
}
