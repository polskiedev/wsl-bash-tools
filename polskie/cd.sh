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
        case "$1" in
            "-sp")
                log_verbose "cd: -sp. Entering override mode."
                cdp "$2"
                ;;
            "-sn")
                log_verbose "cd: -sn. Entering override mode."
                cdn "$2"
                ;;
            *)
                command cd "$@"
                ;;
        esac
        
    else
        log_verbose "More than one argument passed."
        command cd "$@"
    fi
    # Call the actual 'cd' command
    #  command cd "$@"
}

