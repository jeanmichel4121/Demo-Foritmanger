#!/bin/bash
#
# FortiManager Configuration Loader
#
# Loads environment variables from .env file at project root.
# These variables are used by all other scripts in the bash section.
#
# Usage:
#   source "$(dirname "$0")/../config/fmg-config.sh"
#   echo "Connecting to $FMG_HOST"
#

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Find .env file (search in multiple locations)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE=""

# Try different paths
for path in \
    "$SCRIPT_DIR/../../.env" \
    "$SCRIPT_DIR/../../../.env" \
    "./.env" \
    "$HOME/.fmg.env"; do
    if [[ -f "$path" ]]; then
        ENV_FILE="$path"
        break
    fi
done

if [[ -f "$ENV_FILE" ]]; then
    [[ "$FMG_DEBUG" == "true" ]] && echo -e "${CYAN}Loading configuration from $ENV_FILE${NC}"

    # Load .env file
    while IFS= read -r line || [[ -n "$line" ]]; do
        # Skip empty lines and comments
        [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue

        # Parse key=value
        if [[ "$line" =~ ^([^=]+)=(.*)$ ]]; then
            key="${BASH_REMATCH[1]}"
            value="${BASH_REMATCH[2]}"

            # Trim whitespace
            key="$(echo "$key" | xargs)"
            value="$(echo "$value" | xargs)"

            # Remove surrounding quotes
            value="${value#\"}"
            value="${value%\"}"
            value="${value#\'}"
            value="${value%\'}"

            # Export variable
            export "$key=$value"
        fi
    done < "$ENV_FILE"

    [[ "$FMG_DEBUG" == "true" ]] && echo -e "${GREEN}Configuration loaded: FMG_HOST=$FMG_HOST, FMG_ADOM=$FMG_ADOM${NC}"
else
    echo -e "${YELLOW}Warning: .env file not found!${NC}"
    echo "Create .env file at project root with:"
    echo ""
    echo "FMG_HOST=192.168.1.100"
    echo "FMG_PORT=443"
    echo "FMG_USERNAME=api_admin"
    echo "FMG_PASSWORD=your_password"
    echo "FMG_ADOM=root"
    echo "FMG_VERIFY_SSL=false"
    echo ""
fi

# Set defaults
export FMG_PORT="${FMG_PORT:-443}"
export FMG_ADOM="${FMG_ADOM:-root}"
export FMG_VERIFY_SSL="${FMG_VERIFY_SSL:-true}"

# Build base URL
export FMG_BASE_URL="https://${FMG_HOST}:${FMG_PORT}/jsonrpc"

# Build cURL options
CURL_OPTS="-s"
if [[ "$FMG_VERIFY_SSL" == "false" ]]; then
    CURL_OPTS="$CURL_OPTS -k"
fi
export CURL_OPTS

# Check for required tools
check_dependencies() {
    local missing=()

    command -v curl >/dev/null 2>&1 || missing+=("curl")
    command -v jq >/dev/null 2>&1 || missing+=("jq")

    if [[ ${#missing[@]} -gt 0 ]]; then
        echo -e "${RED}Error: Missing required tools: ${missing[*]}${NC}"
        echo "Install with:"
        echo "  Ubuntu/Debian: sudo apt install ${missing[*]}"
        echo "  CentOS/RHEL:   sudo yum install ${missing[*]}"
        echo "  macOS:         brew install ${missing[*]}"
        return 1
    fi
    return 0
}

# Run dependency check
check_dependencies || exit 1
