<#
.SYNOPSIS
    CRUD for FortiManager schedules

.DESCRIPTION
    This script manages firewall schedules (one-time and recurring).
    Supports create, read, and delete operations.

.PARAMETER Action
    Action to perform: create, read, delete

.PARAMETER Type
    Schedule type: onetime, recurring

.PARAMETER Name
    Schedule name

.PARAMETER Start
    Start date/time (onetime) - format: "YYYY-MM-DD HH:MM"

.PARAMETER End
    End date/time (onetime) - format: "YYYY-MM-DD HH:MM"

.PARAMETER Days
    Days of the week (recurring) - monday, tuesday, wednesday, thursday, friday, saturday, sunday

.PARAMETER StartTime
    Start time (recurring) - format: "HH:MM"

.PARAMETER EndTime
    End time (recurring) - format: "HH:MM"

.PARAMETER Session
    Session token (optional if using API Key)

.EXAMPLE
    # Create one-time schedule
    .\crud-schedules.ps1 -Action create -Type onetime -Name "MAINT" -Start "2024-06-01 22:00" -End "2024-06-02 06:00"

.EXAMPLE
    # Create recurring schedule
    .\crud-schedules.ps1 -Action create -Type recurring -Name "BUSINESS_HOURS" -Days @("monday","tuesday","wednesday","thursday","friday") -StartTime "08:00" -EndTime "18:00"

.EXAMPLE
    # List all schedules
    .\crud-schedules.ps1 -Action read
#>

param(
    [Parameter(Mandatory)]
    [ValidateSet("create", "read", "delete")]
    [string]$Action,

    [Parameter()]
    [ValidateSet("onetime", "recurring")]
    [string]$Type = "onetime",

    [Parameter()]
    [string]$Name,

    [Parameter()]
    [string]$Start,

    [Parameter()]
    [string]$End,

    [Parameter()]
    [string[]]$Days,

    [Parameter()]
    [string]$StartTime,

    [Parameter()]
    [string]$EndTime,

    [Parameter()]
    [string]$Session
)

# Load tools
. "$PSScriptRoot\..\config\fmg-config.ps1"
. "$PSScriptRoot\..\utils\Invoke-FMGRequest.ps1"

$baseUrl = "/pm/config/adom/$($script:FMG_ADOM)/obj/firewall/schedule/$Type"

switch ($Action) {
    "create" {
        if (-not $Name) { Write-Error "-Name parameter required"; return }

        $data = @{ name = $Name }

        if ($Type -eq "onetime") {
            if (-not $Start -or -not $End) {
                Write-Error "-Start and -End parameters required for onetime schedules"
                return
            }
            $data.start = $Start
            $data.end = $End
        }
        elseif ($Type -eq "recurring") {
            if ($Days) {
                $data.day = $Days
            }
            if ($StartTime) { $data."start-time" = $StartTime }
            if ($EndTime) { $data."end-time" = $EndTime }
        }

        Write-Host "`nCreating schedule '$Name' ($Type)..." -ForegroundColor Cyan

        $result = Invoke-FMGRequest -Method "add" -Url $baseUrl -Data $data -Session $Session

        if ($result.success) {
            Write-Host "[OK] Schedule created!" -ForegroundColor Green
        } else {
            Write-Host "[ERROR] $($result.message)" -ForegroundColor Red
        }
    }

    "read" {
        # Read both schedule types
        Write-Host "`nOne-time Schedules:" -ForegroundColor Cyan
        $urlOnetime = "/pm/config/adom/$($script:FMG_ADOM)/obj/firewall/schedule/onetime"
        $result = Invoke-FMGRequest -Method "get" -Url $urlOnetime -Session $Session

        if ($result.success -and $result.data) {
            $schedules = if ($result.data -is [Array]) { $result.data } else { @($result.data) }
            $schedules | ForEach-Object {
                [PSCustomObject]@{
                    Name  = $_.name
                    Start = $_.start
                    End   = $_.end
                }
            } | Format-Table -AutoSize
        }

        Write-Host "`nRecurring Schedules:" -ForegroundColor Cyan
        $urlRecurring = "/pm/config/adom/$($script:FMG_ADOM)/obj/firewall/schedule/recurring"
        $result = Invoke-FMGRequest -Method "get" -Url $urlRecurring -Session $Session

        if ($result.success -and $result.data) {
            $schedules = if ($result.data -is [Array]) { $result.data } else { @($result.data) }
            $schedules | ForEach-Object {
                $daysList = if ($_.day) { $_.day -join "," } else { "all" }
                [PSCustomObject]@{
                    Name  = $_.name
                    Days  = $daysList
                    Time  = "$($_.'start-time') - $($_.'end-time')"
                }
            } | Format-Table -AutoSize
        }
    }

    "delete" {
        if (-not $Name) { Write-Error "-Name parameter required"; return }

        $url = "$baseUrl/$Name"

        Write-Host "`nDeleting schedule '$Name'..." -ForegroundColor Cyan

        $result = Invoke-FMGRequest -Method "delete" -Url $url -Session $Session

        if ($result.success) {
            Write-Host "[OK] Schedule deleted!" -ForegroundColor Green
        } else {
            Write-Host "[ERROR] $($result.message)" -ForegroundColor Red
        }
    }
}
