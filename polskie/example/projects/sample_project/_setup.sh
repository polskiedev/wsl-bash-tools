#!/bin/bash

log_verbose "Project 'sample_project' loading..."

function _wsl_sample_project_setup() {
    local project_scripts=("ntest.sh" "helloworld.sh")
    local project_setup_dir="$1"
    local project_name="$2"
    local writefile="$3"
    
    log_verbose "Project '$project_name' setting up..."

    for ((i = 0; i < ${#project_scripts[@]}; i++)); do
        local item
        item="$project_setup_dir/${project_scripts[i]}"
        log_verbose "Adding file '$item' to $writefile"
        echo "$item" >> "$writefile"
    done
}