#!/bin/bash

merge_associative_arrays() {
    local -n result=$1  # Reference the output array by name
    shift  # Remove the first argument (result array name) from the list

    for array_name in "$@"; do
        # Use indirect expansion to access the associative array
        eval "declare -n current_array=$array_name"
        
        for key in "${!current_array[@]}"; do
            result["$key"]="${current_array["$key"]}"
        done
    done
}

print_associative_array() {
    local -n arr=$1  # Use nameref to reference the passed array by name
    for key in "${!arr[@]}"; do
        echo "$key => ${arr[$key]}"
    done
}

is_associative_array() {
    local var_name="$1"
    declare -p "$var_name" 2>/dev/null | grep -q 'declare -A'
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