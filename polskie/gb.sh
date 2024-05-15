#!/bin/bash

# To do
# - If search results to multiple files. Display results with index, ask what branch (by index) he needs 

function gb() {
    if [ -n "$1" ]; then
        local branchName="$1"
        local output
        local line_count
        local branches
        local index
        local file=$(gb_saved_repo_branch_file)
        local current_branch=$(git branch --show-current)

        ### Check first if we can do quick switching
        log_debug "textman_check_text \"$file\" \"$branchName\""
        textman_check_text "$file" "$branchName"

        if [ $? -eq 1 ]; then
            log_debug "'$branchName' found on '$file'"
            if ! [ "$current_branch" = "$branchName" ]; then
                log_info "Branch '$branchName' already saved in '$file'."
                log_info "Switching from branch '$current_branch' to '$branchName'"
                git checkout "$branchName"

                log_info "Updating branch..."
                gfp
                return
            else
                log_info "You are already on branch '$branchName'."
            fi
        else
            log_debug "'$branchName' not found on '$file'"
        fi

        ### Process git switching
        gfp

        if [[ "$1" =~ ^[0-9]{1,6}$ ]]; then
            branchName="$(trim_whitespace "$POLSKIE_BRANCH_PREFIX")-$1"
            log_info "Converting '$1' to '$branchName'"
        fi

        output=$(git branch -a | grep -i "$branchName" | sed 's/^* //' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
        IFS=$'\n' read -r -d '' -a branches <<< "$output"
        line_count=$(echo "$output" | wc -l)

        if [ "$line_count" -eq 1 ] && [[ -n "$output" ]]; then
            log_info "Switching to branch: '$output'"
            git checkout "$output"
            gbs
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
                    gbs
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

function gbs2() {
    if [ "$1" == "-b" ]; then
        if [ -n "$POLSKIE_SAVED_BRANCH" ]; then
            log_info "Checking out saved branch: '$POLSKIE_SAVED_BRANCH'"
            git checkout "$POLSKIE_SAVED_BRANCH"
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

function gbs() {
    local file
    local file_path
    local ext=".txt"
    local branch
    local switch_branch
    local current_branch

    if [[ -d "$HOME/$(trim_whitespace $POLSKIE_SAVED_REPOSITORY_BRANCHES_SOURCE)" ]]; then
        log_verbose "Save repository branches directory found."
    else
        currdir="$(pwd)"
        mkdir "$HOME/$(trim_whitespace $POLSKIE_SAVED_REPOSITORY_BRANCHES_SOURCE)"
        log_verbose "Folder repository branches directory created."
        cd "$currdir"
    fi

    if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
        file=$(git rev-parse --show-toplevel | xargs basename)
        file+=$ext

        log_verbose "Current directory is inside a Git repository.${file}"

        file_path="$HOME/$(trim_whitespace $POLSKIE_SAVED_REPOSITORY_BRANCHES_SOURCE)/${file}"

        if [[ -f "$file_path" ]]; then
            log_verbose "File exists: $file_path"
        else
            log_verbose "File does not exist: $file_path"
            log_verbose "Creating file: ${file}"
            touch $file_path
        fi

        branch=$(git branch --show-current)

        textman_save_text "$file_path" "$branch" --prepend
    else
        log_verbose "Current directory is not inside a Git repository."
    fi

    if [ -n "$1" ]; then
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
                            git checkout "$switch_branch"
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
        elif [ "$1" == "-l" ]; then
            current_branch=$(git branch --show-current)
            log_info "Current Branch: \"$current_branch\""
            log_info "Switched Branches List:"
            textman_show_text "$file_path"
        else
            log_info "Unknown command: $1"
        fi
    fi
}

function gb_saved_repo_branch_file() {
    local file
    local file_path
    local ext=".txt"

    if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
        file=$(git rev-parse --show-toplevel | xargs basename)
        file+=$ext

        file_path="$HOME/$(trim_whitespace $POLSKIE_SAVED_REPOSITORY_BRANCHES_SOURCE)/${file}"

        if [[ -f "$file_path" ]]; then
            echo $file_path
        fi
    fi
}

# Define the completion function
_switch_gb_autocomplete() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local file=$(gb_saved_repo_branch_file)
    local matchingStrings=()
    
    cur="${cur//nb-/NB-}"
    while IFS= read -r line; do
        # Check if the line matches the text to check
        if [[ $line == *"$cur"* ]]; then        
           matchingStrings+=("$line")
        fi
    done < "$file"

    # printf '%s\n' "${matchingStrings[@]}"

    # COMPREPLY=($(compgen -W "${matchingStrings[*]}" -- "$cur"))
    COMPREPLY=("${matchingStrings[@]}")
}

# Register the completion function
complete -F _switch_gb_autocomplete gb