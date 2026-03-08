<#
.SYNOPSIS
    Session-based authentication to FortiManager

.DESCRIPTION
    This script performs a login to FortiManager and returns the session token.
    This token must be used in all subsequent requests.

.OUTPUTS
    String - The session token

.EXAMPLE
    $session = .\login-session.ps1
    Write-Host "Token: $session"

.NOTES
    Requires FMG_USERNAME and FMG_PASSWORD variables in .env
#>

# Load configuration
. "$PSScriptRoot\..\config\fmg-config.ps1"

# Check credentials
if (-not $env:FMG_USERNAME -or -not $env:FMG_PASSWORD) {
    Write-Error "FMG_USERNAME and FMG_PASSWORD must be defined in .env"
    return $null
}

# Build login payload
$payload = @{
    id = 1
    method = "exec"
    params = @(
        @{
            url = "/sys/login/user"
            data = @{
                user = $env:FMG_USERNAME
                passwd = $env:FMG_PASSWORD
            }
        }
    )
}

$jsonPayload = $payload | ConvertTo-Json -Depth 10

# Headers
$headers = @{
    "Content-Type" = "application/json"
}

# URL
$uri = "https://$($env:FMG_HOST):$($env:FMG_PORT)/jsonrpc"

Write-Host "Connecting to $env:FMG_HOST..." -ForegroundColor Cyan

try {
    $response = Invoke-RestMethod -Uri $uri -Method Post -Body $jsonPayload -Headers $headers

    # Check status
    $status = $response.result[0].status
    if ($status.code -ne 0) {
        Write-Error "Login failed: $($status.message)"
        return $null
    }

    # Extract session token
    $session = $response.session

    if ($session) {
        Write-Host "Login successful!" -ForegroundColor Green
        Write-Host "Session: $($session.Substring(0,20))..." -ForegroundColor DarkGray

        # Store in global variable for convenience
        $global:FMG_SESSION = $session

        return $session
    } else {
        Write-Error "No session token in response"
        return $null
    }

} catch {
    Write-Error "Connection error: $_"
    return $null
}
