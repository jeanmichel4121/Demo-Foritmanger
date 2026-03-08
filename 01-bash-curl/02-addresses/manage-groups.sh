#!/bin/bash
#
# Manage address groups in FortiManager
#
# Usage:
#   ./manage-groups.sh -a ACTION -n NAME [-m MEMBERS] [-c COMMENT] [-S SESSION]
#
# Actions: create, read, update, delete
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../config/fmg-config.sh"
source "$SCRIPT_DIR/../utils/fmg-request.sh"

ACTION=""
NAME=""
MEMBERS=""
COMMENT=""
SESSION=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -a|--action) ACTION="$2"; shift 2 ;;
        -n|--name) NAME="$2"; shift 2 ;;
        -m|--members) MEMBERS="$2"; shift 2 ;;
        -c|--comment) COMMENT="$2"; shift 2 ;;
        -S|--session) SESSION="$2"; shift 2 ;;
        -h|--help)
            echo "Usage: $0 -a ACTION -n NAME [-m MEMBERS] [-c COMMENT] [-S SESSION]"
            echo "Actions: create, read, update, delete"
            echo "Members: comma-separated list (e.g., 'addr1,addr2,addr3')"
            exit 0
            ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

URL="/pm/config/adom/$FMG_ADOM/obj/firewall/addrgrp"

case "$ACTION" in
    create)
        [[ -z "$NAME" ]] && { print_error "Name required"; exit 1; }
        [[ -z "$MEMBERS" ]] && { print_error "Members required"; exit 1; }

        # Convert comma-separated to JSON array
        MEMBERS_JSON=$(echo "$MEMBERS" | jq -R 'split(",")')

        DATA="{\"name\": \"$NAME\", \"member\": $MEMBERS_JSON"
        [[ -n "$COMMENT" ]] && DATA="$DATA, \"comment\": \"$COMMENT\""
        DATA="$DATA}"

        print_info "Creating address group '$NAME'..."
        RESPONSE=$(fmg_add "$URL" "$DATA" "$SESSION")
        fmg_is_success "$RESPONSE" && print_success "Group '$NAME' created!" || print_error "$(fmg_get_error "$RESPONSE")"
        ;;

    read)
        [[ -n "$NAME" ]] && URL="$URL/$NAME"
        print_info "Retrieving address groups..."
        RESPONSE=$(fmg_get "$URL" '{"fields": ["name", "member", "comment"]}' "$SESSION")

        if fmg_is_success "$RESPONSE"; then
            fmg_get_data "$RESPONSE" | jq -r '
                (if type == "array" then . else [.] end) |
                .[] | "\(.name): \(.member | if type == "array" then map(if type == "object" then .name else . end) | join(", ") else . end)"
            '
        else
            print_error "$(fmg_get_error "$RESPONSE")"
        fi
        ;;

    update)
        [[ -z "$NAME" ]] && { print_error "Name required"; exit 1; }

        DATA="{"
        FIRST=true
        if [[ -n "$MEMBERS" ]]; then
            MEMBERS_JSON=$(echo "$MEMBERS" | jq -R 'split(",")')
            DATA="$DATA\"member\": $MEMBERS_JSON"
            FIRST=false
        fi
        if [[ -n "$COMMENT" ]]; then
            [[ "$FIRST" == false ]] && DATA="$DATA, "
            DATA="$DATA\"comment\": \"$COMMENT\""
        fi
        DATA="$DATA}"

        print_info "Updating group '$NAME'..."
        RESPONSE=$(fmg_update "$URL/$NAME" "$DATA" "$SESSION")
        fmg_is_success "$RESPONSE" && print_success "Group updated!" || print_error "$(fmg_get_error "$RESPONSE")"
        ;;

    delete)
        [[ -z "$NAME" ]] && { print_error "Name required"; exit 1; }
        print_info "Deleting group '$NAME'..."
        RESPONSE=$(fmg_delete "$URL/$NAME" "$SESSION")
        fmg_is_success "$RESPONSE" && print_success "Group deleted!" || print_error "$(fmg_get_error "$RESPONSE")"
        ;;

    *)
        print_error "Invalid action. Use: create, read, update, delete"
        exit 1
        ;;
esac
