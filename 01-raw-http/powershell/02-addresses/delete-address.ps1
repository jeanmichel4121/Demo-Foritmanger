<#
.SYNOPSIS
    Deletes an IPv4 address from FortiManager

.DESCRIPTION
    This script deletes a firewall address object.
    Warning: deletion fails if address is used in a policy.

.PARAMETER Name
    Name of address to delete

.PARAMETER Force
    Delete without confirmation (default: asks for confirmation)

.PARAMETER Session
    Session token (optional if API Key)

.EXAMPLE
    .\delete-address.ps1 -Name "NET_SERVERS"

.EXAMPLE
    .\delete-address.ps1 -Name "NET_SERVERS" -Force
#>

param(
    [Parameter(Mandatory)]
    [string]$Name,

    [Parameter()]
    [switch]$Force,

    [Parameter()]
    [string]$Session
)

# Load tools
. "$PSScriptRoot\..\config\fmg-config.ps1"
. "$PSScriptRoot\..\utils\Invoke-FMGRequest.ps1"

# URL for specific object
$url = "/pm/config/adom/$($script:FMG_ADOM)/obj/firewall/address/$Name"

# Confirmation unless -Force
if (-not $Force) {
    Write-Host "`nDelete address '$Name'" -ForegroundColor Yellow
    $confirm = Read-Host "Confirm? (y/N)"

    if ($confirm -notmatch '^[yY]') {
        Write-Host "Operation cancelled." -ForegroundColor DarkGray
        return
    }
}

Write-Host "`nDeleting address '$Name'..." -ForegroundColor Cyan

# Send request
$result = Invoke-FMGRequest -Method "delete" -Url $url -Session $Session

if ($result.success) {
    Write-Host "`n[OK] Address '$Name' deleted!" -ForegroundColor Green
} else {
    Write-Host "`n[ERROR] Code $($result.code): $($result.message)" -ForegroundColor Red

    switch ($result.code) {
        -2 { Write-Host "Address '$Name' does not exist." -ForegroundColor Yellow }
        -10 {
            Write-Host "Address is used in one or more policies." -ForegroundColor Yellow
            Write-Host "Remove references to this address first."
        }
    }
}

return $result
