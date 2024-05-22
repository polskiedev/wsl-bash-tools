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

reverse_array() {
    local original_array=("$@")
    local reversed_string=""
    local i

    for (( i=${#original_array[@]}-1; i>=0; i-- )); do
        reversed_string+="${original_array[i]}|"
    done

    # Remove the trailing '|'
    reversed_string="${reversed_string%|}"
    echo "$reversed_string"

    # # Example usage
    # original_array=("one" "two" "three" "four" "five")
    # reversed_string=$(reverse_array "${original_array[@]}")
    # IFS='|' read -r -a reversed_array <<< "$reversed_string"

    # echo "Original array: ${original_array[@]}"
    # echo "Reversed array: ${reversed_array[@]}"
}

highlight_string() {
    local substring="$1"
    local text="$2"

    # ANSI escape codes for bold and red text
    local bold_red='\033[1;31m'
    local reset='\033[0m'

    # Replace the substring with the highlighted version using awk
    highlighted_text=$(awk -v s="$substring" -v br="$bold_red" -v rs="$reset" '{
        gsub(s, br s rs);
        print;
    }' <<< "$text")

    # Print the highlighted text
    echo -e "$highlighted_text"
}