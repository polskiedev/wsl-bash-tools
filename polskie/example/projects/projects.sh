#!/bin/bash

function load_wsl_polskie_projects() {
    local writefile="$1"
    local project_folder="$HOME/polskie/projects"
    local project_list=("sample_project")

    if [ -f "$writefile" ]; then
        log_verbose "File '$writefile' already exists. Overwriting..."
        > "$writefile"  # Overwrite the existing file with an empty content
        # truncate -s 0 "$writefile"
    else
        touch "$writefile"  # Create a new blank file
    fi

    for ((i = 0; i < ${#project_list[@]}; i++)); do
        local project="${project_list[i]}"
        local project_setup_dir="$project_folder/$project"

        log_verbose "Looking for Project '$project'"

        if [ -f "$project_setup_dir/_setup.sh" ]; then
            log_verbose "Project '$project' found."
            . "$project_setup_dir/_setup.sh"
            $(_wsl_"${project}"_setup "$project_setup_dir" "$project" "$writefile")
        fi
    done
}

load_wsl_polskie_projects "$1"