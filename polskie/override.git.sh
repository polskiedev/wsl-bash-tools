#!/bin/bash
log_verbose "File: override.git.sh"

# Override git command to log successful checkouts
override_git() {
    if [[ "$1" == "checkout" ]]; then
        # Capture the branch name
        branch="$2"
        
        # Call the actual git checkout command
        command git "$@"
        
        # Check if the git checkout was successful
        if [ $? -eq 0 ]; then
            # echo "$(date): Checked out to $branch" >> ~/git_checkout_log.txt
            if [ $? -eq 1 ]; then
                gbs
            fi
        fi
    elif [[ "$1" == "test" ]]; then
        log_info "This is a test run."
    else
        # Call the actual git command for other subcommands
        command git "$@"
    fi
}
