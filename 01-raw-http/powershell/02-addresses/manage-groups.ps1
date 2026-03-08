<#
.SYNOPSIS
    Address group management

.DESCRIPTION
    This script allows creating, modifying, listing and deleting address groups.

.PARAMETER Action
    Action to perform: create, read, update, delete, add-member, remove-member

.PARAMETER Name
    Group name

.PARAMETER Members
    Group members (array of address names)

.PARAMETER Comment
    Comment

.PARAMETER Session
    Session token (optional if API Key)

.EXAMPLE
    # Create a group
    .\manage-groups.ps1 -Action create -Name "GRP_SERVERS" -Members @("NET_WEB", "NET_DB")

.EXAMPLE
    # List groups
    .\manage-groups.ps1 -Action read

.EXAMPLE
    # Add a member
    .\manage-groups.ps1 -Action add-member -Name "GRP_SERVERS" -Members @("NET_APP")

.EXAMPLE
    # Delete a group
    .\manage-groups.ps1 -Action delete -Name "GRP_SERVERS"
#>

param(
    [Parameter(Mandatory)]
    [ValidateSet("create", "read", "update", "delete", "add-member", "remove-member")]
    [string]$Action,

    [Parameter()]
    [string]$Name,

    [Parameter()]
    [string[]]$Members,

    [Parameter()]
    [string]$Comment,

    [Parameter()]
    [string]$Session
)

# Load tools
. "$PSScriptRoot\..\config\fmg-config.ps1"
. "$PSScriptRoot\..\utils\Invoke-FMGRequest.ps1"

# Base URL for address groups
$baseUrl = "/pm/config/adom/$($script:FMG_ADOM)/obj/firewall/addrgrp"

switch ($Action) {
    "create" {
        if (-not $Name) { Write-Error "-Name parameter required"; return }
        if (-not $Members) { Write-Error "-Members parameter required"; return }

        $data = @{
            name = $Name
            member = $Members
        }
        if ($Comment) { $data.comment = $Comment }

        Write-Host "`nCreating group '$Name'..." -ForegroundColor Cyan
        Write-Host "  Members: $($Members -join ', ')"

        $result = Invoke-FMGRequest -Method "add" -Url $baseUrl -Data $data -Session $Session

        if ($result.success) {
            Write-Host "`n[OK] Group '$Name' created!" -ForegroundColor Green
        } else {
            Write-Host "`n[ERROR] $($result.message)" -ForegroundColor Red
        }
    }

    "read" {
        $url = if ($Name) { "$baseUrl/$Name" } else { $baseUrl }

        Write-Host "`nRetrieving groups..." -ForegroundColor Cyan

        $options = @{ fields = @("name", "member", "comment") }
        $result = Invoke-FMGRequest -Method "get" -Url $url -Session $Session -Options $options

        if ($result.success) {
            $groups = $result.data
            if ($groups -isnot [Array]) { $groups = @($groups) }

            if ($groups.Count -gt 0) {
                Write-Host "`n[OK] $($groups.Count) group(s)" -ForegroundColor Green

                $groups | ForEach-Object {
                    $memberList = if ($_.member) {
                        ($_.member | ForEach-Object { if ($_ -is [string]) { $_ } else { $_.name } }) -join ", "
                    } else { "" }

                    [PSCustomObject]@{
                        Name    = $_.name
                        Members = $memberList
                        Comment = $_.comment
                    }
                } | Format-Table -AutoSize -Wrap
            } else {
                Write-Host "`nNo groups found." -ForegroundColor Yellow
            }
        }
    }

    "update" {
        if (-not $Name) { Write-Error "-Name parameter required"; return }

        $url = "$baseUrl/$Name"
        $data = @{}

        if ($Members) { $data.member = $Members }
        if ($Comment) { $data.comment = $Comment }

        if ($data.Count -eq 0) {
            Write-Warning "Nothing to update."
            return
        }

        Write-Host "`nUpdating group '$Name'..." -ForegroundColor Cyan

        $result = Invoke-FMGRequest -Method "update" -Url $url -Data $data -Session $Session

        if ($result.success) {
            Write-Host "`n[OK] Group updated!" -ForegroundColor Green
        } else {
            Write-Host "`n[ERROR] $($result.message)" -ForegroundColor Red
        }
    }

    "delete" {
        if (-not $Name) { Write-Error "-Name parameter required"; return }

        $url = "$baseUrl/$Name"

        Write-Host "`nDeleting group '$Name'..." -ForegroundColor Cyan

        $result = Invoke-FMGRequest -Method "delete" -Url $url -Session $Session

        if ($result.success) {
            Write-Host "`n[OK] Group deleted!" -ForegroundColor Green
        } else {
            Write-Host "`n[ERROR] $($result.message)" -ForegroundColor Red
        }
    }

    "add-member" {
        if (-not $Name) { Write-Error "-Name parameter required"; return }
        if (-not $Members) { Write-Error "-Members parameter required"; return }

        # First, get current members
        $url = "$baseUrl/$Name"
        $result = Invoke-FMGRequest -Method "get" -Url $url -Session $Session

        if (-not $result.success) {
            Write-Error "Group '$Name' not found."
            return
        }

        $currentMembers = @()
        if ($result.data.member) {
            $currentMembers = $result.data.member | ForEach-Object {
                if ($_ -is [string]) { $_ } else { $_.name }
            }
        }

        # Add new members
        $newMembers = $currentMembers + $Members | Select-Object -Unique

        Write-Host "`nAdding members to group '$Name'..." -ForegroundColor Cyan
        Write-Host "  New: $($Members -join ', ')"

        $data = @{ member = $newMembers }
        $result = Invoke-FMGRequest -Method "update" -Url $url -Data $data -Session $Session

        if ($result.success) {
            Write-Host "`n[OK] Members added!" -ForegroundColor Green
        } else {
            Write-Host "`n[ERROR] $($result.message)" -ForegroundColor Red
        }
    }

    "remove-member" {
        if (-not $Name) { Write-Error "-Name parameter required"; return }
        if (-not $Members) { Write-Error "-Members parameter required"; return }

        # Get current members
        $url = "$baseUrl/$Name"
        $result = Invoke-FMGRequest -Method "get" -Url $url -Session $Session

        if (-not $result.success) {
            Write-Error "Group '$Name' not found."
            return
        }

        $currentMembers = @()
        if ($result.data.member) {
            $currentMembers = $result.data.member | ForEach-Object {
                if ($_ -is [string]) { $_ } else { $_.name }
            }
        }

        # Remove specified members
        $newMembers = $currentMembers | Where-Object { $_ -notin $Members }

        if ($newMembers.Count -eq 0) {
            Write-Warning "Group cannot be empty. Delete the group instead."
            return
        }

        Write-Host "`nRemoving members from group '$Name'..." -ForegroundColor Cyan
        Write-Host "  To remove: $($Members -join ', ')"

        $data = @{ member = $newMembers }
        $result = Invoke-FMGRequest -Method "update" -Url $url -Data $data -Session $Session

        if ($result.success) {
            Write-Host "`n[OK] Members removed!" -ForegroundColor Green
        } else {
            Write-Host "`n[ERROR] $($result.message)" -ForegroundColor Red
        }
    }
}
