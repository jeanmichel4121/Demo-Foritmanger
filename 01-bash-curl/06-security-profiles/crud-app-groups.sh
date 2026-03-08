#!/bin/bash
#
# CRUD operations for Application Groups in FortiManager
#
# Usage:
#   ./crud-app-groups.sh -a ACTION -n NAME [OPTIONS]
#
# Actions: create, read, update, delete
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../config/fmg-config.sh"
source "$SCRIPT_DIR/../utils/fmg-request.sh"

ACTION=""
NAME=""
APPLICATIONS=""
COMMENT=""
SESSION=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -a|--action) ACTION="$2"; shift 2 ;;
        -n|--name) NAME="$2"; shift 2 ;;
        --apps) APPLICATIONS="$2"; shift 2 ;;
        -c|--comment) COMMENT="$2"; shift 2 ;;
        -S|--session) SESSION="$2"; shift 2 ;;
        -h|--help)
            echo "Usage: $0 -a ACTION -n NAME [OPTIONS]"
            echo ""
            echo "Actions: create, read, update, delete"
            echo ""
            echo "Options:"
            echo "  --apps        Comma-separated application IDs or names"
            echo "  -c, --comment Comment"
            exit 0
            ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

URL="/pm/config/adom/$FMG_ADOM/obj/application/group"

case "$ACTION" in
    create)
        [[ -z "$NAME" ]] && { print_error "Name required"; exit 1; }

        DATA="{\"name\": \"$NAME\""
        if [[ -n "$APPLICATIONS" ]]; then
            APPS_JSON=$(echo "$APPLICATIONS" | jq -R 'split(",")')
            DATA="$DATA, \"application\": $APPS_JSON"
        fi
        [[ -n "$COMMENT" ]] && DATA="$DATA, \"comment\": \"$COMMENT\""
        DATA="$DATA}"

        print_info "Creating application group '$NAME'..."
        RESPONSE=$(fmg_add "$URL" "$DATA" "$SESSION")
        fmg_is_success "$RESPONSE" && print_success "App group '$NAME' created!" || print_error "$(fmg_get_error "$RESPONSE")"
        ;;

    read)
        [[ -n "$NAME" ]] && URL="$URL/$NAME"
        print_info "Retrieving application groups..."
        RESPONSE=$(fmg_get "$URL" '{"fields": ["name", "application", "comment"]}' "$SESSION")

        if fmg_is_success "$RESPONSE"; then
            echo ""
            fmg_get_data "$RESPONSE" | jq -r '
                (if type == "array" then . else [.] end) |
                .[] |
                "Name: \(.name)\n  Applications: \(.application // [] | join(", "))\n  Comment: \(.comment // "")\n"
            '
        else
            print_error "$(fmg_get_error "$RESPONSE")"
        fi
        ;;

    update)
        [[ -z "$NAME" ]] && { print_error "Name required"; exit 1; }

        DATA="{"
        FIRST=true
        if [[ -n "$APPLICATIONS" ]]; then
            APPS_JSON=$(echo "$APPLICATIONS" | jq -R 'split(",")')
            DATA="$DATA\"application\": $APPS_JSON"
            FIRST=false
        fi
        if [[ -n "$COMMENT" ]]; then
            [[ "$FIRST" == false ]] && DATA="$DATA, "
            DATA="$DATA\"comment\": \"$COMMENT\""
        fi
        DATA="$DATA}"

        print_info "Updating app group '$NAME'..."
        RESPONSE=$(fmg_update "$URL/$NAME" "$DATA" "$SESSION")
        fmg_is_success "$RESPONSE" && print_success "App group updated!" || print_error "$(fmg_get_error "$RESPONSE")"
        ;;

    delete)
        [[ -z "$NAME" ]] && { print_error "Name required"; exit 1; }
        print_info "Deleting app group '$NAME'..."
        RESPONSE=$(fmg_delete "$URL/$NAME" "$SESSION")
        fmg_is_success "$RESPONSE" && print_success "App group deleted!" || print_error "$(fmg_get_error "$RESPONSE")"
        ;;

    *)
        print_error "Invalid action. Use: create, read, update, delete"
        exit 1
        ;;
esac
