<#
.SYNOPSIS
    Install a policy package to one or more FortiGate devices

.DESCRIPTION
    This script initiates the installation of a policy package from FortiManager
    to target FortiGate devices. The installation runs asynchronously.

.PARAMETER Package
    Policy package name

.PARAMETER Device
    Target device name (FortiGate)

.PARAMETER Scope
    Installation scope: all (all devices in package) or device (specific device)

.PARAMETER Preview
    Preview mode: shows changes without applying them

.PARAMETER Session
    Session token (optional if using API Key)

.EXAMPLE
    # Install to a specific device
    .\install-package.ps1 -Package "default" -Device "FGT-01"

.EXAMPLE
    # Preview changes
    .\install-package.ps1 -Package "default" -Device "FGT-01" -Preview

.EXAMPLE
    # Install to all devices in the package
    .\install-package.ps1 -Package "default" -Scope all
#>

param(
    [Parameter(Mandatory)]
    [string]$Package,

    [Parameter()]
    [string]$Device,

    [Parameter()]
    [ValidateSet("all", "device")]
    [string]$Scope = "device",

    [Parameter()]
    [switch]$Preview,

    [Parameter()]
    [string]$Session
)

# Load tools
. "$PSScriptRoot\..\config\fmg-config.ps1"
. "$PSScriptRoot\..\utils\Invoke-FMGRequest.ps1"

# Build installation data
$data = @{
    adom = $script:FMG_ADOM
    pkg = $Package
}

if ($Scope -eq "device" -and $Device) {
    $data.scope = @(
        @{
            name = $Device
            vdom = "root"
        }
    )
}

# URL based on mode
if ($Preview) {
    $url = "/securityconsole/install/preview"
    Write-Host "`nGenerating installation preview..." -ForegroundColor Cyan
} else {
    $url = "/securityconsole/install/package"
    Write-Host "`nStarting installation..." -ForegroundColor Cyan
}

Write-Host "  Package: $Package"
Write-Host "  ADOM:    $($script:FMG_ADOM)"
if ($Device) { Write-Host "  Device:  $Device" }

# Send request
$result = Invoke-FMGRequest -Method "exec" -Url $url -Data $data -Session $Session

if ($result.success) {
    if ($Preview) {
        Write-Host "`n[OK] Preview generated. Check FortiManager for details." -ForegroundColor Green
    } else {
        Write-Host "`n[OK] Installation started!" -ForegroundColor Green
        Write-Host "Installation is running in the background." -ForegroundColor DarkGray
        Write-Host "Check FortiManager to monitor progress."

        # If a task ID is returned
        if ($result.data.task) {
            Write-Host "`nTask ID: $($result.data.task)" -ForegroundColor Cyan
        }
    }
} else {
    Write-Host "`n[ERROR] $($result.message)" -ForegroundColor Red

    switch ($result.code) {
        -2 { Write-Host "Package or device not found." -ForegroundColor Yellow }
        -6 { Write-Host "Permission denied." -ForegroundColor Yellow }
    }
}

return $result
