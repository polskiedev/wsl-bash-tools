#!/bin/bash

log_verbose "File: cd.sh"

cd() {
    # Your custom code herea
    log_verbose "cd: Custom cd function is running..."

    if [ "$#" -eq 0 ]; then
        log_verbose "cd: No arguments passed."
    elif [ "$#" -eq 1 ]; then
        log_verbose "cd: One argument passed."
        command cd "$@"
    elif [ "$#" -eq 2 ]; then
        log_verbose "cd: Two argument passed."
        command cd "$2"
    else
        echo "More than one argument passed."
    fi
    # Call the actual 'cd' command
    #  command cd "$@"
}

