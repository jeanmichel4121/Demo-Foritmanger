<#
.SYNOPSIS
    CRUD for FortiManager firewall policies

.DESCRIPTION
    This script manages firewall policies within a policy package.
    Supports create, read, update, delete, and move operations.

.PARAMETER Action
    Action to perform: create, read, update, delete, move

.PARAMETER Package
    Policy package name (default: default)

.PARAMETER Name
    Policy name

.PARAMETER PolicyId
    Policy ID (for update/delete/move operations)

.PARAMETER SrcIntf
    Source interface(s) - comma-separated

.PARAMETER DstIntf
    Destination interface(s) - comma-separated

.PARAMETER SrcAddr
    Source address(es) - comma-separated

.PARAMETER DstAddr
    Destination address(es) - comma-separated

.PARAMETER Service
    Service(s) - comma-separated

.PARAMETER ActionPolicy
    Policy action: accept, deny

.PARAMETER Schedule
    Schedule name (default: always)

.PARAMETER NAT
    Enable/disable NAT: enable, disable

.PARAMETER Comment
    Policy comment

.PARAMETER Session
    Session token (optional if using API Key)

.EXAMPLE
    # Create a policy
    .\crud-policies.ps1 -Action create -Package "default" -Name "Allow_Web" `
        -SrcIntf "internal" -DstIntf "wan1" -SrcAddr "NET_USERS" -DstAddr "all" `
        -Service "HTTP,HTTPS" -ActionPolicy "accept"

.EXAMPLE
    # List all policies in a package
    .\crud-policies.ps1 -Action read -Package "default"

.EXAMPLE
    # Update a policy
    .\crud-policies.ps1 -Action update -Package "default" -PolicyId 5 -Comment "Updated comment"

.EXAMPLE
    # Delete a policy
    .\crud-policies.ps1 -Action delete -Package "default" -PolicyId 5
#>

param(
    [Parameter(Mandatory)]
    [ValidateSet("create", "read", "update", "delete", "move")]
    [string]$Action,

    [Parameter()]
    [string]$Package = "default",

    [Parameter()]
    [string]$Name,

    [Parameter()]
    [int]$PolicyId,

    [Parameter()]
    [string]$SrcIntf,

    [Parameter()]
    [string]$DstIntf,

    [Parameter()]
    [string]$SrcAddr,

    [Parameter()]
    [string]$DstAddr,

    [Parameter()]
    [string]$Service,

    [Parameter()]
    [ValidateSet("accept", "deny")]
    [string]$ActionPolicy = "accept",

    [Parameter()]
    [string]$Schedule = "always",

    [Parameter()]
    [ValidateSet("enable", "disable")]
    [string]$NAT = "disable",

    [Parameter()]
    [string]$Comment,

    [Parameter()]
    [string]$Session
)

# Load tools
. "$PSScriptRoot\..\config\fmg-config.ps1"
. "$PSScriptRoot\..\utils\Invoke-FMGRequest.ps1"

$baseUrl = "/pm/config/adom/$($script:FMG_ADOM)/pkg/$Package/firewall/policy"

# Helper function to convert comma-separated string to array
function ConvertTo-ArrayIfString {
    param([string]$Value)
    if ($Value) {
        return @($Value -split ',\s*')
    }
    return $null
}

