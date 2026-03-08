<#
.SYNOPSIS
    Modifies an existing IPv4 address

.DESCRIPTION
    This script partially updates a firewall address object.
    Uses 'update' method which only modifies specified fields.

.PARAMETER Name
    Name of address to modify

.PARAMETER NewSubnet
    New subnet (optional)

.PARAMETER Comment
    New comment (optional)

.PARAMETER NewName
    New name to rename address (optional)

.PARAMETER Session
    Session token (optional if API Key)

.EXAMPLE
    .\update-address.ps1 -Name "NET_SERVERS" -Comment "New comment"

.EXAMPLE
    .\update-address.ps1 -Name "NET_SERVERS" -NewSubnet "10.10.20.0/24"

.EXAMPLE
    .\update-address.ps1 -Name "OLD_NAME" -NewName "NEW_NAME"
#>

param(
    [Parameter(Mandatory)]
    [string]$Name,

    [Parameter()]
    [string]$NewSubnet,

    [Parameter()]
    [string]$Comment,

    [Parameter()]
    [string]$NewName,

    [Parameter()]
    [string]$Session
)

# Load tools
. "$PSScriptRoot\..\config\fmg-config.ps1"
. "$PSScriptRoot\..\utils\Invoke-FMGRequest.ps1"

# Convert CIDR to IP MASK format if needed
function Convert-CidrToMask {
    param([string]$Cidr)

    if ($Cidr -match '^(\d+\.\d+\.\d+\.\d+)/(\d+)$') {
        $ip = $matches[1]
        $bits = [int]$matches[2]

        $mask = [uint32]::MaxValue -shl (32 - $bits)
        $maskBytes = [BitConverter]::GetBytes($mask)
        [Array]::Reverse($maskBytes)
        $maskStr = ($maskBytes | ForEach-Object { $_ }) -join '.'

        return "$ip $maskStr"
    }
    return $Cidr
}

# URL for specific object
$url = "/pm/config/adom/$($script:FMG_ADOM)/obj/firewall/address/$Name"

# Build update data
$data = @{}

if ($NewSubnet) {
    $data.subnet = Convert-CidrToMask -Cidr $NewSubnet
}

if ($Comment) {
    $data.comment = $Comment
}

if ($NewName) {
    $data.name = $NewName
}

# Check there's something to update
if ($data.Count -eq 0) {
    Write-Warning "No modification specified. Use -NewSubnet, -Comment or -NewName."
    return
}

Write-Host "`nUpdating address '$Name'..." -ForegroundColor Cyan
$data.GetEnumerator() | ForEach-Object {
    Write-Host "  $($_.Key): $($_.Value)"
}

# Send request
$result = Invoke-FMGRequest -Method "update" -Url $url -Data $data -Session $Session

if ($result.success) {
    Write-Host "`n[OK] Address '$Name' updated!" -ForegroundColor Green

    if ($NewName) {
        Write-Host "     Renamed to '$NewName'" -ForegroundColor Cyan
    }
} else {
    Write-Host "`n[ERROR] Code $($result.code): $($result.message)" -ForegroundColor Red

    switch ($result.code) {
        -2 { Write-Host "Address '$Name' does not exist." -ForegroundColor Yellow }
        -10 { Write-Host "Address is used in a policy. Cannot modify some fields." -ForegroundColor Yellow }
    }
}

return $result
