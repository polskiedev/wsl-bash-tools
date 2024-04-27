#!/bin/bash

# To do
# - If search results to multiple files. Display results with index, ask what branch (by index) he needs 

function gb() {
        if [ -n "$1" ]; then
                gfp

                branchName=$1
                if [[ "$1" =~ ^[0-9]{1,6}$ ]]; then
                        branchName="NB-$1"
                        log_info "Converting '$1' to '$branchName'"
                fi
                
                output=$(git branch --list | grep -i "$branchName" | sed 's/^* //' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
                line_count=$(echo "$output" | wc -l)

                if [ "$line_count" -eq 1 ] && [[ -n "$output" ]]; then
                        log_info "Branch checkout: '$output'"
                        git checkout "$output"
                else
                        log_error "Unable to continue. There are multiple matches or no matches in branch"
                        git branch --list | grep -i "$branchName"
                fi
        else
                log_info $(git branch --show-current)
        fi
}
