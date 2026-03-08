#!/bin/bash
#
# CRUD operations for custom services in FortiManager
#
# Usage:
#   ./crud-services.sh -a ACTION -n NAME [OPTIONS]
#
# Actions: create, read, update, delete
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../config/fmg-config.sh"
source "$SCRIPT_DIR/../utils/fmg-request.sh"

ACTION=""
NAME=""
TCP_PORT=""
UDP_PORT=""
PROTOCOL="TCP/UDP/SCTP"
COMMENT=""
SESSION=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -a|--action) ACTION="$2"; shift 2 ;;
        -n|--name) NAME="$2"; shift 2 ;;
        -t|--tcp) TCP_PORT="$2"; shift 2 ;;
        -u|--udp) UDP_PORT="$2"; shift 2 ;;
        -p|--protocol) PROTOCOL="$2"; shift 2 ;;
        -c|--comment) COMMENT="$2"; shift 2 ;;
        -S|--session) SESSION="$2"; shift 2 ;;
        -h|--help)
            echo "Usage: $0 -a ACTION -n NAME [OPTIONS]"
            echo ""
            echo "Actions: create, read, update, delete"
            echo ""
            echo "Options:"
            echo "  -t, --tcp        TCP port or range (e.g., '443', '8000-9000')"
            echo "  -u, --udp        UDP port or range"
            echo "  -p, --protocol   Protocol type (default: TCP/UDP/SCTP)"
            echo "  -c, --comment    Comment"
            exit 0
            ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

URL="/pm/config/adom/$FMG_ADOM/obj/firewall/service/custom"

case "$ACTION" in
    create)
        [[ -z "$NAME" ]] && { print_error "Name required"; exit 1; }
        [[ -z "$TCP_PORT" && -z "$UDP_PORT" ]] && { print_error "TCP or UDP port required"; exit 1; }

        DATA="{\"name\": \"$NAME\", \"protocol\": \"$PROTOCOL\""
        [[ -n "$TCP_PORT" ]] && DATA="$DATA, \"tcp-portrange\": \"$TCP_PORT\""
        [[ -n "$UDP_PORT" ]] && DATA="$DATA, \"udp-portrange\": \"$UDP_PORT\""
        [[ -n "$COMMENT" ]] && DATA="$DATA, \"comment\": \"$COMMENT\""
        DATA="$DATA}"

        print_info "Creating service '$NAME'..."
        RESPONSE=$(fmg_add "$URL" "$DATA" "$SESSION")
        fmg_is_success "$RESPONSE" && print_success "Service '$NAME' created!" || print_error "$(fmg_get_error "$RESPONSE")"
        ;;

    read)
        [[ -n "$NAME" ]] && URL="$URL/$NAME"
        print_info "Retrieving services..."
        RESPONSE=$(fmg_get "$URL" '{"fields": ["name", "tcp-portrange", "udp-portrange", "protocol", "comment"]}' "$SESSION")

        if fmg_is_success "$RESPONSE"; then
            echo ""
            printf "%-25s %-15s %-15s %s\n" "NAME" "TCP" "UDP" "COMMENT"
            printf "%s\n" "----------------------------------------------------------------------"
            fmg_get_data "$RESPONSE" | jq -r '
                (if type == "array" then . else [.] end) |
                .[] |
                [.name // "N/A", .["tcp-portrange"] // "-", .["udp-portrange"] // "-", .comment // ""] |
                @tsv
            ' | while IFS=$'\t' read -r name tcp udp comment; do
                printf "%-25s %-15s %-15s %s\n" "$name" "$tcp" "$udp" "$comment"
            done
        else
            print_error "$(fmg_get_error "$RESPONSE")"
        fi
        ;;

    update)
        [[ -z "$NAME" ]] && { print_error "Name required"; exit 1; }

        DATA="{"
        FIRST=true
        if [[ -n "$TCP_PORT" ]]; then
            DATA="$DATA\"tcp-portrange\": \"$TCP_PORT\""
            FIRST=false
        fi
        if [[ -n "$UDP_PORT" ]]; then
            [[ "$FIRST" == false ]] && DATA="$DATA, "
            DATA="$DATA\"udp-portrange\": \"$UDP_PORT\""
            FIRST=false
        fi
        if [[ -n "$COMMENT" ]]; then
            [[ "$FIRST" == false ]] && DATA="$DATA, "
            DATA="$DATA\"comment\": \"$COMMENT\""
        fi
        DATA="$DATA}"

        print_info "Updating service '$NAME'..."
        RESPONSE=$(fmg_update "$URL/$NAME" "$DATA" "$SESSION")
        fmg_is_success "$RESPONSE" && print_success "Service updated!" || print_error "$(fmg_get_error "$RESPONSE")"
        ;;

    delete)
        [[ -z "$NAME" ]] && { print_error "Name required"; exit 1; }
        print_info "Deleting service '$NAME'..."
        RESPONSE=$(fmg_delete "$URL/$NAME" "$SESSION")
        fmg_is_success "$RESPONSE" && print_success "Service deleted!" || print_error "$(fmg_get_error "$RESPONSE")"
        ;;

    *)
        print_error "Invalid action. Use: create, read, update, delete"
        exit 1
        ;;
esac
