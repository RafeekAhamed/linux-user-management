#!/bin/bash

set -Eeuo pipefail

REPORT_DIR="/srv/linux-user-management/reports"
REPORT_FILE="$REPORT_DIR/user_group_report.txt"
LOG_FILE="/srv/linux-user-management/logs/user_group_report.log"

log_message() {
    printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$1" |
        tee -a "$LOG_FILE"
}

handle_error() {
    local exit_code=$?
    trap - ERR
    log_message "ERROR: Script failed near line ${BASH_LINENO[0]} (exit code: $exit_code)"
    exit "$exit_code"
}

trap handle_error ERR

if [[ ! -d "$REPORT_DIR" ]]; then
    echo "ERROR: Report directory does not exist: $REPORT_DIR"
    exit 1
fi

if [[ ! -w "$REPORT_DIR" ]]; then
    echo "ERROR: Report directory is not writable: $REPORT_DIR"
    exit 1
fi

if [[ ! -f "$LOG_FILE" || ! -w "$LOG_FILE" ]]; then
    echo "ERROR: Log file does not exist or is not writable: $LOG_FILE"
    exit 1
fi

log_message "Starting Linux User & Group Management report."

if ! getent group devops >/dev/null; then
    log_message "ERROR: Required group devops was not found."
    exit 1
fi

{
    echo "========================================"
    echo "Linux User & Group Management Report"
    echo "========================================"
    echo "Generated on: $(date)"
    echo

    echo "----- Current User -----"
    whoami
    echo

    echo "----- DevOps Group -----"
    getent group devops
    echo

    for username in developer1 developer2; do
        echo "----- $username Account -----"

        if id "$username" >/dev/null 2>&1; then
            id "$username"
            getent passwd "$username"

            if id -nG "$username" | tr ' ' '\n' | grep -Fxq devops; then
                echo "DevOps membership: Confirmed"
            else
                echo "WARNING: $username is not a member of devops."
            fi
        else
            echo "WARNING: $username user not found."
        fi

        echo
    done

    echo "----- Shared Directory Permissions -----"
    ls -ld /srv/linux-user-management
    ls -ld /srv/linux-user-management/logs
    ls -ld /srv/linux-user-management/reports
    ls -ld /srv/linux-user-management/scripts
    echo

    echo "----- Log Files -----"
    ls -l /srv/linux-user-management/logs
    echo

    echo "Report generated successfully."
} > "$REPORT_FILE"

log_message "SUCCESS: Report saved to $REPORT_FILE"
