#!/bin/bash
#
# Disconnect from FortiManager (session-based)
#
# This script properly closes a FortiManager session.
# Important: always close sessions to free resources.
#
# Usage:
#   ./logout.sh <session_token>
#   ./logout.sh "$SESSION"
#
# Arguments:
#   $1 - Session token to close
#
# Notes:
#   Not needed if using Bearer token (API Key)
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
NC='\033[0m'

# Get session from argument or environment
SESSION="${1:-$FMG_SESSION}"

if [[ -z "$SESSION" ]]; then
    echo -e "${YELLOW}Warning: No session to close.${NC}"
    echo "Usage: $0 <session_token>"
    echo "Or set FMG_SESSION environment variable."
    exit 1
fi

# Build logout payload
PAYLOAD=$(cat <<EOF
{
    "id": 99,
    "method": "exec",
    "params": [{
        "url": "/sys/logout"
    }],
    "session": "$SESSION"
}
EOF
)

echo -e "${CYAN}Disconnecting from $FMG_HOST...${NC}"

# Send request
RESPONSE=$(curl $CURL_OPTS -X POST "$FMG_BASE_URL" \
    -H "Content-Type: application/json" \
    -d "$PAYLOAD" 2>&1)

# Check status code
STATUS_CODE=$(echo "$RESPONSE" | jq -r '.result[0].status.code // -1')

case "$STATUS_CODE" in
    0)
        echo -e "${GREEN}Logout successful!${NC}"
        ;;
    -11)
        # Session already expired/invalid - not a problem
        echo -e "${YELLOW}Session already expired or invalid.${NC}"
        ;;
    *)
        STATUS_MSG=$(echo "$RESPONSE" | jq -r '.result[0].status.message // "Unknown error"')
        echo -e "${YELLOW}Logout: $STATUS_MSG${NC}"
        ;;
esac
