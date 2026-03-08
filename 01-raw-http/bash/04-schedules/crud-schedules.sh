#!/bin/bash
#
# CRUD operations for schedules in FortiManager
#
# Usage:
#   ./crud-schedules.sh -a ACTION -n NAME [OPTIONS]
#
# Actions: create, read, update, delete
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../config/fmg-config.sh"
source "$SCRIPT_DIR/../utils/fmg-request.sh"

ACTION=""
NAME=""
START=""
END=""
COMMENT=""
SESSION=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -a|--action) ACTION="$2"; shift 2 ;;
        -n|--name) NAME="$2"; shift 2 ;;
        --start) START="$2"; shift 2 ;;
        --end) END="$2"; shift 2 ;;
        -c|--comment) COMMENT="$2"; shift 2 ;;
        -S|--session) SESSION="$2"; shift 2 ;;
        -h|--help)
            echo "Usage: $0 -a ACTION -n NAME [OPTIONS]"
            echo ""
            echo "Actions: create, read, update, delete"
            echo ""
            echo "Options:"
            echo "  --start      Start datetime (format: 'HH:MM YYYY/MM/DD')"
            echo "  --end        End datetime (format: 'HH:MM YYYY/MM/DD')"
            echo "  -c, --comment  Comment"
            exit 0
            ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

URL="/pm/config/adom/$FMG_ADOM/obj/firewall/schedule/onetime"

case "$ACTION" in
    create)
        [[ -z "$NAME" ]] && { print_error "Name required"; exit 1; }
        [[ -z "$START" || -z "$END" ]] && { print_error "Start and end times required"; exit 1; }

        DATA="{\"name\": \"$NAME\", \"start\": \"$START\", \"end\": \"$END\""
        [[ -n "$COMMENT" ]] && DATA="$DATA, \"comment\": \"$COMMENT\""
        DATA="$DATA}"

        print_info "Creating schedule '$NAME'..."
        RESPONSE=$(fmg_add "$URL" "$DATA" "$SESSION")
        fmg_is_success "$RESPONSE" && print_success "Schedule '$NAME' created!" || print_error "$(fmg_get_error "$RESPONSE")"
        ;;

    read)
        [[ -n "$NAME" ]] && URL="$URL/$NAME"
        print_info "Retrieving schedules..."
        RESPONSE=$(fmg_get "$URL" '{"fields": ["name", "start", "end", "comment"]}' "$SESSION")

        if fmg_is_success "$RESPONSE"; then
            echo ""
            printf "%-25s %-20s %-20s %s\n" "NAME" "START" "END" "COMMENT"
            printf "%s\n" "----------------------------------------------------------------------"
            fmg_get_data "$RESPONSE" | jq -r '
                (if type == "array" then . else [.] end) |
                .[] |
                [.name // "N/A", .start // "-", .end // "-", .comment // ""] |
                @tsv
            ' | while IFS=$'\t' read -r name start end comment; do
                printf "%-25s %-20s %-20s %s\n" "$name" "$start" "$end" "$comment"
            done
        else
            print_error "$(fmg_get_error "$RESPONSE")"
        fi
        ;;

    update)
        [[ -z "$NAME" ]] && { print_error "Name required"; exit 1; }

        DATA="{"
        FIRST=true
        if [[ -n "$START" ]]; then DATA="$DATA\"start\": \"$START\""; FIRST=false; fi
        if [[ -n "$END" ]]; then
            [[ "$FIRST" == false ]] && DATA="$DATA, "
            DATA="$DATA\"end\": \"$END\""
            FIRST=false
        fi
        if [[ -n "$COMMENT" ]]; then
            [[ "$FIRST" == false ]] && DATA="$DATA, "
            DATA="$DATA\"comment\": \"$COMMENT\""
        fi
        DATA="$DATA}"

        print_info "Updating schedule '$NAME'..."
        RESPONSE=$(fmg_update "$URL/$NAME" "$DATA" "$SESSION")
        fmg_is_success "$RESPONSE" && print_success "Schedule updated!" || print_error "$(fmg_get_error "$RESPONSE")"
        ;;

    delete)
        [[ -z "$NAME" ]] && { print_error "Name required"; exit 1; }
        print_info "Deleting schedule '$NAME'..."
        RESPONSE=$(fmg_delete "$URL/$NAME" "$SESSION")
        fmg_is_success "$RESPONSE" && print_success "Schedule deleted!" || print_error "$(fmg_get_error "$RESPONSE")"
        ;;

    *)
        print_error "Invalid action. Use: create, read, update, delete"
        exit 1
        ;;
esac
