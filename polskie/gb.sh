#!/bin/bash

# To do
# - If search results to multiple files. Display results with index, ask what branch (by index) he needs 

function gb() {
    if [ -n "$1" ]; then
        gfp

        local branchName=$1
        local output
        local line_count
        local branches
        local index

        if [[ "$1" =~ ^[0-9]{1,6}$ ]]; then
            branchName="$POLSKIE_BRANCH_PREFIX-$1"
            log_info "Converting '$1' to '$branchName'"
        fi

        output=$(git branch -a | grep -i "$branchName" | sed 's/^* //' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
        IFS=$'\n' read -r -d '' -a branches <<< "$output"
        line_count=$(echo "$output" | wc -l)

        if [ "$line_count" -eq 1 ] && [[ -n "$output" ]]; then
            log_info "Branch checkout: '$output'"
            git checkout "$output"
            gbs2
            return
        elif [ "${#branches[@]}" -eq 0 ]; then
            log_error "No branches found matching '$branchName'."
            return
        fi

        index=1
        for branch in "${branches[@]}"; do
            log_info "[$index] $branch"
            ((index++))
        done

        while true; do
            read -p "Choose an index (0 to exit): " choice

            if [[ "$choice" =~ ^[0-9]+$ ]]; then
                if (( choice >= 1 )) && (( choice <= ${#branches[@]} )); then
                    log_info "Switching to branch: ${branches[choice-1]}"
                    git checkout "${branches[choice-1]}"
                    gbs2
                    break
                elif (( choice == 0 )); then
                    log_info "Exiting."
                    break
                else
                    log_error "Invalid index. Please choose again."
                fi
            else
                log_error "Invalid input. Please enter a number."
            fi
        done
    else
        log_info $(git branch --show-current)
    fi
}

function gbs() {
    gbs2

    if [ "$1" == "-b" ]; then
        if [ -n "$POLSKIE_SAVED_BRANCH" ]; then
            log_info "Checking out saved branch: '$POLSKIE_SAVED_BRANCH'"
            gb "$POLSKIE_SAVED_BRANCH"
        fi
    elif [ "$1" == "-s" ]; then
        if [ -n "$POLSKIE_SAVED_BRANCH" ]; then
            log_info "Saved branch: '$POLSKIE_SAVED_BRANCH'"
        fi
    else
        log_info "Saving branch: '$(git branch --show-current)'"
        POLSKIE_SAVED_BRANCH=$(git branch --show-current)
    fi
}

function gbs2() {
    local file
    local file_path
    local ext=".txt"
    local branch
    local switch_branch

    if [[ -d "$HOME/$POLSKIE_SAVED_REPOSITORY_BRANCHES_SOURCE" ]]; then
        log_verbose "Save repository branches directory found."
    else
        currdir="$PWD"
        mkdir "$HOME/$POLSKIE_SAVED_REPOSITORY_BRANCHES_SOURCE"
        log_verbose "Folder repository branches directory created."
        cd "$currdir"
    fi

    if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
        file=$(git rev-parse --show-toplevel | xargs basename)
        file+=$ext

        log_verbose "Current directory is inside a Git repository.${file}"

        file_path="$HOME/$POLSKIE_SAVED_REPOSITORY_BRANCHES_SOURCE/${file}"

        if [[ -f "$file_path" ]]; then
            log_verbose "File exists: $file_path"
        else
            log_verbose "File does not exist: $file_path"
            log_verbose "Creating file: ${file}"
            touch $file_path
        fi

        branch=$(git branch --show-current)

        textman_save_text "$file_path" "$branch"
    else
        log_verbose "Current directory is not inside a Git repository."
    fi

    if [ "$1" == "-s" ]; then
        textman_show_text "$file_path"
        switch_branch=$(textman_extract_text "$file_path")

        if [ -n "$switch_branch" ]; then
            while true; do
                local choice
                read -p "Do you want to switch to branch \"$switch_branch\"? (y/n) " choice
                case "$choice" in
                    [Yy]|[Yy][Ee][Ss])
                        log_info "Switching to branch: \"$switch_branch\""
                        # To do: Task
                        break
                        ;;
                    [Nn]|[Nn][Oo])
                        log_info "No problem!"
                        break
                        ;;
                    *)
                        log_info "Please enter yes or no."
                        ;;
                esac
            done
        else
            log_info "Not interested? Bye!"
        fi
    fi
}