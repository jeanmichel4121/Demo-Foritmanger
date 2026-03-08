#!/bin/bash
#
# Deletes an IPv4 address from FortiManager
#
# This script deletes a firewall address object.
# Warning: deletion fails if address is used in a policy.
#
# Usage:
#   ./delete-address.sh -n NAME [-f] [-S SESSION]
#
# Arguments:
#   -n, --name      Name of address to delete (required)
#   -f, --force     Delete without confirmation
#   -S, --session   Session token (optional if FMG_API_KEY is set)
#
# Examples:
#   ./delete-address.sh -n NET_SERVERS
#   ./delete-address.sh -n NET_SERVERS -f
#

set -e

# Load tools
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../config/fmg-config.sh"
source "$SCRIPT_DIR/../utils/fmg-request.sh"

# Default values
NAME=""
FORCE=false
SESSION=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -n|--name)
            NAME="$2"
            shift 2
            ;;
        -f|--force)
            FORCE=true
            shift
            ;;
        -S|--session)
            SESSION="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 -n NAME [-f] [-S SESSION]"
            echo ""
            echo "Options:"
            echo "  -n, --name      Address name to delete (required)"
            echo "  -f, --force     Delete without confirmation"
            echo "  -S, --session   Session token"
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

# Confirmation unless --force
if [[ "$FORCE" == false ]]; then
    echo -e "${YELLOW}Delete address '$NAME'${NC}"
    read -p "Confirm? (y/N) " CONFIRM

    if [[ ! "$CONFIRM" =~ ^[yY] ]]; then
        echo "Operation cancelled."
        exit 0
    fi
fi

# Endpoint URL
URL="/pm/config/adom/$FMG_ADOM/obj/firewall/address/$NAME"

print_info "Deleting address '$NAME'..."

# Send request
RESPONSE=$(fmg_delete "$URL" "$SESSION")

if fmg_is_success "$RESPONSE"; then
    print_success "Address '$NAME' deleted!"
else
    print_error "$(fmg_get_error "$RESPONSE")"

    CODE=$(echo "$RESPONSE" | jq -r '.result[0].status.code')
    case "$CODE" in
        -2) echo "Address '$NAME' does not exist." ;;
        -10)
            echo "Address is used in one or more policies."
            echo "Remove references to this address first."
            ;;
    esac
    exit 1
fi
