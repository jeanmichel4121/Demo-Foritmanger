<#
.SYNOPSIS
    Sends a JSON-RPC request to FortiManager

.DESCRIPTION
    This function encapsulates the logic for sending JSON-RPC requests to
    the FortiManager API, handling authentication and payload structure.

.PARAMETER Method
    JSON-RPC method: get, add, set, update, delete, exec, move, clone

.PARAMETER Url
    FortiManager object URL
    Example: /pm/config/adom/root/obj/firewall/address

.PARAMETER Data
    Data to send (hashtable that will be converted to JSON)

.PARAMETER Session
    Session token (optional if API Key is configured in FMG_API_KEY)

.PARAMETER Options
    Additional options (filter, fields, loadsub, etc.)

.OUTPUTS
    Hashtable containing request result

.EXAMPLE
    # Read all addresses
    Invoke-FMGRequest -Method "get" -Url "/pm/config/adom/root/obj/firewall/address"

.EXAMPLE
    # Create an address
    $data = @{ name = "TEST"; type = "ipmask"; subnet = "10.0.0.0 255.255.255.0" }
    Invoke-FMGRequest -Method "add" -Url "/pm/config/adom/root/obj/firewall/address" -Data $data -Session $session

.EXAMPLE
    # With filter
    $options = @{ filter = @(,@("name", "like", "NET_%")) }
    Invoke-FMGRequest -Method "get" -Url "/pm/config/adom/root/obj/firewall/address" -Options $options
#>

function Invoke-FMGRequest {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateSet("get", "add", "set", "update", "delete", "exec", "move", "clone")]
        [string]$Method,

        [Parameter(Mandatory)]
        [string]$Url,

        [Parameter()]
        [hashtable]$Data,

        [Parameter()]
        [string]$Session,

        [Parameter()]
        [hashtable]$Options
    )

    # Load configuration if not already done
    if (-not $env:FMG_HOST) {
        . "$PSScriptRoot\..\config\fmg-config.ps1"
    }

    # Build request parameters
    $params = @{
        url = $Url
    }

    # Add data if present
    if ($Data) {
        $params.data = $Data
    }

    # Add options if present (filter, fields, etc.)
    if ($Options) {
        foreach ($key in $Options.Keys) {
            $params[$key] = $Options[$key]
        }
    }

    # Build JSON-RPC payload
    $payload = @{
        id = Get-Random -Maximum 9999
        method = $Method
        params = @($params)
    }

    # Add session if provided (session-based mode)
    if ($Session) {
        $payload.session = $Session
    }

    # Convert to JSON
    $jsonPayload = $payload | ConvertTo-Json -Depth 20 -Compress

    # Debug: show request
    if ($env:FMG_DEBUG -eq "true") {
        Write-Host "`n>>> REQUEST >>>" -ForegroundColor Cyan
        Write-Host ($payload | ConvertTo-Json -Depth 20)
    }

    # Build headers
    $headers = @{
        "Content-Type" = "application/json"
        "Accept" = "application/json"
    }

    # If API Key configured, use Bearer token
    if ($env:FMG_API_KEY -and -not $Session) {
        $headers["Authorization"] = "Bearer $($env:FMG_API_KEY)"
    }

    # API URL
    $uri = $script:FMG_BASE_URL
    if (-not $uri) {
        $uri = "https://$($env:FMG_HOST):$($env:FMG_PORT)/jsonrpc"
    }

    try {
        # Send request
        $response = Invoke-RestMethod -Uri $uri -Method Post -Body $jsonPayload -Headers $headers

        # Debug: show response
        if ($env:FMG_DEBUG -eq "true") {
            Write-Host "`n<<< RESPONSE <<<" -ForegroundColor Green
            Write-Host ($response | ConvertTo-Json -Depth 20)
        }

        # Check status
        $status = $response.result[0].status
        if ($status.code -ne 0) {
            Write-Error "FMG Error [$($status.code)]: $($status.message)"
            return @{
                success = $false
                code = $status.code
                message = $status.message
                data = $null
            }
        }

        # Return data
        return @{
            success = $true
            code = 0
            message = "OK"
            data = $response.result[0].data
        }

    } catch {
        Write-Error "Connection error: $_"
        return @{
            success = $false
            code = -1
            message = $_.Exception.Message
            data = $null
        }
    }
}

# Export function
Export-ModuleMember -Function Invoke-FMGRequest -ErrorAction SilentlyContinue
