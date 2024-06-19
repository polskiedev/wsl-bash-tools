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

# Function to check if a string is snake_case
is_snake_case() {
    [[ "$1" =~ ^[a-z0-9_]+$ ]]
}

# Function to check if a string is camelCase
is_camel_case() {
    [[ "$1" =~ ^[a-z]+([A-Z][a-z0-9]+)*$ ]]
}

to_lower_snake_case() {
    #Good for creating slugs
    local str="$1"
    # Replace spaces with underscores
    str="${str// /_}"
    # Replace uppercase letters with underscore followed by lowercase letter
    str="$(echo "$str" | sed -r 's/([A-Z])/_\L\1/g')"
    # Remove leading underscore if it exists
    str="${str#_}"
    # Convert to lowercase
    # str="${str,,}"
    echo "$str"
}

to_lower_camel_case() {
    local input=$1
    local camel_case=$(to_camel_case "$input")
    echo "${camel_case,}"  # Convert first letter to lowercase
}

# Function to convert underscore_case to camelCase
to_camel_case() {
    local input=$1
    local result=""

    while IFS="_" read -r f1 f2; do
        if [ -z "$result" ]; then
            result="$f1"
        else
            result="${result}$(tr '[:lower:]' '[:upper:]' <<< ${f1:0:1})${f1:1}"
        fi
        if [ -n "$f2" ]; then
            result="${result}$(tr '[:lower:]' '[:upper:]' <<< ${f2:0:1})${f2:1}"
        fi
    done <<< "$input"

    echo "$result"
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

highlight_string() {
    local substring="$1"
    local text="$2"
    local style="${3:-red}"
    local branch
    # ANSI escape codes
    local bold_yellow="\033[1;33m"     # ANSI escape code for bold yellow
    local bold_green="\033[1;32m"      # ANSI escape code for bold green
    local bold_red="\033[1;31m"        # ANSI escape code for bold red
    local bold_white="\033[1;37m"   
    local reset='\033[0m'

    case "$style" in
        "red") br="$bold_red";;
        "yellow") br="$bold_yellow";;
        "green") br="$bold_green";;
        "white") br="$bold_white";;
        *) br="$bold_red";;
    esac

    # Replace the substring with the highlighted version using awk
    highlighted_text=$(awk -v s="$substring" -v br="$br" -v rs="$reset" '{
        gsub(s, br s rs);
        print;
    }' <<< "$text")

    # Print the highlighted text
    echo -e "$highlighted_text"
}

slugify() {
    local input="$1"
    # Convert to lowercase
    local lower=$(echo "$input" | tr '[:upper:]' '[:lower:]')
    # Replace spaces with dashes
    local no_spaces=$(echo "$lower" | tr ' ' '-')
    # Remove all characters except lowercase letters, digits, dashes, and underscores
    local cleaned=$(echo "$no_spaces" | sed 's/[^a-z0-9_\-]//g')
    # Replace multiple dashes with a single dash
    local single_dash=$(echo "$cleaned" | tr -s '-')
    # Trim dashes from the start and end of the text
    local trimmed=$(echo "$single_dash" | sed 's/^-//;s/-$//')
    echo "$trimmed"
}

generate_hash() {
  echo $(date +%s%N | sha256sum | base64 | head -c 8)
}

humanized_datetime() {
    local current_datetime=$(date +"%Y%m%d_%I%M%p" | sed 's/AM/am/' | sed 's/PM/pm/')
    echo $current_datetime
}

rename_dt() {
    # Original filename (example)
    local original_file="$1"
    local no_hash=${2:-false}
    local temp_hash=""

    # Get the current datetime in the format YYYYMMDD_HHMMSS
    # current_datetime=$(date +"%Y%m%d_%H%M%S")
    # current_datetime=$(date +"%F %T")
    local current_datetime=$(humanized_datetime)

    # Generate a temporary hash
    if [ "$no_hash" = false ]; then
        temp_hash="_$(generate_hash)"
    fi

    # Extract the file extension
    local file_extension="${original_file##*.}"

    # Extract the filename without the extension
    local file_name="${original_file%.*}"

    # Construct the new filename
    local new_file="${file_name}_${current_datetime}${temp_hash}.${file_extension}"

    # Rename the file
    mv "$original_file" "$new_file"

    echo "File renamed from '$original_file' to '$new_file'"
}

# Todo: Validation not working AOTM, zipping a lot of sub folders
backup_dt() {
    # Check if the correct number of arguments is provided
    # if [ $# -ge 2 ]; then
    #     echo "Usage: backup_dt <source_folder> <destination_folder>"
    #     return
    # fi

    # Source folder to zip
    local source_folder="/path/to/source_folder"
    source_folder="$1"

    local source_real=$(realpath "$source_folder")

    # Destination folder for the zip file
    local destination_folder="/path/to/destination_folder"

    # Get the current datetime in the desired format (YYYYMMDD_HHMM)
    local current_datetime=$(humanized_datetime)

    # Extract the last component of the source folder path (folder or file name)
    local source_name=$(basename "$source_folder")

    # Get the parent directory of the source folder
    local parent_dir=$(dirname "$source_folder")

    local filename=$(basename --suffix=".${source_folder##*.}" "$source_folder")

    # Extract the file extension
    local file_extension="${source_folder##*.}"

    local slug=""
    if [ -n "$3" ]; then
        slug="_$(slugify "$3")"
    fi

    # Create the zip filename with datetime
    local zip_filename="backup_${source_name}_${current_datetime}${slug}.zip"

    # Check if the source path is a directory or a file
    local source_type
    if [ -d "$source_real" ]; then
        # Source is a directory
        source_type="directory"
    elif [ -f "$source_real" ]; then
        # Source is a file
        source_type="file"
        zip_filename="backup_${filename}_${current_datetime}${slug}.zip"
    else
        echo "Error: Source is neither a file nor a directory."
        return
    fi

    destination_folder="$(realpath "$parent_dir")"
    if [ "$2" != "." ]; then
        destination_folder="$(realpath "$2")"
    fi
    
    # echo "current_folder: $PWD"
    # echo "source_folder: $source_folder"
    # echo "source_name: $source_name"
    # echo "parent_dir: $parent_dir"
    # echo "source_type: $source_type"
    # echo "filename: $filename"
    # echo "file_extension: $file_extension"
    # echo "source_folder_real: $source_real"
    # echo "real_parent: $(realpath "$parent_dir")"

    # local currdir="$PWD"
    # cd "$parent_dir"
    # echo "cd '$parent_dir'"

    # Zip the source folder
    zip -r "$zip_filename" "$source_folder"
    # cd "$currdir"

    echo "'$source_folder' zipped and saved to '$destination_folder/$zip_filename'"
}