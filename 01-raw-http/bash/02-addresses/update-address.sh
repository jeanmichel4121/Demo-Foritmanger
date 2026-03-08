#!/bin/bash
#
# Modifies an existing IPv4 address
#
# This script partially updates a firewall address object.
# Uses 'update' method which only modifies specified fields.
#
# Usage:
#   ./update-address.sh -n NAME [-s SUBNET] [-c COMMENT] [-N NEWNAME] [-S SESSION]
#
# Arguments:
#   -n, --name        Name of address to modify (required)
#   -s, --subnet      New subnet (optional)
#   -c, --comment     New comment (optional)
#   -N, --new-name    Rename address to this name (optional)
#   -S, --session     Session token (optional if FMG_API_KEY is set)
#
# Examples:
#   ./update-address.sh -n NET_SERVERS -c "New comment"
#   ./update-address.sh -n NET_SERVERS -s 10.10.20.0/24
#   ./update-address.sh -n OLD_NAME -N NEW_NAME
#

set -euo pipefail

# Load tools
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../config/fmg-config.sh"
source "$SCRIPT_DIR/../utils/fmg-request.sh"

# Default values
NAME=""
NEW_SUBNET=""
COMMENT=""
NEW_NAME=""
SESSION=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -n|--name)
            NAME="$2"
            shift 2
            ;;
        -s|--subnet)
            NEW_SUBNET="$2"
            shift 2
            ;;
        -c|--comment)
            COMMENT="$2"
            shift 2
            ;;
        -N|--new-name)
            NEW_NAME="$2"
            shift 2
            ;;
        -S|--session)
            SESSION="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 -n NAME [-s SUBNET] [-c COMMENT] [-N NEWNAME] [-S SESSION]"
            echo ""
            echo "Options:"
            echo "  -n, --name        Address name to modify (required)"
            echo "  -s, --subnet      New subnet"
            echo "  -c, --comment     New comment"
            echo "  -N, --new-name    Rename address"
            echo "  -S, --session     Session token"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Validate required parameters
if [[ -z "$NAME" ]]; then
    print_error "Name is required (-n)"
    exit 1
fi

# Build update data
DATA="{"
FIRST=true

if [[ -n "$NEW_SUBNET" ]]; then
    SUBNET_MASK=$(cidr_to_mask "$NEW_SUBNET")
    DATA="$DATA\"subnet\": \"$SUBNET_MASK\""
    FIRST=false
    echo "  subnet: $SUBNET_MASK"
fi

if [[ -n "$COMMENT" ]]; then
    [[ "$FIRST" == false ]] && DATA="$DATA, "
    DATA="$DATA\"comment\": \"$COMMENT\""
    FIRST=false
    echo "  comment: $COMMENT"
fi

if [[ -n "$NEW_NAME" ]]; then
    [[ "$FIRST" == false ]] && DATA="$DATA, "
    DATA="$DATA\"name\": \"$NEW_NAME\""
    FIRST=false
    echo "  name: $NEW_NAME"
fi

DATA="$DATA}"

# Check there's something to update
if [[ "$DATA" == "{}" ]]; then
    print_warning "No modification specified. Use -s, -c or -N."
    exit 1
fi

# Endpoint URL
URL="/pm/config/adom/$FMG_ADOM/obj/firewall/address/$NAME"

print_info "Updating address '$NAME'..."

# Send request
RESPONSE=$(fmg_update "$URL" "$DATA" "$SESSION")

if fmg_is_success "$RESPONSE"; then
    print_success "Address '$NAME' updated!"
    [[ -n "$NEW_NAME" ]] && echo "     Renamed to '$NEW_NAME'"
else
    print_error "$(fmg_get_error "$RESPONSE")"

    CODE=$(echo "$RESPONSE" | jq -r '.result[0].status.code')
    case "$CODE" in
        -2) echo "Address '$NAME' does not exist." ;;
        -10) echo "Address is used in a policy. Cannot modify some fields." ;;
    esac
    exit 1
fi
