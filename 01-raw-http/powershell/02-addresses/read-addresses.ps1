<#
.SYNOPSIS
    Lists IPv4 addresses from FortiManager

.DESCRIPTION
    This script retrieves firewall address objects from the configured ADOM.
    Supports name filters (wildcards).

.PARAMETER Filter
    Name filter (e.g., "NET_*", "*SERVERS*")

.PARAMETER Name
    Exact name of a specific address

.PARAMETER Fields
    Fields to return (default: name, subnet, type, comment)

.PARAMETER Session
    Session token (optional if API Key)

.EXAMPLE
    # All addresses
    .\read-addresses.ps1

.EXAMPLE
    # Addresses starting with NET_
    .\read-addresses.ps1 -Filter "NET_*"

.EXAMPLE
    # Specific address
    .\read-addresses.ps1 -Name "NET_SERVERS"
#>

param(
    [Parameter()]
    [string]$Filter,

    [Parameter()]
    [string]$Name,

    [Parameter()]
    [string[]]$Fields = @("name", "subnet", "type", "comment"),

    [Parameter()]
    [string]$Session
)

# Load tools
. "$PSScriptRoot\..\config\fmg-config.ps1"
. "$PSScriptRoot\..\utils\Invoke-FMGRequest.ps1"

# Endpoint URL
$url = "/pm/config/adom/$($script:FMG_ADOM)/obj/firewall/address"

# If specific name, add to URL
if ($Name) {
    $url += "/$Name"
}

# Request options
$options = @{
    fields = $Fields
    loadsub = 0
}

# Add filter if specified
if ($Filter) {
    # Convert wildcard to FMG pattern (% for *)
    $pattern = $Filter -replace '\*', '%'
    $options.filter = @(,@("name", "like", $pattern))
}

Write-Host "`nRetrieving addresses..." -ForegroundColor Cyan
if ($Filter) { Write-Host "  Filter: $Filter" }

# Send request
$result = Invoke-FMGRequest -Method "get" -Url $url -Session $Session -Options $options

if ($result.success) {
    $addresses = $result.data

    # Ensure we have an array
    if ($addresses -and $addresses -isnot [Array]) {
        $addresses = @($addresses)
    }

    if ($addresses -and $addresses.Count -gt 0) {
        Write-Host "`n[OK] $($addresses.Count) address(es) found" -ForegroundColor Green
        Write-Host ""

        # Display as table
        $addresses | ForEach-Object {
            $subnet = if ($_.subnet) {
                if ($_.subnet -is [Array]) { $_.subnet -join " " } else { $_.subnet }
            } else { "N/A" }

            [PSCustomObject]@{
                Name    = $_.name
                Type    = $_.type
                Subnet  = $subnet
                Comment = $_.comment
            }
        } | Format-Table -AutoSize

    } else {
        Write-Host "`nNo addresses found." -ForegroundColor Yellow
    }

    return $addresses

} else {
    Write-Host "`n[ERROR] Code $($result.code): $($result.message)" -ForegroundColor Red
    return $null
}
