#!/bin/bash
#
# Session-based authentication to FortiManager
#
# This script performs a login to FortiManager and returns the session token.
# This token must be used in all subsequent requests.
#
# Usage:
#   ./login-session.sh
#   SESSION=$(./login-session.sh)
#
# Output:
#   Session token (string)
#
# Notes:
#   Requires FMG_USERNAME and FMG_PASSWORD variables in .env
#

set -e

# Load configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../config/fmg-config.sh"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
GRAY='\033[0;90m'
NC='\033[0m'

# Check credentials
if [[ -z "$FMG_USERNAME" || -z "$FMG_PASSWORD" ]]; then
    echo -e "${RED}Error: FMG_USERNAME and FMG_PASSWORD must be defined in .env${NC}" >&2
    exit 1
fi

# Build login payload
PAYLOAD=$(cat <<EOF
{
    "id": 1,
    "method": "exec",
    "params": [{
        "url": "/sys/login/user",
        "data": {
            "user": "$FMG_USERNAME",
            "passwd": "$FMG_PASSWORD"
        }
    }]
}
EOF
)

echo -e "${CYAN}Connecting to $FMG_HOST...${NC}" >&2

# Send request
RESPONSE=$(curl $CURL_OPTS -X POST "$FMG_BASE_URL" \
    -H "Content-Type: application/json" \
    -d "$PAYLOAD" 2>&1)

# Check for curl errors
if [[ $? -ne 0 ]]; then
    echo -e "${RED}Connection error: $RESPONSE${NC}" >&2
    exit 1
fi

# Check status code
STATUS_CODE=$(echo "$RESPONSE" | jq -r '.result[0].status.code // -1')

if [[ "$STATUS_CODE" != "0" ]]; then
    STATUS_MSG=$(echo "$RESPONSE" | jq -r '.result[0].status.message // "Unknown error"')
    echo -e "${RED}Login failed: $STATUS_MSG${NC}" >&2
    exit 1
fi

# Extract session token
SESSION=$(echo "$RESPONSE" | jq -r '.session // empty')

if [[ -z "$SESSION" ]]; then
    echo -e "${RED}Error: No session token in response${NC}" >&2
    exit 1
fi

echo -e "${GREEN}Login successful!${NC}" >&2
echo -e "${GRAY}Session: ${SESSION:0:20}...${NC}" >&2

# Output session token (for capture)
echo "$SESSION"
