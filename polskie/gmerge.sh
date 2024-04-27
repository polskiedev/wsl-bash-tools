#!/bin/bash

# Todo: 
# - Check first if there are modified files, do not process merging

function gmerge() {
    if [ $# -ne 2 ]; then
        log_info "Usage: gmerge <new-branch> <old-branch>"
        return 1
    fi

    local branch1="$1"
    local branch2="$2"

    if ! git rev-parse --quiet --verify "$branch1" > /dev/null; then
        log_error "New Branch '$branch1' does not exist."
        return 1
    fi

    if ! git rev-parse --quiet --verify "$branch2" > /dev/null; then
        log_error "Old Branch '$branch2' does not exist."
        return 1
    fi

    git fetch origin

    git checkout "$branch2" && git pull origin "$branch2"
    git checkout "$branch1" && git pull origin "$branch1"


    read -p "Do you want to merge from <old-branch> '$branch2' to <new-branch> '$branch1'? (yes/no): " confirm
    case "$confirm" in
        [yY]|[yY][eE][sS])
            log_info "git merge \"$branch2\""
            git merge "$branch2"
            ;;
        *)
            log_error "Merge operation canceled."
            ;;
    esac
}