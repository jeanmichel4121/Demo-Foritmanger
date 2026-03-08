<#
.SYNOPSIS
    CRUD for FortiManager custom services

.DESCRIPTION
    This script manages custom firewall services (TCP/UDP/SCTP/ICMP).
    Supports create, read, update, and delete operations.

.PARAMETER Action
    Action to perform: create, read, update, delete

.PARAMETER Name
    Service name

.PARAMETER Protocol
    Protocol: TCP, UDP, SCTP, ICMP, IP

.PARAMETER Port
    Port or port range (e.g., "443", "8080-8090")

.PARAMETER Filter
    Name filter for read operations (e.g., "SVC_*")

.PARAMETER Comment
    Optional comment

.PARAMETER Session
    Session token (optional if using API Key)

.EXAMPLE
    # Create a service
    .\crud-services.ps1 -Action create -Name "SVC_HTTPS_8443" -Protocol TCP -Port "8443"

.EXAMPLE
    # List services with filter
    .\crud-services.ps1 -Action read -Filter "SVC_*"

.EXAMPLE
    # Delete a service
    .\crud-services.ps1 -Action delete -Name "SVC_HTTPS_8443"
#>

param(
    [Parameter(Mandatory)]
    [ValidateSet("create", "read", "update", "delete")]
    [string]$Action,

    [Parameter()]
    [string]$Name,

    [Parameter()]
    [ValidateSet("TCP", "UDP", "SCTP", "ICMP", "IP")]
    [string]$Protocol = "TCP",

    [Parameter()]
    [string]$Port,

    [Parameter()]
    [string]$Filter,

    [Parameter()]
    [string]$Comment,

    [Parameter()]
    [string]$Session
)

# Load tools
. "$PSScriptRoot\..\config\fmg-config.ps1"
. "$PSScriptRoot\..\utils\Invoke-FMGRequest.ps1"

$baseUrl = "/pm/config/adom/$($script:FMG_ADOM)/obj/firewall/service/custom"

switch ($Action) {
    "create" {
        if (-not $Name -or -not $Port) {
            Write-Error "-Name and -Port parameters required"
            return
        }

        $data = @{
            name = $Name
            protocol = "TCP/UDP/SCTP"
        }

        # Configure port based on protocol
        switch ($Protocol) {
            "TCP" { $data."tcp-portrange" = $Port }
            "UDP" { $data."udp-portrange" = $Port }
            "SCTP" { $data."sctp-portrange" = $Port }
        }

        if ($Comment) { $data.comment = $Comment }

        Write-Host "`nCreating service '$Name' ($Protocol/$Port)..." -ForegroundColor Cyan

        $result = Invoke-FMGRequest -Method "add" -Url $baseUrl -Data $data -Session $Session

        if ($result.success) {
            Write-Host "[OK] Service created!" -ForegroundColor Green
        } else {
            Write-Host "[ERROR] $($result.message)" -ForegroundColor Red
        }
    }

    "read" {
        $url = if ($Name) { "$baseUrl/$Name" } else { $baseUrl }

        $options = @{
            fields = @("name", "protocol", "tcp-portrange", "udp-portrange", "comment")
        }

        if ($Filter) {
            $pattern = $Filter -replace '\*', '%'
            $options.filter = @(,@("name", "like", $pattern))
        }

        Write-Host "`nRetrieving services..." -ForegroundColor Cyan

        $result = Invoke-FMGRequest -Method "get" -Url $url -Session $Session -Options $options

        if ($result.success -and $result.data) {
            $services = if ($result.data -is [Array]) { $result.data } else { @($result.data) }

            Write-Host "[OK] $($services.Count) service(s)" -ForegroundColor Green

            $services | ForEach-Object {
                $ports = if ($_."tcp-portrange") { "TCP/$($_.'tcp-portrange')" }
                         elseif ($_."udp-portrange") { "UDP/$($_.'udp-portrange')" }
                         else { $_.protocol }

                [PSCustomObject]@{
                    Name    = $_.name
                    Ports   = $ports
                    Comment = $_.comment
                }
            } | Format-Table -AutoSize
        }
    }

    "update" {
        if (-not $Name) { Write-Error "-Name parameter required"; return }

        $url = "$baseUrl/$Name"
        $data = @{}

        if ($Port -and $Protocol) {
            switch ($Protocol) {
                "TCP" { $data."tcp-portrange" = $Port }
                "UDP" { $data."udp-portrange" = $Port }
            }
        }
        if ($Comment) { $data.comment = $Comment }

        if ($data.Count -eq 0) { Write-Warning "Nothing to update"; return }

        Write-Host "`nUpdating service '$Name'..." -ForegroundColor Cyan

        $result = Invoke-FMGRequest -Method "update" -Url $url -Data $data -Session $Session

        if ($result.success) {
            Write-Host "[OK] Service updated!" -ForegroundColor Green
        } else {
            Write-Host "[ERROR] $($result.message)" -ForegroundColor Red
        }
    }

    "delete" {
        if (-not $Name) { Write-Error "-Name parameter required"; return }

        $url = "$baseUrl/$Name"

        Write-Host "`nDeleting service '$Name'..." -ForegroundColor Cyan

        $result = Invoke-FMGRequest -Method "delete" -Url $url -Session $Session

        if ($result.success) {
            Write-Host "[OK] Service deleted!" -ForegroundColor Green
        } else {
            Write-Host "[ERROR] $($result.message)" -ForegroundColor Red
        }
    }
}
