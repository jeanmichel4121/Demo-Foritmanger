#!/bin/bash
#
# CRUD operations for Virtual IPs (VIP/DNAT) in FortiManager
#
# Usage:
#   ./crud-vip.sh -a ACTION -n NAME [OPTIONS]
#
# Actions: create, read, update, delete
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../config/fmg-config.sh"
source "$SCRIPT_DIR/../utils/fmg-request.sh"

ACTION=""
NAME=""
EXTIP=""
MAPPEDIP=""
EXTPORT=""
MAPPEDPORT=""
EXTINTF="any"
TYPE="static-nat"
COMMENT=""
SESSION=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -a|--action) ACTION="$2"; shift 2 ;;
        -n|--name) NAME="$2"; shift 2 ;;
        --extip) EXTIP="$2"; shift 2 ;;
        --mappedip) MAPPEDIP="$2"; shift 2 ;;
        --extport) EXTPORT="$2"; shift 2 ;;
        --mappedport) MAPPEDPORT="$2"; shift 2 ;;
        --extintf) EXTINTF="$2"; shift 2 ;;
        -c|--comment) COMMENT="$2"; shift 2 ;;
        -S|--session) SESSION="$2"; shift 2 ;;
        -h|--help)
            echo "Usage: $0 -a ACTION -n NAME [OPTIONS]"
            echo ""
            echo "Actions: create, read, update, delete"
            echo ""
            echo "Options:"
            echo "  --extip       External IP address"
            echo "  --mappedip    Mapped (internal) IP address"
            echo "  --extport     External port (for port forwarding)"
            echo "  --mappedport  Mapped port (for port forwarding)"
            echo "  --extintf     External interface (default: any)"
            echo "  -c, --comment Comment"
            exit 0
            ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

URL="/pm/config/adom/$FMG_ADOM/obj/firewall/vip"

case "$ACTION" in
    create)
        [[ -z "$NAME" ]] && { print_error "Name required"; exit 1; }
        [[ -z "$EXTIP" || -z "$MAPPEDIP" ]] && { print_error "External and mapped IPs required"; exit 1; }

        DATA="{\"name\": \"$NAME\", \"type\": \"$TYPE\", \"extip\": \"$EXTIP\", \"mappedip\": \"$MAPPEDIP\", \"extintf\": \"$EXTINTF\""

        # Port forwarding
        if [[ -n "$EXTPORT" && -n "$MAPPEDPORT" ]]; then
            DATA="$DATA, \"portforward\": \"enable\", \"protocol\": \"tcp\", \"extport\": \"$EXTPORT\", \"mappedport\": \"$MAPPEDPORT\""
        fi

        [[ -n "$COMMENT" ]] && DATA="$DATA, \"comment\": \"$COMMENT\""
        DATA="$DATA}"

        print_info "Creating VIP '$NAME'..."
        echo "  External:  $EXTIP -> Mapped: $MAPPEDIP"
        RESPONSE=$(fmg_add "$URL" "$DATA" "$SESSION")
        fmg_is_success "$RESPONSE" && print_success "VIP '$NAME' created!" || print_error "$(fmg_get_error "$RESPONSE")"
        ;;

    read)
        [[ -n "$NAME" ]] && URL="$URL/$NAME"
        print_info "Retrieving VIPs..."
        RESPONSE=$(fmg_get "$URL" '{"fields": ["name", "extip", "mappedip", "extport", "mappedport", "comment"]}' "$SESSION")

        if fmg_is_success "$RESPONSE"; then
            echo ""
            printf "%-20s %-15s %-15s %-10s %s\n" "NAME" "EXTERNAL" "MAPPED" "PORTS" "COMMENT"
            printf "%s\n" "----------------------------------------------------------------------"
            fmg_get_data "$RESPONSE" | jq -r '
                (if type == "array" then . else [.] end) |
                .[] |
                [
                    .name // "N/A",
                    .extip // "-",
                    (if .mappedip then (if (.mappedip | type) == "array" then .mappedip[0] else .mappedip end) else "-" end),
                    (if .extport then "\(.extport)->\(.mappedport)" else "-" end),
                    .comment // ""
                ] | @tsv
            ' | while IFS=$'\t' read -r name ext map ports comment; do
                printf "%-20s %-15s %-15s %-10s %s\n" "$name" "$ext" "$map" "$ports" "$comment"
            done
        else
            print_error "$(fmg_get_error "$RESPONSE")"
        fi
        ;;

    update)
        [[ -z "$NAME" ]] && { print_error "Name required"; exit 1; }

        DATA="{"
        FIRST=true
        if [[ -n "$EXTIP" ]]; then DATA="$DATA\"extip\": \"$EXTIP\""; FIRST=false; fi
        if [[ -n "$MAPPEDIP" ]]; then
            [[ "$FIRST" == false ]] && DATA="$DATA, "
            DATA="$DATA\"mappedip\": \"$MAPPEDIP\""
            FIRST=false
        fi
        if [[ -n "$COMMENT" ]]; then
            [[ "$FIRST" == false ]] && DATA="$DATA, "
            DATA="$DATA\"comment\": \"$COMMENT\""
        fi
        DATA="$DATA}"

        print_info "Updating VIP '$NAME'..."
        RESPONSE=$(fmg_update "$URL/$NAME" "$DATA" "$SESSION")
        fmg_is_success "$RESPONSE" && print_success "VIP updated!" || print_error "$(fmg_get_error "$RESPONSE")"
        ;;

    delete)
        [[ -z "$NAME" ]] && { print_error "Name required"; exit 1; }
        print_info "Deleting VIP '$NAME'..."
        RESPONSE=$(fmg_delete "$URL/$NAME" "$SESSION")
        fmg_is_success "$RESPONSE" && print_success "VIP deleted!" || print_error "$(fmg_get_error "$RESPONSE")"
        ;;

    *)
        print_error "Invalid action. Use: create, read, update, delete"
        exit 1
        ;;
esac
