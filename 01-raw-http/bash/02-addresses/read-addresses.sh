#!/bin/bash
#
# Lists IPv4 addresses from FortiManager
#
# This script retrieves firewall address objects from the configured ADOM.
# Supports name filters (wildcards).
#
# Usage:
#   ./read-addresses.sh [-f FILTER] [-n NAME] [-S SESSION]
#
# Arguments:
#   -f, --filter    Name filter (e.g., "NET_*", "*SERVERS*")
#   -n, --name      Exact name of a specific address
#   -S, --session   Session token (optional if FMG_API_KEY is set)
#   -j, --json      Output raw JSON
#
# Examples:
#   ./read-addresses.sh                    # All addresses
#   ./read-addresses.sh -f "NET_*"         # Filter by name pattern
#   ./read-addresses.sh -n NET_SERVERS     # Specific address
#

set -euo pipefail

# Load tools
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../config/fmg-config.sh"
source "$SCRIPT_DIR/../utils/fmg-request.sh"

# Default values
FILTER=""
NAME=""
SESSION=""
JSON_OUTPUT=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -f|--filter)
            FILTER="$2"
            shift 2
            ;;
        -n|--name)
            NAME="$2"
            shift 2
            ;;
        -S|--session)
            SESSION="$2"
            shift 2
            ;;
        -j|--json)
            JSON_OUTPUT=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [-f FILTER] [-n NAME] [-S SESSION] [-j]"
            echo ""
            echo "Options:"
            echo "  -f, --filter    Name filter (e.g., 'NET_*')"
            echo "  -n, --name      Exact address name"
            echo "  -S, --session   Session token"
            echo "  -j, --json      Output raw JSON"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Endpoint URL
URL="/pm/config/adom/$FMG_ADOM/obj/firewall/address"

# Add specific name to URL if provided
if [[ -n "$NAME" ]]; then
    URL="$URL/$NAME"
fi

# Build options JSON
OPTIONS='{"fields": ["name", "subnet", "type", "comment"], "loadsub": 0'

# Add filter if specified
if [[ -n "$FILTER" ]]; then
    # Convert * to % for FMG pattern
    PATTERN="${FILTER//\*/%}"
    OPTIONS="$OPTIONS, \"filter\": [[\"name\", \"like\", \"$PATTERN\"]]"
fi

OPTIONS="$OPTIONS}"

print_info "Retrieving addresses..."
[[ -n "$FILTER" ]] && echo "  Filter: $FILTER"

# Send request
RESPONSE=$(fmg_get "$URL" "$OPTIONS" "$SESSION")

if fmg_is_success "$RESPONSE"; then
    DATA=$(fmg_get_data "$RESPONSE")

    # Check if we have data
    if [[ "$DATA" == "null" || "$DATA" == "[]" ]]; then
        print_warning "No addresses found."
        exit 0
    fi

    # Count results
    COUNT=$(echo "$DATA" | jq 'if type == "array" then length else 1 end')
    print_success "$COUNT address(es) found"
    echo ""

    # Output format
    if $JSON_OUTPUT; then
        echo "$DATA" | jq .
    else
        # Table format
        printf "%-30s %-10s %-25s %s\n" "NAME" "TYPE" "SUBNET" "COMMENT"
        printf "%s\n" "--------------------------------------------------------------------------------"

        echo "$DATA" | jq -r '
            (if type == "array" then . else [.] end) |
            .[] |
            [
                .name // "N/A",
                .type // "N/A",
                (if .subnet then (if (.subnet | type) == "array" then .subnet | join(" ") else .subnet end) else "N/A" end),
                .comment // ""
            ] |
            @tsv
        ' | while IFS=$'\t' read -r name type subnet comment; do
            printf "%-30s %-10s %-25s %s\n" "$name" "$type" "$subnet" "$comment"
        done
    fi
else
    print_error "$(fmg_get_error "$RESPONSE")"
    exit 1
fi
