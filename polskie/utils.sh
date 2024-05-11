#!/bin/bash
change_text_color() {
    local color="$1"
    local text="$2"
    local color_code=""

    case "$color" in
        RED) color_code="$CLR_RED" ;;
        GREEN) color_code="$CLR_GREEN" ;;
        BLUE) color_code="$CLR_BLUE" ;;
        YELLOW) color_code="$CLR_YELLOW" ;;
        *) color_code="$CLR_RESET" ;;  # Default to reset color
    esac

    echo -e "${color_code}${text}${CLR_RESET}"
}

text_success() {
    change_text_color GREEN "$@"
}

text_info() {
    change_text_color BLUE "$@"
}

text_error() {
    change_text_color RED "$@"
}

text_debug() {
    change_text_color YELLOW "$@"
}

hgrep() {
    history | grep "$1"
}

prompt_yes_no() {
    read -r -p "$1 (yes/no): " response
    case "$response" in
        [yY][eE][sS]|[yY]) return 0 ;;
        *) return 1 ;;
    esac
}

check_file_exists() {
    if [ -f "$1" ]; then
        return 0  # File exists
    else
        return 1  # File does not exist
    fi
}

trim_whitespace() {
    local data="$1"
    local trimmed_data="${data#"${data%%[![:space:]]*}"}"
    trimmed_data="${trimmed_data%"${trimmed_data##*[![:space:]]}"}"
    echo "$trimmed_data"
}

to_lower_snake_case() {
    local str="$1"
    # Replace spaces with underscores
    str="${str// /_}"
    # Convert to lowercase
    str="${str,,}"
    echo "$str"
}