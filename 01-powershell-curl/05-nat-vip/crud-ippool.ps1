<#
.SYNOPSIS
    CRUD for FortiManager IP Pools (SNAT)

.DESCRIPTION
    This script manages IP Pool objects for SNAT (Source NAT).
    Supports overload (PAT), one-to-one, and fixed-port-range types.

.PARAMETER Action
    Action to perform: create, read, delete

.PARAMETER Name
    IP Pool name

.PARAMETER StartIP
    First IP address in the pool

.PARAMETER EndIP
    Last IP address in the pool

.PARAMETER Type
    Pool type: overload (PAT), one-to-one, fixed-port-range

.PARAMETER Comment
    Optional comment

.PARAMETER Session
    Session token (optional if using API Key)

.EXAMPLE
    # Create overload IP pool (PAT)
    .\crud-ippool.ps1 -Action create -Name "POOL_NAT" -StartIP "203.0.113.20" -EndIP "203.0.113.25"

.EXAMPLE
    # Create one-to-one IP pool
    .\crud-ippool.ps1 -Action create -Name "POOL_1TO1" -StartIP "203.0.113.30" -EndIP "203.0.113.35" -Type "one-to-one"

.EXAMPLE
    # List all IP pools
    .\crud-ippool.ps1 -Action read
#>

param(
    [Parameter(Mandatory)]
    [ValidateSet("create", "read", "delete")]
    [string]$Action,

    [Parameter()]
    [string]$Name,

    [Parameter()]
    [string]$StartIP,

    [Parameter()]
    [string]$EndIP,

    [Parameter()]
    [ValidateSet("overload", "one-to-one", "fixed-port-range")]
    [string]$Type = "overload",

    [Parameter()]
    [string]$Comment,

    [Parameter()]
    [string]$Session
)

# Load tools
. "$PSScriptRoot\..\config\fmg-config.ps1"
. "$PSScriptRoot\..\utils\Invoke-FMGRequest.ps1"

$baseUrl = "/pm/config/adom/$($script:FMG_ADOM)/obj/firewall/ippool"

switch ($Action) {
    "create" {
        if (-not $Name -or -not $StartIP -or -not $EndIP) {
            Write-Error "-Name, -StartIP, and -EndIP parameters required"
            return
        }

        $data = @{
            name = $Name
            type = $Type
            startip = $StartIP
            endip = $EndIP
        }

        if ($Comment) { $data.comment = $Comment }

        Write-Host "`nCreating IP Pool '$Name'..." -ForegroundColor Cyan
        Write-Host "  Range: $StartIP - $EndIP ($Type)"

        $result = Invoke-FMGRequest -Method "add" -Url $baseUrl -Data $data -Session $Session

        if ($result.success) {
            Write-Host "[OK] IP Pool created!" -ForegroundColor Green
        } else {
            Write-Host "[ERROR] $($result.message)" -ForegroundColor Red
        }
    }

    "read" {
        $url = if ($Name) { "$baseUrl/$Name" } else { $baseUrl }

        $options = @{
            fields = @("name", "type", "startip", "endip", "comment")
        }

        Write-Host "`nRetrieving IP Pools..." -ForegroundColor Cyan

        $result = Invoke-FMGRequest -Method "get" -Url $url -Session $Session -Options $options

        if ($result.success -and $result.data) {
            $pools = if ($result.data -is [Array]) { $result.data } else { @($result.data) }

            Write-Host "[OK] $($pools.Count) pool(s)" -ForegroundColor Green

            $pools | ForEach-Object {
                [PSCustomObject]@{
                    Name    = $_.name
                    Type    = $_.type
                    Range   = "$($_.startip) - $($_.endip)"
                    Comment = $_.comment
                }
            } | Format-Table -AutoSize
        }
    }

    "delete" {
        if (-not $Name) { Write-Error "-Name parameter required"; return }

        $url = "$baseUrl/$Name"

        Write-Host "`nDeleting IP Pool '$Name'..." -ForegroundColor Cyan

        $result = Invoke-FMGRequest -Method "delete" -Url $url -Session $Session

        if ($result.success) {
            Write-Host "[OK] IP Pool deleted!" -ForegroundColor Green
        } else {
            Write-Host "[ERROR] $($result.message)" -ForegroundColor Red
        }
    }
}
