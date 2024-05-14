#!/bin/bash

textman_count_text() {
    local file="$1"
    local texts=($(<"$file"))

    echo "${#texts[@]}"
}

textman_show_text() {
    local file="$1"
    local texts=($(<"$file"))
    local index=1

    for text in "${texts[@]}"; do
        echo "$index: $text"
        ((index++))
    done
}

textman_extract_text() {
    local file="$1"
    local texts=($(<"$file"))

    read -p "Choose an index: " choice
    if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 )) && (( choice <= ${#texts[@]} )); then
        echo "${texts[choice-1]}"
    else
        echo ""
    fi
}

textman_choose_text() {
    local file="$1"
    local texts=($(<"$file"))
    local index=1

    for text in "${texts[@]}"; do
        echo "$index: $text"
        ((index++))
    done

    read -p "Choose an index: " choice
    if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 )) && (( choice <= ${#texts[@]} )); then
        # log_info "You chose index $choice: ${texts[choice-1]}"
        echo "${texts[choice-1]}"
    else
        # log_info "Invalid choice."
        echo ""
    fi
}

# Function to save a text to a file if it doesn't already exist.
textman_save_text() {
    local file="$1"
    local text="$2"
    local option="$3"

    # echo "textman_save_text $file $text $option"

    if ! grep -qF "$text" "$file"; then
        if [[ "$option" == "--prepend" ]]; then
            tmpfile=$(mktemp)
            { echo "$text"; cat "$file"; } > "$tmpfile" && mv "$tmpfile" "$file"
            log_info "Text '$text' prepended to '$file'."
        else
            echo "$text" >> "$file"
            log_info "Text '$text' appended to '$file'."
        fi
    else
        log_verbose "Text '$text' already exists in '$file'."
    fi
}


textman_remove_text() {
    local file="$1"
    local text_to_remove="$2"

    if grep -qF "$text_to_remove" "$file"; then
        sed -i "/$text_to_remove/d" "$file"
        log_info "Text '$text_to_remove' removed from '$file'."
    else
        log_verbose "Text '$text_to_remove' not found in '$file'."
    fi
}

textman_check_text() {
    local file="$1"
    local text_to_check="$2"

    if grep -qwF "$text_to_check" "$file"; then
        log_verbose "Text '$text_to_check' exists in '$file'."
        return 1  # Return success code
    else
        log_verbose "Text '$text_to_check' not found in '$file'."
        return 0  # Return failure code
    fi
}

# Usage examples
# test_choose_text "list.txt"
# test_save_text "list.txt" "New text"
# test_remove_text "list.txt" "New text"