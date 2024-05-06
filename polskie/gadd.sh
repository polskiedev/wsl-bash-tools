#!/bin/bash

function gadd() {
    local cr
    cr=`echo $'\n.'`
    cr=${cr%.}

    if [ -n "$1" ]; then
        grep_output=$(git status --porcelain | grep -i "$1")
        result_count=$(echo "$grep_output" | wc -l)

        if [ "$result_count" -eq 1 ]; then
            file_path=$(echo "$grep_output" | awk '{print $2}')
            if [ -n "$file_path" ]; then
                msg="Found this: $cr"
                msg+="-$file_path$cr$cr"
                msg+="Do you want to add it to git? (y/n) "
                while true; do
                    read -p "$msg"  yn
                    case $yn in
                        [Yy]* ) log_info "Execute: git add $file_path"; 
                                git add "$file_path"
                                break;;
                        [Nn]* ) log_info "Add cancelled."; 
                            break;; 
                        * ) echo "Please answer yes or no.";;
                    esac
                done
            fi
        else
            log_error "Matching multiple files, cannot proceed.[$result_count]"
            git status | grep -i "$1"
        fi
    else
        # #########################################
        # Get the modified files using an array directly
        mapfile -t modified_files < <(git status --short | grep '^ M' | sed 's/^ M //')
        num_modified_files="${#modified_files[@]}"

        # Check if there are modified files
        if [ "${#modified_files[@]}" -gt 0 ]; then
            str_modified_files="$([[ "$num_modified_files" -gt 1 ]] && echo "Files found: $num_modified_files. ")"
            log_info "${str_modified_files}Processing git modified files only..."
            log_info "Execute: git status --short"
            echo "$cr"
            log_info "Please select file to add:"

            local counter=0

            for file in "${modified_files[@]}"; do
                ((counter++))
                log_info "[$counter] $file"
            done

            read -p "Input file by index: " choice

            # Validate user input
            if [[ "$choice" =~ ^[1-9][0-9]*$ && "$choice" -le "${#modified_files[@]}" ]]; then
                chosen_file="${modified_files[$(($choice - 1))]}"
                log_info "Chosen file: $chosen_file"
                # ####################
                msg="$cr$cr"
                # msg+="Chosen File: $chosen_file$cr"
                msg+="Do you want to add it to git? (y/n) "
                while true; do
                    read -p "$msg"  yn
                    case $yn in
                        [Yy]* ) log_info "Execute: git add $chosen_file"; 
                                git add "$chosen_file"
                                break;;
                        [Nn]* ) log_info "Add cancelled."; 
                            break;;
                        * ) echo "Please answer yes or no.";;
                    esac
                done
                # ####################
            else
                log_error "Invalid choice."
            fi
        else
            log_info "No files found to process."
        fi
    # #########################################
    fi
}
