#!/bin/bash

# Color definitions
COLOR_GREEN='\033[0;32m'
COLOR_YELLOW='\033[0;33m'
COLOR_RED='\033[0;31m'
COLOR_RESET='\033[0m'

# Decorated logging function
decorate_log() {
    local log_info="${COLOR_GREEN}[INFO]${COLOR_RESET}"
    local log_pass="${COLOR_GREEN}[PASS]${COLOR_RESET}"
    local log_warning="${COLOR_YELLOW}[WARNING]${COLOR_RESET}"
    local log_error="${COLOR_RED}[ERROR]${COLOR_RESET}"
    local log_fail="${COLOR_RED}[FAIL]${COLOR_RESET}"

    local log_type=$1
    local log_message=$2

    if [ $log_type = "INFO" ]; then
        echo -e "${log_info} ${log_message}"
    elif [ $log_type = "PASS" ]; then
        echo -e "${log_pass} ${log_message}"
    elif [ $log_type = "WARN" ]; then
        echo -e "${log_warning} ${log_message}"
    elif [ $log_type = "ERROR" ]; then
        echo -e "${log_error} ${log_message}"
    elif [ $log_type = "FAIL" ]; then
        echo -e "${log_fail} ${log_message}"
    else
        echo -e "${COLOR_RED}[ERROR]${COLOR_RESET} Invalid log type.\n\n\tReceived: $log_type\n\tValid Types: INFO, PASS, WARN, ERROR, FAIL\n"
        exit 1
    fi
}

# Check if a command is available
check_command() {
    local command=$1
    if command -v $command >/dev/null 2>&1; then
        decorate_log "PASS" "$command is available"
        return 0
    fi

    # Optionally, if n-number of args are passed, check those as well
    # if the first arg check failed. If the check passes, output
    # a recommendation to suggest using the cli tool identified in arg 1.
    # NOTE: A secondary arg pass is still a valid pass.
    for arg in "${@:2}"; do
        if command -v $arg >/dev/null 2>&1; then
            decorate_log "PASS" "$arg is available, consider using $command"
            return 0
        fi
    done

    # This section should only be reached if no early return is hit above
    # so we can assume a fail
    decorate_log "FAIL" "$command is not available"
    return 1
}

PASS=true

# Override check_command to track overall pass/fail status
check_command_with_tracking() {
    if ! check_command "$@"; then
        PASS=false
    fi
}

echo ""
decorate_log "INFO" "Running project generation pre-checks"
echo ""

# Validate project name
PROJECT_NAME="{{ cookiecutter.project_name }}"
if [ -z "$PROJECT_NAME" ] || [ "$PROJECT_NAME" = "" ]; then
    decorate_log "FAIL" "project_name cannot be empty"
    exit 1
fi

check_command_with_tracking git
check_command_with_tracking mise

if [ "$PASS" = true ]; then
    echo ""
    decorate_log "PASS" "All checks passed. Proceeding with project generation"
    echo ""
else
    echo ""
    decorate_log "FAIL" "One or more checks failed. Please ensure required cli tools are installed."
    echo ""
    exit 1
fi
