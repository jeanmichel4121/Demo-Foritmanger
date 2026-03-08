#!/bin/bash
#
# CRUD operations for IP Pools (SNAT) in FortiManager
#
# Usage:
#   ./crud-ippool.sh -a ACTION -n NAME [OPTIONS]
#
# Actions: create, read, update, delete
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../config/fmg-config.sh"
source "$SCRIPT_DIR/../utils/fmg-request.sh"

ACTION=""
NAME=""
STARTIP=""
ENDIP=""
TYPE="overload"
COMMENT=""
SESSION=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -a|--action) ACTION="$2"; shift 2 ;;
        -n|--name) NAME="$2"; shift 2 ;;
        --startip) STARTIP="$2"; shift 2 ;;
        --endip) ENDIP="$2"; shift 2 ;;
        -t|--type) TYPE="$2"; shift 2 ;;
        -c|--comment) COMMENT="$2"; shift 2 ;;
        -S|--session) SESSION="$2"; shift 2 ;;
        -h|--help)
            echo "Usage: $0 -a ACTION -n NAME [OPTIONS]"
            echo ""
            echo "Actions: create, read, update, delete"
            echo ""
            echo "Options:"
            echo "  --startip     Start IP of pool"
            echo "  --endip       End IP of pool"
            echo "  -t, --type    Pool type: overload, one-to-one (default: overload)"
            echo "  -c, --comment Comment"
            exit 0
            ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

URL="/pm/config/adom/$FMG_ADOM/obj/firewall/ippool"

case "$ACTION" in
    create)
        [[ -z "$NAME" ]] && { print_error "Name required"; exit 1; }
        [[ -z "$STARTIP" || -z "$ENDIP" ]] && { print_error "Start and end IPs required"; exit 1; }

        DATA="{\"name\": \"$NAME\", \"type\": \"$TYPE\", \"startip\": \"$STARTIP\", \"endip\": \"$ENDIP\""
        [[ -n "$COMMENT" ]] && DATA="$DATA, \"comment\": \"$COMMENT\""
        DATA="$DATA}"

        print_info "Creating IP Pool '$NAME'..."
        echo "  Range: $STARTIP - $ENDIP ($TYPE)"
        RESPONSE=$(fmg_add "$URL" "$DATA" "$SESSION")
        fmg_is_success "$RESPONSE" && print_success "IP Pool '$NAME' created!" || print_error "$(fmg_get_error "$RESPONSE")"
        ;;

    read)
        [[ -n "$NAME" ]] && URL="$URL/$NAME"
        print_info "Retrieving IP Pools..."
        RESPONSE=$(fmg_get "$URL" '{"fields": ["name", "startip", "endip", "type", "comment"]}' "$SESSION")

        if fmg_is_success "$RESPONSE"; then
            echo ""
            printf "%-25s %-15s %-15s %-12s %s\n" "NAME" "START IP" "END IP" "TYPE" "COMMENT"
            printf "%s\n" "----------------------------------------------------------------------"
            fmg_get_data "$RESPONSE" | jq -r '
                (if type == "array" then . else [.] end) |
                .[] |
                [.name // "N/A", .startip // "-", .endip // "-", .type // "-", .comment // ""] |
                @tsv
            ' | while IFS=$'\t' read -r name start end type comment; do
                printf "%-25s %-15s %-15s %-12s %s\n" "$name" "$start" "$end" "$type" "$comment"
            done
        else
            print_error "$(fmg_get_error "$RESPONSE")"
        fi
        ;;

    update)
        [[ -z "$NAME" ]] && { print_error "Name required"; exit 1; }

        DATA="{"
        FIRST=true
        if [[ -n "$STARTIP" ]]; then DATA="$DATA\"startip\": \"$STARTIP\""; FIRST=false; fi
        if [[ -n "$ENDIP" ]]; then
            [[ "$FIRST" == false ]] && DATA="$DATA, "
            DATA="$DATA\"endip\": \"$ENDIP\""
            FIRST=false
        fi
        if [[ -n "$COMMENT" ]]; then
            [[ "$FIRST" == false ]] && DATA="$DATA, "
            DATA="$DATA\"comment\": \"$COMMENT\""
        fi
        DATA="$DATA}"

        print_info "Updating IP Pool '$NAME'..."
        RESPONSE=$(fmg_update "$URL/$NAME" "$DATA" "$SESSION")
        fmg_is_success "$RESPONSE" && print_success "IP Pool updated!" || print_error "$(fmg_get_error "$RESPONSE")"
        ;;

    delete)
        [[ -z "$NAME" ]] && { print_error "Name required"; exit 1; }
        print_info "Deleting IP Pool '$NAME'..."
        RESPONSE=$(fmg_delete "$URL/$NAME" "$SESSION")
        fmg_is_success "$RESPONSE" && print_success "IP Pool deleted!" || print_error "$(fmg_get_error "$RESPONSE")"
        ;;

    *)
        print_error "Invalid action. Use: create, read, update, delete"
        exit 1
        ;;
esac
