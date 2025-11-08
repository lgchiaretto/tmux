#!/bin/bash
# Helper function to center content in terminal

center_content() {
    local term_height=$(tput lines)
    local term_width=$(tput cols)
    
    local -a lines=()
    while IFS= read -r line; do
        lines+=("$line")
    done
    
    local content_lines=${#lines[@]}
    
    local vertical_padding=$(( (term_height - content_lines) / 2 ))
    
    if [ $vertical_padding -lt 0 ]; then
        vertical_padding=0
    fi
    
    for ((i=0; i<vertical_padding; i++)); do
        echo
    done
    
    local max_width=0
    for line in "${lines[@]}"; do
        local clean_line=$(echo -e "$line" | sed -r 's/\x1b\[[0-9;]*m//g')
        local line_length=${#clean_line}
        if [ $line_length -gt $max_width ]; then
            max_width=$line_length
        fi
    done
    
    local horizontal_padding=$(( (term_width - max_width) / 2 ))
    
    if [ $horizontal_padding -lt 0 ]; then
        horizontal_padding=0
    fi
    
    for line in "${lines[@]}"; do
        if [ $horizontal_padding -gt 0 ]; then
            printf "%${horizontal_padding}s" ""
        fi
        echo -e "$line"
    done
}

export -f center_content