switch ($Action) {
    "create" {
        if (-not $Name) { Write-Error "-Name parameter required"; return }

        $data = @{
            name = $Name
            action = $ActionPolicy
            schedule = $Schedule
            nat = $NAT
            logtraffic = "all"
            status = "enable"
        }

        if ($SrcIntf) { $data.srcintf = ConvertTo-ArrayIfString $SrcIntf }
        if ($DstIntf) { $data.dstintf = ConvertTo-ArrayIfString $DstIntf }
        if ($SrcAddr) { $data.srcaddr = ConvertTo-ArrayIfString $SrcAddr }
        if ($DstAddr) { $data.dstaddr = ConvertTo-ArrayIfString $DstAddr }
        if ($Service) { $data.service = ConvertTo-ArrayIfString $Service }
        if ($Comment) { $data.comments = $Comment }

        Write-Host "`nCreating policy '$Name'..." -ForegroundColor Cyan
        Write-Host "  Package: $Package"
        Write-Host "  $SrcAddr ($SrcIntf) -> $DstAddr ($DstIntf) : $Service [$ActionPolicy]"

        $result = Invoke-FMGRequest -Method "add" -Url $baseUrl -Data $data -Session $Session

        if ($result.success) {
            Write-Host "[OK] Policy created!" -ForegroundColor Green
        } else {
            Write-Host "[ERROR] $($result.message)" -ForegroundColor Red
        }
    }

    "read" {
        $url = if ($PolicyId) { "$baseUrl/$PolicyId" } else { $baseUrl }

        $options = @{
            fields = @("policyid", "name", "srcintf", "dstintf", "srcaddr", "dstaddr", "service", "action", "status", "comments")
        }

        Write-Host "`nRetrieving policies (package: $Package)..." -ForegroundColor Cyan

        $result = Invoke-FMGRequest -Method "get" -Url $url -Session $Session -Options $options

        if ($result.success -and $result.data) {
            $policies = if ($result.data -is [Array]) { $result.data } else { @($result.data) }

            Write-Host "[OK] $($policies.Count) policy(ies)" -ForegroundColor Green
            Write-Host ""

            $policies | ForEach-Object {
                $srcIntfs = if ($_.srcintf) { ($_.srcintf | ForEach-Object { if ($_ -is [string]) { $_ } else { $_.name } }) -join "," } else { "any" }
                $dstIntfs = if ($_.dstintf) { ($_.dstintf | ForEach-Object { if ($_ -is [string]) { $_ } else { $_.name } }) -join "," } else { "any" }
                $srcAddrs = if ($_.srcaddr) { ($_.srcaddr | ForEach-Object { if ($_ -is [string]) { $_ } else { $_.name } }) -join "," } else { "any" }
                $dstAddrs = if ($_.dstaddr) { ($_.dstaddr | ForEach-Object { if ($_ -is [string]) { $_ } else { $_.name } }) -join "," } else { "any" }
                $services = if ($_.service) { ($_.service | ForEach-Object { if ($_ -is [string]) { $_ } else { $_.name } }) -join "," } else { "all" }

                [PSCustomObject]@{
                    ID       = $_.policyid
                    Name     = $_.name
                    SrcIntf  = $srcIntfs
                    DstIntf  = $dstIntfs
                    SrcAddr  = $srcAddrs
                    DstAddr  = $dstAddrs
                    Service  = $services
                    Action   = $_.action
                    Status   = $_.status
                }
            } | Format-Table -AutoSize
        }
    }

    "update" {
        if (-not $PolicyId) { Write-Error "-PolicyId parameter required"; return }

        $url = "$baseUrl/$PolicyId"
        $data = @{}

        if ($Name) { $data.name = $Name }
        if ($SrcIntf) { $data.srcintf = ConvertTo-ArrayIfString $SrcIntf }
        if ($DstIntf) { $data.dstintf = ConvertTo-ArrayIfString $DstIntf }
        if ($SrcAddr) { $data.srcaddr = ConvertTo-ArrayIfString $SrcAddr }
        if ($DstAddr) { $data.dstaddr = ConvertTo-ArrayIfString $DstAddr }
        if ($Service) { $data.service = ConvertTo-ArrayIfString $Service }
        if ($Comment) { $data.comments = $Comment }

        if ($data.Count -eq 0) { Write-Warning "Nothing to update"; return }

        Write-Host "`nUpdating policy ID $PolicyId..." -ForegroundColor Cyan

        $result = Invoke-FMGRequest -Method "update" -Url $url -Data $data -Session $Session

        if ($result.success) {
            Write-Host "[OK] Policy updated!" -ForegroundColor Green
        } else {
            Write-Host "[ERROR] $($result.message)" -ForegroundColor Red
        }
    }

    "delete" {
        if (-not $PolicyId) { Write-Error "-PolicyId parameter required"; return }

        $url = "$baseUrl/$PolicyId"

        Write-Host "`nDeleting policy ID $PolicyId..." -ForegroundColor Cyan

        $result = Invoke-FMGRequest -Method "delete" -Url $url -Session $Session

        if ($result.success) {
            Write-Host "[OK] Policy deleted!" -ForegroundColor Green
        } else {
            Write-Host "[ERROR] $($result.message)" -ForegroundColor Red
        }
    }

    "move" {
        Write-Host "Use the web interface or the move API to reorder policies." -ForegroundColor Yellow
    }
}
