#!/bin/bash
#
# Creates an IPv4 address in FortiManager
#
# This script creates a firewall address object of type ipmask.
# Other types (iprange, fqdn, geography) are possible.
#
# Usage:
#   ./create-address.sh -n NAME -s SUBNET [-c COMMENT] [-t TYPE] [-S SESSION]
#
# Arguments:
#   -n, --name      Address name (required)
#   -s, --subnet    Subnet in CIDR (10.0.0.0/24) or IP MASK format (required)
#   -c, --comment   Optional comment
#   -t, --type      Address type: ipmask, iprange, fqdn (default: ipmask)
#   -S, --session   Session token (optional if FMG_API_KEY is set)
#
# Examples:
#   ./create-address.sh -n NET_SERVERS -s 10.10.10.0/24
#   ./create-address.sh -n HOST_WEB01 -s 10.10.10.5/32 -c "Main web server"
#

set -e

# Load tools
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../config/fmg-config.sh"
source "$SCRIPT_DIR/../utils/fmg-request.sh"

# Default values
TYPE="ipmask"
COMMENT=""
SESSION=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -n|--name)
            NAME="$2"
            shift 2
            ;;
        -s|--subnet)
            SUBNET="$2"
            shift 2
            ;;
        -c|--comment)
            COMMENT="$2"
            shift 2
            ;;
        -t|--type)
            TYPE="$2"
            shift 2
            ;;
        -S|--session)
            SESSION="$2"
            shift 2
            ;;
        -h|--help)
            echo "Usage: $0 -n NAME -s SUBNET [-c COMMENT] [-t TYPE] [-S SESSION]"
            echo ""
            echo "Options:"
            echo "  -n, --name      Address name (required)"
            echo "  -s, --subnet    Subnet in CIDR or IP MASK format (required)"
            echo "  -c, --comment   Optional comment"
            echo "  -t, --type      Address type: ipmask, iprange, fqdn (default: ipmask)"
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

if [[ -z "$SUBNET" ]]; then
    print_error "Subnet is required (-s)"
    exit 1
fi

# Convert CIDR to IP MASK format
SUBNET_MASK=$(cidr_to_mask "$SUBNET")

# Build data JSON
DATA=$(cat <<EOF
{
    "name": "$NAME",
    "type": "$TYPE",
    "subnet": "$SUBNET_MASK",
    "allow-routing": "disable",
    "visibility": "enable"
EOF
)

# Add comment if provided
if [[ -n "$COMMENT" ]]; then
    DATA="$DATA, \"comment\": \"$COMMENT\""
fi

DATA="$DATA}"

# Endpoint URL
URL="/pm/config/adom/$FMG_ADOM/obj/firewall/address"

print_info "Creating address '$NAME'..."
echo "  Subnet: $SUBNET_MASK"
echo "  Type:   $TYPE"

# Send request
RESPONSE=$(fmg_add "$URL" "$DATA" "$SESSION")

if fmg_is_success "$RESPONSE"; then
    print_success "Address '$NAME' created successfully!"
else
    print_error "$(fmg_get_error "$RESPONSE")"

    # Common errors
    CODE=$(echo "$RESPONSE" | jq -r '.result[0].status.code')
    case "$CODE" in
        -3) echo "Address already exists." ;;
        -6) echo "Permission denied. Check API admin rights." ;;
    esac
    exit 1
fi
