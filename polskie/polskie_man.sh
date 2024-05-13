#!/bin/bash

polskie_man_write() {
    local docs=("alias.sh" "utils.sh" "logs.sh" "textman.sh" "greset.sh" "gb.sh" "gadd.sh" "gcommit.sh" "gmerge.sh")
    local docFile="$1"
    if [ -f $docFile ]; then
        for ((i = 0; i < ${#docs[@]}; i++)); do
            echo "$HOME/polskie/docs/${docs[i]}.txt" >> "$docFile"
        done
    fi
}

polskie_man() {
    echo "polskie_man()"
    if [ -f $writefiledocs ]; then
        while IFS= read -r file; do
            if [ -f "$file" ]; then
                local texts=($(<"$file"))
                for text in "${texts[@]}"; do
                    echo "$text"
                done
            fi
        done < "$writefiledocs"
    fi
}