#!/bin/bash
#
# CRUD operations for Firewall Policies in FortiManager
#
# Usage:
#   ./crud-policies.sh -a ACTION [OPTIONS]
#
# Actions: create, read, update, delete, move
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../config/fmg-config.sh"
source "$SCRIPT_DIR/../utils/fmg-request.sh"

ACTION=""
PACKAGE="${FMG_PKG:-default}"
NAME=""
POLICYID=""
SRCINTF=""
DSTINTF=""
SRCADDR=""
DSTADDR=""
SERVICE=""
POLICY_ACTION="accept"
SCHEDULE="always"
NAT="disable"
COMMENT=""
MOVE_TARGET=""
MOVE_OPTION="before"
SESSION=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -a|--action) ACTION="$2"; shift 2 ;;
        -p|--package) PACKAGE="$2"; shift 2 ;;
        -n|--name) NAME="$2"; shift 2 ;;
        -i|--id) POLICYID="$2"; shift 2 ;;
        --srcintf) SRCINTF="$2"; shift 2 ;;
        --dstintf) DSTINTF="$2"; shift 2 ;;
        --srcaddr) SRCADDR="$2"; shift 2 ;;
        --dstaddr) DSTADDR="$2"; shift 2 ;;
        --service) SERVICE="$2"; shift 2 ;;
        --policy-action) POLICY_ACTION="$2"; shift 2 ;;
        --schedule) SCHEDULE="$2"; shift 2 ;;
        --nat) NAT="$2"; shift 2 ;;
        -c|--comment) COMMENT="$2"; shift 2 ;;
        --move-target) MOVE_TARGET="$2"; shift 2 ;;
        --move-option) MOVE_OPTION="$2"; shift 2 ;;
        -S|--session) SESSION="$2"; shift 2 ;;
        -h|--help)
            echo "Usage: $0 -a ACTION [OPTIONS]"
            echo ""
            echo "Actions: create, read, update, delete, move"
            echo ""
            echo "Options:"
            echo "  -p, --package     Policy package name (default: $PACKAGE)"
            echo "  -n, --name        Policy name"
            echo "  -i, --id          Policy ID (for update/delete/move)"
            echo "  --srcintf         Source interfaces (comma-separated)"
            echo "  --dstintf         Destination interfaces (comma-separated)"
            echo "  --srcaddr         Source addresses (comma-separated)"
            echo "  --dstaddr         Destination addresses (comma-separated)"
            echo "  --service         Services (comma-separated)"
            echo "  --policy-action   accept or deny (default: accept)"
            echo "  --schedule        Schedule name (default: always)"
            echo "  --nat             enable or disable (default: disable)"
            echo "  --move-target     Target policy ID for move"
            echo "  --move-option     before or after (default: before)"
            exit 0
            ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

URL="/pm/config/adom/$FMG_ADOM/pkg/$PACKAGE/firewall/policy"

# Helper to convert comma-separated to JSON array
to_json_array() {
    echo "$1" | jq -R 'split(",")'
}

