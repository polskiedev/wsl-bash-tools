#!/bin/bash

function greset() {
        grep_output=$(git status --porcelain | grep -i "$1")
        result_count=$(echo "$grep_output" | wc -l)

        if [ "$result_count" -eq 1 ]; then
                file_path=$(echo "$grep_output" | awk '{print $2}')
                if [ -n "$file_path" ]; then
                        log_info "Reverting $1... from $file_path"
                        log_info "git checkout HEAD '$file_path'"
                        git checkout HEAD "$file_path"
                else
                        echo "Something went wrong..."
                fi
        else
                log_error "Matching '$result_count' for '$1', cannot proceed."

        fi
}
