#!/bin/bash
#
# FortiManager JSON-RPC Request Helper
#
# This script provides a reusable function for sending JSON-RPC requests
# to the FortiManager API, handling authentication and payload structure.
#
# Usage:
#   source "$(dirname "$0")/../utils/fmg-request.sh"
#   fmg_request "get" "/pm/config/adom/root/obj/firewall/address"
#
# Functions:
#   fmg_request METHOD URL [DATA] [SESSION]
#   fmg_get URL [OPTIONS_JSON]
#   fmg_add URL DATA [SESSION]
#   fmg_update URL DATA [SESSION]
#   fmg_delete URL [SESSION]
#   fmg_exec URL [DATA] [SESSION]
#

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Load config if not already loaded
if [[ -z "$FMG_HOST" ]]; then
    source "$(dirname "${BASH_SOURCE[0]}")/../config/fmg-config.sh"
fi

#
# Main JSON-RPC request function
#
# Arguments:
#   $1 - method: get, add, set, update, delete, exec, move, clone
#   $2 - url: FortiManager object URL
#   $3 - data: JSON data (optional)
#   $4 - session: Session token (optional if FMG_API_KEY is set)
#   $5 - options: Additional JSON options like filter, fields (optional)
#
# Returns:
#   JSON response from FortiManager
#   Exit code: 0 on success, 1 on error
#
fmg_request() {
    local method="$1"
    local url="$2"
    local data="$3"
    local session="$4"
    local options="$5"

    # Validate method
    case "$method" in
        get|add|set|update|delete|exec|move|clone) ;;
        *)
            echo -e "${RED}Error: Invalid method '$method'${NC}" >&2
            echo "Valid methods: get, add, set, update, delete, exec, move, clone" >&2
            return 1
            ;;
    esac

    # Generate random request ID
    local id=$((RANDOM % 9999 + 1))

    # Build params object
    local params="{\"url\":\"$url\""

    # Add data if provided
    if [[ -n "$data" && "$data" != "null" ]]; then
        params="$params,\"data\":$data"
    fi

    # Add options if provided (filter, fields, etc.)
    if [[ -n "$options" && "$options" != "null" ]]; then
        # Merge options into params
        # Remove leading { and trailing } from options, then append
        local opts_inner="${options#\{}"
        opts_inner="${opts_inner%\}}"
        if [[ -n "$opts_inner" ]]; then
            params="$params,$opts_inner"
        fi
    fi

    params="$params}"

    # Build payload
    local payload="{\"id\":$id,\"method\":\"$method\",\"params\":[$params]"

    # Add session if provided
    if [[ -n "$session" ]]; then
        payload="$payload,\"session\":\"$session\""
    fi

    payload="$payload}"

    # Debug output
    if [[ "$FMG_DEBUG" == "true" ]]; then
        echo -e "\n${CYAN}>>> REQUEST >>>${NC}" >&2
        echo "$payload" | jq . >&2
    fi

    # Build headers
    local headers=(-H "Content-Type: application/json" -H "Accept: application/json")

    # Add Bearer token if API key is set and no session provided
    if [[ -n "$FMG_API_KEY" && -z "$session" ]]; then
        headers+=(-H "Authorization: Bearer $FMG_API_KEY")
    fi

    # Send request
    local response
    response=$(curl $CURL_OPTS -X POST "$FMG_BASE_URL" \
        "${headers[@]}" \
        -d "$payload" 2>&1)

    local curl_exit=$?

    if [[ $curl_exit -ne 0 ]]; then
        echo -e "${RED}Error: cURL failed with exit code $curl_exit${NC}" >&2
        echo "$response" >&2
        return 1
    fi

    # Debug output
    if [[ "$FMG_DEBUG" == "true" ]]; then
        echo -e "\n${GREEN}<<< RESPONSE <<<${NC}" >&2
        echo "$response" | jq . >&2
    fi

    # Check if response is valid JSON
    if ! echo "$response" | jq . >/dev/null 2>&1; then
        echo -e "${RED}Error: Invalid JSON response${NC}" >&2
        echo "$response" >&2
        return 1
    fi

    # Check status code
    local status_code
    status_code=$(echo "$response" | jq -r '.result[0].status.code // -999')

    if [[ "$status_code" != "0" ]]; then
        local status_message
        status_message=$(echo "$response" | jq -r '.result[0].status.message // "Unknown error"')
        echo -e "${RED}Error [$status_code]: $status_message${NC}" >&2

        # Provide helpful hints based on error code
        case "$status_code" in
            -2)  echo "Hint: Object not found - check name, ADOM, or path" >&2 ;;
            -3)  echo "Hint: Object already exists - use 'update' or 'set'" >&2 ;;
            -6)  echo "Hint: Permission denied - check user permissions" >&2 ;;
            -10) echo "Hint: Object in use - remove references first" >&2 ;;
            -11) echo "Hint: Invalid session - re-authenticate" >&2 ;;
            -10147) echo "Hint: ADOM locked - use workspace lock/unlock" >&2 ;;
        esac

        # Still output the response for parsing
        echo "$response"
        return 1
    fi

    # Output response
    echo "$response"
    return 0
}

