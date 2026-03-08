<#
.SYNOPSIS
    Disconnect from FortiManager (session-based)

.DESCRIPTION
    This script properly closes a FortiManager session.
    Important: always close sessions to free resources.

.PARAMETER Session
    Session token to close. If not specified, uses $global:FMG_SESSION.

.EXAMPLE
    # With explicit session
    .\logout.ps1 -Session "abc123..."

.EXAMPLE
    # With global session (defined by login-session.ps1)
    .\logout.ps1

.NOTES
    Not needed if using Bearer token (API Key)
#>

param(
    [Parameter()]
    [string]$Session
)

# Load configuration
. "$PSScriptRoot\..\config\fmg-config.ps1"

# Use global session if no parameter
if (-not $Session) {
    $Session = $global:FMG_SESSION
}

if (-not $Session) {
    Write-Warning "No session to close. Use login-session.ps1 first."
    return
}

# Build logout payload
$payload = @{
    id = 99
    method = "exec"
    params = @(
        @{
            url = "/sys/logout"
        }
    )
    session = $Session
}

$jsonPayload = $payload | ConvertTo-Json -Depth 10

# Headers
$headers = @{
    "Content-Type" = "application/json"
}

# URL
$uri = "https://$($env:FMG_HOST):$($env:FMG_PORT)/jsonrpc"

Write-Host "Disconnecting from $env:FMG_HOST..." -ForegroundColor Cyan

try {
    $response = Invoke-RestMethod -Uri $uri -Method Post -Body $jsonPayload -Headers $headers

    # Check status
    $status = $response.result[0].status
    if ($status.code -eq 0) {
        Write-Host "Logout successful!" -ForegroundColor Green

        # Clear global variable
        $global:FMG_SESSION = $null
    } else {
        # Code -11 = session already expired/invalid - not a problem
        if ($status.code -eq -11) {
            Write-Host "Session already expired or invalid." -ForegroundColor Yellow
        } else {
            Write-Warning "Logout: $($status.message)"
        }
    }

} catch {
    Write-Error "Error during logout: $_"
}
