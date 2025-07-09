#!/bin/bash

COLOR_GREEN='\033[0;32m'
COLOR_YELLOW='\033[0;33m'
COLOR_RED='\033[0;31m'
COLOR_RESET='\033[0m'

PASS=true

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
        echo -e "${color_red}[ERROR]${color_reset} Invalid log type.\n\n\tReceived: $log_type\n\tValid Types: INFO, WARN, ERROR\n"
        exit 1
    fi
}

check_command() {
    local command=$1
    if command -v $command >/dev/null 2>&1; then
        decorate_log "PASS" "$command is available"
        return
    fi

    # Optionally, if n-number of args are passed, check those as well
    # if the first arg check failed. If the check passes, output
    # a recommendation to suggest using the cli tool identified in arg 1.
    # NOTE: A secondary arg pass is still a valid pass.
    for arg in "${@:2}"; do
        if command -v $arg >/dev/null 2>&1; then
            decorate_log "PASS" "$arg is available, consider using $command"
            return
        fi
    done

    # This section should only be reached if no early return is hit above
    # so we can assume a fail
    PASS=false
    decorate_log "FAIL" "$command is not available"
}

echo -e "${COLOR_YELLOW}\nRunning project generation pre-checks\n${COLOR_RESET}"

if [ {{ cookiecutter.use_opentofu }} = "yes" ]; then
    check_command tofu
else
    check_command terraform
fi

check_command terraform-docs
check_command tflint
check_command trivy

if [ {{ cookiecutter.create_git_repo }} = "yes" ]; then
    check_command git

    if [ {{ cookiecutter.use_git_hooks }} = "yes" ]; then
        check_command pre-commit
    fi
fi

if [ "$PASS" = true ]; then
    echo -e "${COLOR_GREEN}\nAll checks passed. Proceeding with project generation\n${COLOR_RESET}"
else
    echo -e "${COLOR_RED}\nOne or more checks failed. Please ensure required cli tools are installed.\n${COLOR_RESET}"
    exit 1
fi
