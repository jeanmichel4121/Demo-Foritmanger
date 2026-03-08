<#
.SYNOPSIS
    CRUD for FortiManager application groups

.DESCRIPTION
    This script manages application control groups.
    Groups can contain applications or application categories.

.PARAMETER Action
    Action to perform: create, read, delete

.PARAMETER Name
    Group name

.PARAMETER Applications
    List of applications or categories

.PARAMETER Comment
    Optional comment

.PARAMETER Session
    Session token (optional if using API Key)

.EXAMPLE
    # Create application group
    .\crud-app-groups.ps1 -Action create -Name "STREAMING" -Applications @("Netflix", "YouTube", "Spotify")

.EXAMPLE
    # List all application groups
    .\crud-app-groups.ps1 -Action read

.EXAMPLE
    # Delete application group
    .\crud-app-groups.ps1 -Action delete -Name "STREAMING"
#>

param(
    [Parameter(Mandatory)]
    [ValidateSet("create", "read", "delete")]
    [string]$Action,

    [Parameter()]
    [string]$Name,

    [Parameter()]
    [string[]]$Applications,

    [Parameter()]
    [string]$Comment,

    [Parameter()]
    [string]$Session
)

# Load tools
. "$PSScriptRoot\..\config\fmg-config.ps1"
. "$PSScriptRoot\..\utils\Invoke-FMGRequest.ps1"

$baseUrl = "/pm/config/adom/$($script:FMG_ADOM)/obj/application/group"

switch ($Action) {
    "create" {
        if (-not $Name) { Write-Error "-Name parameter required"; return }

        $data = @{
            name = $Name
        }

        if ($Applications) {
            $data.application = $Applications
        }

        if ($Comment) { $data.comment = $Comment }

        Write-Host "`nCreating application group '$Name'..." -ForegroundColor Cyan

        $result = Invoke-FMGRequest -Method "add" -Url $baseUrl -Data $data -Session $Session

        if ($result.success) {
            Write-Host "[OK] Group created!" -ForegroundColor Green
        } else {
            Write-Host "[ERROR] $($result.message)" -ForegroundColor Red
        }
    }

    "read" {
        $url = if ($Name) { "$baseUrl/$Name" } else { $baseUrl }

        Write-Host "`nRetrieving application groups..." -ForegroundColor Cyan

        $result = Invoke-FMGRequest -Method "get" -Url $url -Session $Session

        if ($result.success -and $result.data) {
            $groups = if ($result.data -is [Array]) { $result.data } else { @($result.data) }

            Write-Host "[OK] $($groups.Count) group(s)" -ForegroundColor Green

            $groups | ForEach-Object {
                $apps = if ($_.application) { $_.application -join ", " } else { "" }
                [PSCustomObject]@{
                    Name         = $_.name
                    Applications = $apps
                    Comment      = $_.comment
                }
            } | Format-Table -AutoSize -Wrap
        }
    }

    "delete" {
        if (-not $Name) { Write-Error "-Name parameter required"; return }

        $url = "$baseUrl/$Name"

        Write-Host "`nDeleting group '$Name'..." -ForegroundColor Cyan

        $result = Invoke-FMGRequest -Method "delete" -Url $url -Session $Session

        if ($result.success) {
            Write-Host "[OK] Group deleted!" -ForegroundColor Green
        } else {
            Write-Host "[ERROR] $($result.message)" -ForegroundColor Red
        }
    }
}
