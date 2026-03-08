#!/bin/bash
#
# Test connection with API Key (Bearer Token)
#
# This script tests connection to FortiManager using an API Key.
# With Bearer token, no explicit login/logout is needed.
#
# Usage:
#   ./login-bearer.sh
#
# Output:
#   FortiManager system info if connection succeeds
#
# Notes:
#   Requires FMG_API_KEY in .env
#   Available since FortiManager 7.2.2+
#

set -euo pipefail

# Load configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../config/fmg-config.sh"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
GRAY='\033[0;90m'
NC='\033[0m'

# Check API Key
if [[ -z "$FMG_API_KEY" ]]; then
    echo -e "${YELLOW}Warning: FMG_API_KEY is not defined in .env${NC}"
    echo ""
    echo "To use Bearer token:"
    echo "1. On FortiManager: System Settings > Admin > Administrators"
    echo "2. Create admin with type 'API User'"
    echo "3. Generate an API Key"
    echo "4. Add FMG_API_KEY=<your_key> to .env"
    exit 1
fi

# Build test request (read system status)
PAYLOAD=$(cat <<EOF
{
    "id": 1,
    "method": "get",
    "params": [{
        "url": "/sys/status"
    }]
}
EOF
)

echo -e "${CYAN}Testing Bearer connection to $FMG_HOST...${NC}"

# Send request with Bearer token
RESPONSE=$(curl $CURL_OPTS -X POST "$FMG_BASE_URL" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $FMG_API_KEY" \
    -d "$PAYLOAD" 2>&1)

# Check for curl errors
if [[ $? -ne 0 ]]; then
    echo -e "${RED}Connection error: $RESPONSE${NC}"
    exit 1
fi

# Check status code
STATUS_CODE=$(echo "$RESPONSE" | jq -r '.result[0].status.code // -1')

if [[ "$STATUS_CODE" != "0" ]]; then
    STATUS_MSG=$(echo "$RESPONSE" | jq -r '.result[0].status.message // "Unknown error"')
    echo -e "${RED}Connection failed: $STATUS_MSG${NC}"
    echo "Verify that API Key is valid and admin has required permissions."
    exit 1
fi

# Show FMG info
echo -e "\n${GREEN}Bearer connection successful!${NC}"
echo -e "\n${CYAN}FortiManager Info:${NC}"

HOSTNAME=$(echo "$RESPONSE" | jq -r '.result[0].data.Hostname // "N/A"')
VERSION=$(echo "$RESPONSE" | jq -r '.result[0].data.Version // "N/A"')
SERIAL=$(echo "$RESPONSE" | jq -r '.result[0].data.Serial // "N/A"')
ADMIN=$(echo "$RESPONSE" | jq -r '.result[0].data.Admin // "N/A"')

echo "  Hostname: $HOSTNAME"
echo "  Version:  $VERSION"
echo "  Serial:   $SERIAL"
echo "  Admin:    $ADMIN"

echo -e "\n${GRAY}No session required with Bearer token.${NC}"
echo "Use scripts directly without login/logout."
