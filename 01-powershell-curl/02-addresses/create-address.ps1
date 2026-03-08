<#
.SYNOPSIS
    Creates an IPv4 address in FortiManager

.DESCRIPTION
    This script creates a firewall address object of type ipmask.
    Other types (iprange, fqdn, geography) are possible.

.PARAMETER Name
    Address name (unique in ADOM)

.PARAMETER Subnet
    Subnet in CIDR format (10.0.0.0/24) or IP MASK (10.0.0.0 255.255.255.0)

.PARAMETER Comment
    Optional comment

.PARAMETER Type
    Address type: ipmask, iprange, fqdn, geography, wildcard

.PARAMETER Session
    Session token (optional if API Key)

.EXAMPLE
    .\create-address.ps1 -Name "NET_SERVERS" -Subnet "10.10.10.0/24"

.EXAMPLE
    .\create-address.ps1 -Name "HOST_WEB01" -Subnet "10.10.10.5/32" -Comment "Main web server"
#>

param(
    [Parameter(Mandatory)]
    [string]$Name,

    [Parameter(Mandatory)]
    [string]$Subnet,

    [Parameter()]
    [string]$Comment = "",

    [Parameter()]
    [ValidateSet("ipmask", "iprange", "fqdn", "geography", "wildcard")]
    [string]$Type = "ipmask",

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

        # Calculate mask
        $mask = [uint32]::MaxValue -shl (32 - $bits)
        $maskBytes = [BitConverter]::GetBytes($mask)
        [Array]::Reverse($maskBytes)
        $maskStr = ($maskBytes | ForEach-Object { $_ }) -join '.'

        return "$ip $maskStr"
    }

    # If already in IP MASK format, return as is
    return $Cidr
}

# Prepare data
$subnet = Convert-CidrToMask -Cidr $Subnet

$data = @{
    name = $Name
    type = $Type
    subnet = $subnet
    "allow-routing" = "disable"
    visibility = "enable"
}

if ($Comment) {
    $data.comment = $Comment
}

# Endpoint URL
$url = "/pm/config/adom/$($script:FMG_ADOM)/obj/firewall/address"

Write-Host "`nCreating address '$Name'..." -ForegroundColor Cyan
Write-Host "  Subnet: $subnet"
Write-Host "  Type:   $Type"

# Send request
$result = Invoke-FMGRequest -Method "add" -Url $url -Data $data -Session $Session

if ($result.success) {
    Write-Host "`n[OK] Address '$Name' created successfully!" -ForegroundColor Green
} else {
    Write-Host "`n[ERROR] Code $($result.code): $($result.message)" -ForegroundColor Red

    # Common errors
    switch ($result.code) {
        -3 { Write-Host "Address already exists." -ForegroundColor Yellow }
        -6 { Write-Host "Permission denied. Check API admin rights." -ForegroundColor Yellow }
    }
}

return $result
