#!/bin/bash
#
# Install Policy Package to FortiGate devices
#
# Usage:
#   ./install-package.sh -d DEVICE [-p PACKAGE] [-v VDOM] [--preview] [-S SESSION]
#
# Options:
#   -d, --device    Device name (required)
#   -p, --package   Policy package name (default: from FMG_PKG or "default")
#   -v, --vdom      VDOM name (default: root)
#   --preview       Preview changes without installing
#   -S, --session   Session token
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../config/fmg-config.sh"
source "$SCRIPT_DIR/../utils/fmg-request.sh"

DEVICE=""
PACKAGE="${FMG_PKG:-default}"
VDOM="root"
PREVIEW=false
SESSION=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--device) DEVICE="$2"; shift 2 ;;
        -p|--package) PACKAGE="$2"; shift 2 ;;
        -v|--vdom) VDOM="$2"; shift 2 ;;
        --preview) PREVIEW=true; shift ;;
        -S|--session) SESSION="$2"; shift 2 ;;
        -h|--help)
            echo "Usage: $0 -d DEVICE [-p PACKAGE] [-v VDOM] [--preview] [-S SESSION]"
            echo ""
            echo "Options:"
            echo "  -d, --device    Device name (required)"
            echo "  -p, --package   Policy package name (default: $PACKAGE)"
            echo "  -v, --vdom      VDOM name (default: root)"
            echo "  --preview       Preview changes without installing"
            echo "  -S, --session   Session token"
            exit 0
            ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

[[ -z "$DEVICE" ]] && { print_error "Device name required (-d)"; exit 1; }

if $PREVIEW; then
    # Preview installation
    URL="/securityconsole/install/preview"
    DATA="{\"adom\": \"$FMG_ADOM\", \"device\": \"$DEVICE\", \"flags\": [\"none\"]}"

    print_info "Previewing installation for device '$DEVICE'..."

    RESPONSE=$(fmg_exec "$URL" "$DATA" "$SESSION")

    if fmg_is_success "$RESPONSE"; then
        TASK_ID=$(echo "$RESPONSE" | jq -r '.result[0].data.task // empty')
        if [[ -n "$TASK_ID" ]]; then
            print_success "Preview task started: $TASK_ID"
            echo "Check task status with: ./check-task.sh $TASK_ID"
        else
            print_success "Preview completed"
            fmg_get_data "$RESPONSE" | jq .
        fi
    else
        print_error "$(fmg_get_error "$RESPONSE")"
        exit 1
    fi
else
    # Install package
    URL="/securityconsole/install/package"
    DATA="{\"adom\": \"$FMG_ADOM\", \"pkg\": \"$PACKAGE\", \"scope\": [{\"name\": \"$DEVICE\", \"vdom\": \"$VDOM\"}]}"

    print_info "Installing package '$PACKAGE' to device '$DEVICE' (vdom: $VDOM)..."

    RESPONSE=$(fmg_exec "$URL" "$DATA" "$SESSION")

    if fmg_is_success "$RESPONSE"; then
        TASK_ID=$(echo "$RESPONSE" | jq -r '.result[0].data.task // empty')

        if [[ -n "$TASK_ID" ]]; then
            print_success "Installation task started: $TASK_ID"
            echo ""
            echo "Monitoring task progress..."
            echo ""

            # Poll task status
            while true; do
                TASK_RESPONSE=$(fmg_get "/task/task/$TASK_ID" "" "$SESSION")
                TASK_DATA=$(fmg_get_data "$TASK_RESPONSE")

                STATE=$(echo "$TASK_DATA" | jq -r '.state // 0')
                PERCENT=$(echo "$TASK_DATA" | jq -r '.percent // 0')
                NUM_DONE=$(echo "$TASK_DATA" | jq -r '.num_done // 0')
                NUM_ERR=$(echo "$TASK_DATA" | jq -r '.num_err // 0')

                printf "\r  Progress: %3d%% | Done: %d | Errors: %d | State: %d" "$PERCENT" "$NUM_DONE" "$NUM_ERR" "$STATE"

                # Check if done
                case "$STATE" in
                    4)  # Done
                        echo ""
                        if [[ "$NUM_ERR" -eq 0 ]]; then
                            print_success "Installation completed successfully!"
                        else
                            print_warning "Installation completed with $NUM_ERR error(s)"
                        fi
                        break
                        ;;
                    5|7)  # Error/Aborted
                        echo ""
                        print_error "Installation failed (state: $STATE)"
                        # Show error details
                        echo "$TASK_DATA" | jq -r '.line[]? | select(.state != 4) | "  \(.name): \(.detail)"'
                        exit 1
                        ;;
                    *)
                        sleep 3
                        ;;
                esac
            done
        else
            print_success "Installation completed"
        fi
    else
        print_error "$(fmg_get_error "$RESPONSE")"
        exit 1
    fi
fi
