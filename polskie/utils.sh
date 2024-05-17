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
    #Good for creating slugs
    local str="$1"
    # Replace spaces with underscores
    str="${str// /_}"
    # Convert to lowercase
    str="${str,,}"
    echo "$str"
}

to_lowercase() {
    local text="$1"
    echo "$text" | tr '[:upper:]' '[:lower:]'
}

to_uppercase() {
    local text="$1"
    echo "$text" | tr '[:lower:]' '[:upper:]'
}

transform_text() {
    local text="$1"
    local option="$2"

    # Check if the option is -u for uppercase
    if [ "$option" = "-u" ]; then
        echo "$text" | tr '[:lower:]' '[:upper:]'
    else
        # Default behavior is lowercase
        echo "$text" | tr '[:upper:]' '[:lower:]'
    fi
}

capitalize_first_letter() {
    local str="$1"
    local first_letter="${str:0:1}"
    local rest="${str:1}"
    echo "${first_letter^}$rest"
}

urlencode() {
    local raw_string="$1"
    local encoded_string=""

    for (( i=0; i<${#raw_string}; i++ )); do
        local char="${raw_string:$i:1}"
        case "$char" in
            [a-zA-Z0-9.~_-]) encoded_string+="$char" ;;
            ' ') encoded_string+="%20" ;;
            *) printf -v encoded_char '%%%02X' "'$char"
               encoded_string+="$encoded_char" ;;
        esac
    done

    echo "$encoded_string"
}