#
# Convenience function: GET request
#
fmg_get() {
    local url="$1"
    local options="$2"
    local session="$3"
    fmg_request "get" "$url" "" "$session" "$options"
}

#
# Convenience function: ADD request
#
fmg_add() {
    local url="$1"
    local data="$2"
    local session="$3"
    fmg_request "add" "$url" "$data" "$session"
}

#
# Convenience function: UPDATE request
#
fmg_update() {
    local url="$1"
    local data="$2"
    local session="$3"
    fmg_request "update" "$url" "$data" "$session"
}

#
# Convenience function: SET request (create or replace)
#
fmg_set() {
    local url="$1"
    local data="$2"
    local session="$3"
    fmg_request "set" "$url" "$data" "$session"
}

#
# Convenience function: DELETE request
#
fmg_delete() {
    local url="$1"
    local session="$2"
    fmg_request "delete" "$url" "" "$session"
}

#
# Convenience function: EXEC request
#
fmg_exec() {
    local url="$1"
    local data="$2"
    local session="$3"
    fmg_request "exec" "$url" "$data" "$session"
}

#
# Helper: Extract data from response
#
fmg_get_data() {
    local response="$1"
    echo "$response" | jq -r '.result[0].data'
}

#
# Helper: Check if request was successful
#
fmg_is_success() {
    local response="$1"
    local code
    code=$(echo "$response" | jq -r '.result[0].status.code // -1')
    [[ "$code" == "0" ]]
}

#
# Helper: Get error message from response
#
fmg_get_error() {
    local response="$1"
    echo "$response" | jq -r '.result[0].status | "\(.code): \(.message)"'
}

#
# Helper: Convert CIDR notation to subnet mask
# Example: 192.168.1.0/24 -> 192.168.1.0 255.255.255.0
#
cidr_to_mask() {
    local cidr="$1"

    # Check if already in mask format
    if [[ "$cidr" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+\ [0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo "$cidr"
        return
    fi

    # Parse CIDR
    if [[ "$cidr" =~ ^([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)/([0-9]+)$ ]]; then
        local ip="${BASH_REMATCH[1]}"
        local bits="${BASH_REMATCH[2]}"

        # Calculate netmask
        local mask=$((0xffffffff << (32 - bits)))
        local m1=$(((mask >> 24) & 255))
        local m2=$(((mask >> 16) & 255))
        local m3=$(((mask >> 8) & 255))
        local m4=$((mask & 255))

        echo "$ip $m1.$m2.$m3.$m4"
    else
        # Return as-is if not CIDR format
        echo "$cidr"
    fi
}

#
# Helper: Print success message
#
print_success() {
    echo -e "${GREEN}[OK]${NC} $1"
}

#
# Helper: Print error message
#
print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

#
# Helper: Print warning message
#
print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

#
# Helper: Print info message
#
print_info() {
    echo -e "${CYAN}[INFO]${NC} $1"
}
