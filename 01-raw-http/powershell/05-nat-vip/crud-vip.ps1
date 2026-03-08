<#
.SYNOPSIS
    CRUD for FortiManager VIPs (Virtual IPs)

.DESCRIPTION
    This script manages Virtual IP objects for DNAT (Destination NAT).
    Supports static NAT and port forwarding configurations.

.PARAMETER Action
    Action to perform: create, read, delete

.PARAMETER Name
    VIP name

.PARAMETER ExtIP
    External IP (public IP)

.PARAMETER MappedIP
    Mapped IP (internal/private IP)

.PARAMETER ExtPort
    External port (for port forwarding)

.PARAMETER MappedPort
    Mapped port (for port forwarding)

.PARAMETER Comment
    Optional comment

.PARAMETER Session
    Session token (optional if using API Key)

.EXAMPLE
    # Create static NAT VIP
    .\crud-vip.ps1 -Action create -Name "VIP_WEB" -ExtIP "203.0.113.10" -MappedIP "10.10.10.5"

.EXAMPLE
    # Create port forwarding VIP
    .\crud-vip.ps1 -Action create -Name "VIP_SSH" -ExtIP "203.0.113.10" -MappedIP "10.10.10.5" -ExtPort "2222" -MappedPort "22"

.EXAMPLE
    # List all VIPs
    .\crud-vip.ps1 -Action read
#>

param(
    [Parameter(Mandatory)]
    [ValidateSet("create", "read", "delete")]
    [string]$Action,

    [Parameter()]
    [string]$Name,

    [Parameter()]
    [string]$ExtIP,

    [Parameter()]
    [string]$MappedIP,

    [Parameter()]
    [string]$ExtPort,

    [Parameter()]
    [string]$MappedPort,

    [Parameter()]
    [string]$Comment,

    [Parameter()]
    [string]$Session
)

# Load tools
. "$PSScriptRoot\..\config\fmg-config.ps1"
. "$PSScriptRoot\..\utils\Invoke-FMGRequest.ps1"

$baseUrl = "/pm/config/adom/$($script:FMG_ADOM)/obj/firewall/vip"

switch ($Action) {
    "create" {
        if (-not $Name -or -not $ExtIP -or -not $MappedIP) {
            Write-Error "-Name, -ExtIP, and -MappedIP parameters required"
            return
        }

        $data = @{
            name = $Name
            type = "static-nat"
            extip = $ExtIP
            mappedip = @(@{ range = $MappedIP })
            extintf = "any"
        }

        # Port forwarding configuration
        if ($ExtPort -and $MappedPort) {
            $data."portforward" = "enable"
            $data.extport = $ExtPort
            $data.mappedport = $MappedPort
            $data.protocol = "tcp"
        }

        if ($Comment) { $data.comment = $Comment }

        Write-Host "`nCreating VIP '$Name'..." -ForegroundColor Cyan
        Write-Host "  $ExtIP -> $MappedIP"

        $result = Invoke-FMGRequest -Method "add" -Url $baseUrl -Data $data -Session $Session

        if ($result.success) {
            Write-Host "[OK] VIP created!" -ForegroundColor Green
        } else {
            Write-Host "[ERROR] $($result.message)" -ForegroundColor Red
        }
    }

    "read" {
        $url = if ($Name) { "$baseUrl/$Name" } else { $baseUrl }

        $options = @{
            fields = @("name", "type", "extip", "mappedip", "extport", "mappedport", "comment")
        }

        Write-Host "`nRetrieving VIPs..." -ForegroundColor Cyan

        $result = Invoke-FMGRequest -Method "get" -Url $url -Session $Session -Options $options

        if ($result.success -and $result.data) {
            $vips = if ($result.data -is [Array]) { $result.data } else { @($result.data) }

            Write-Host "[OK] $($vips.Count) VIP(s)" -ForegroundColor Green

            $vips | ForEach-Object {
                $mapped = if ($_.mappedip) {
                    ($_.mappedip | ForEach-Object { $_.range }) -join ","
                } else { "N/A" }

                $ports = if ($_.extport) { "$($_.extport)->$($_.mappedport)" } else { "" }

                [PSCustomObject]@{
                    Name      = $_.name
                    Type      = $_.type
                    ExtIP     = $_.extip
                    MappedIP  = $mapped
                    Ports     = $ports
                }
            } | Format-Table -AutoSize
        }
    }

    "delete" {
        if (-not $Name) { Write-Error "-Name parameter required"; return }

        $url = "$baseUrl/$Name"

        Write-Host "`nDeleting VIP '$Name'..." -ForegroundColor Cyan

        $result = Invoke-FMGRequest -Method "delete" -Url $url -Session $Session

        if ($result.success) {
            Write-Host "[OK] VIP deleted!" -ForegroundColor Green
        } else {
            Write-Host "[ERROR] $($result.message)" -ForegroundColor Red
        }
    }
}