case "$ACTION" in
    create)
        [[ -z "$NAME" ]] && { print_error "Name required"; exit 1; }

        DATA="{\"name\": \"$NAME\", \"action\": \"$POLICY_ACTION\", \"schedule\": \"$SCHEDULE\", \"nat\": \"$NAT\", \"logtraffic\": \"all\", \"status\": \"enable\""

        [[ -n "$SRCINTF" ]] && DATA="$DATA, \"srcintf\": $(to_json_array "$SRCINTF")"
        [[ -n "$DSTINTF" ]] && DATA="$DATA, \"dstintf\": $(to_json_array "$DSTINTF")"
        [[ -n "$SRCADDR" ]] && DATA="$DATA, \"srcaddr\": $(to_json_array "$SRCADDR")"
        [[ -n "$DSTADDR" ]] && DATA="$DATA, \"dstaddr\": $(to_json_array "$DSTADDR")"
        [[ -n "$SERVICE" ]] && DATA="$DATA, \"service\": $(to_json_array "$SERVICE")"
        [[ -n "$COMMENT" ]] && DATA="$DATA, \"comments\": \"$COMMENT\""

        DATA="$DATA}"

        print_info "Creating policy '$NAME' in package '$PACKAGE'..."
        RESPONSE=$(fmg_add "$URL" "$DATA" "$SESSION")
        fmg_is_success "$RESPONSE" && print_success "Policy '$NAME' created!" || print_error "$(fmg_get_error "$RESPONSE")"
        ;;

    read)
        [[ -n "$POLICYID" ]] && URL="$URL/$POLICYID"
        print_info "Retrieving policies from package '$PACKAGE'..."
        RESPONSE=$(fmg_get "$URL" '{"fields": ["policyid", "name", "srcintf", "dstintf", "srcaddr", "dstaddr", "service", "action", "status"]}' "$SESSION")

        if fmg_is_success "$RESPONSE"; then
            echo ""
            printf "%-6s %-25s %-12s %-12s %-12s %-8s\n" "ID" "NAME" "SRC INTF" "DST INTF" "ACTION" "STATUS"
            printf "%s\n" "--------------------------------------------------------------------------------"
            fmg_get_data "$RESPONSE" | jq -r '
                (if type == "array" then . else [.] end) |
                .[] |
                [
                    .policyid // "N/A",
                    .name // "N/A",
                    (if .srcintf then (if (.srcintf | type) == "array" then (.srcintf | map(if type == "object" then .name else . end) | join(",")) else .srcintf end) else "-" end),
                    (if .dstintf then (if (.dstintf | type) == "array" then (.dstintf | map(if type == "object" then .name else . end) | join(",")) else .dstintf end) else "-" end),
                    .action // "-",
                    .status // "-"
                ] | @tsv
            ' | while IFS=$'\t' read -r id name srcintf dstintf action status; do
                printf "%-6s %-25s %-12s %-12s %-12s %-8s\n" "$id" "$name" "$srcintf" "$dstintf" "$action" "$status"
            done
        else
            print_error "$(fmg_get_error "$RESPONSE")"
        fi
        ;;

    update)
        [[ -z "$POLICYID" ]] && { print_error "Policy ID required (-i)"; exit 1; }

        DATA="{"
        FIRST=true

        add_field() {
            [[ "$FIRST" == false ]] && DATA="$DATA, "
            DATA="$DATA$1"
            FIRST=false
        }

        [[ -n "$NAME" ]] && add_field "\"name\": \"$NAME\""
        [[ -n "$SRCINTF" ]] && add_field "\"srcintf\": $(to_json_array "$SRCINTF")"
        [[ -n "$DSTINTF" ]] && add_field "\"dstintf\": $(to_json_array "$DSTINTF")"
        [[ -n "$SRCADDR" ]] && add_field "\"srcaddr\": $(to_json_array "$SRCADDR")"
        [[ -n "$DSTADDR" ]] && add_field "\"dstaddr\": $(to_json_array "$DSTADDR")"
        [[ -n "$SERVICE" ]] && add_field "\"service\": $(to_json_array "$SERVICE")"
        [[ -n "$COMMENT" ]] && add_field "\"comments\": \"$COMMENT\""

        DATA="$DATA}"

        print_info "Updating policy ID $POLICYID..."
        RESPONSE=$(fmg_update "$URL/$POLICYID" "$DATA" "$SESSION")
        fmg_is_success "$RESPONSE" && print_success "Policy updated!" || print_error "$(fmg_get_error "$RESPONSE")"
        ;;

    delete)
        [[ -z "$POLICYID" ]] && { print_error "Policy ID required (-i)"; exit 1; }
        print_info "Deleting policy ID $POLICYID..."
        RESPONSE=$(fmg_delete "$URL/$POLICYID" "$SESSION")
        fmg_is_success "$RESPONSE" && print_success "Policy deleted!" || print_error "$(fmg_get_error "$RESPONSE")"
        ;;

    move)
        [[ -z "$POLICYID" ]] && { print_error "Policy ID required (-i)"; exit 1; }
        [[ -z "$MOVE_TARGET" ]] && { print_error "Move target required (--move-target)"; exit 1; }

        print_info "Moving policy $POLICYID $MOVE_OPTION policy $MOVE_TARGET..."

        PAYLOAD="{\"id\":1,\"method\":\"move\",\"params\":[{\"url\":\"$URL/$POLICYID\",\"option\":\"$MOVE_OPTION\",\"target\":\"$MOVE_TARGET\"}]"
        [[ -n "$SESSION" ]] && PAYLOAD="$PAYLOAD,\"session\":\"$SESSION\""
        [[ -n "$FMG_API_KEY" && -z "$SESSION" ]] && HEADERS=(-H "Authorization: Bearer $FMG_API_KEY")
        PAYLOAD="$PAYLOAD}"

        RESPONSE=$(curl $CURL_OPTS -X POST "$FMG_BASE_URL" \
            -H "Content-Type: application/json" \
            "${HEADERS[@]}" \
            -d "$PAYLOAD")

        if echo "$RESPONSE" | jq -e '.result[0].status.code == 0' >/dev/null; then
            print_success "Policy moved!"
        else
            print_error "$(echo "$RESPONSE" | jq -r '.result[0].status | "\(.code): \(.message)"')"
        fi
        ;;

    *)
        print_error "Invalid action. Use: create, read, update, delete, move"
        exit 1
        ;;
esac
