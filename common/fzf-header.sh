#!/usr/bin/env bash
# ── Dynamic FZF Header Builder ─────────────────────────────
# Generates boxed headers for fzf-tmux popups.
# Box width is determined by content length so borders always
# align correctly inside any fzf popup size.
#
# After calling fzf_header or fzf_header_2col, these variables are set:
#   FZF_HEADER_WIDTH  - total box width in columns (use for -p WIDTHx...)
#   FZF_HEADER_LINES  - number of header lines (use to calculate popup height)
#
# Usage:
#   source common/fzf-header.sh
#   header=$(fzf_header \
#     "Title text" \
#     "[Enter]     Do something" \
#     "[Tab]       Do another thing" \
#     "[Esc]       Exit")
#   ... | fzf-tmux --header="$header" -p "${FZF_HEADER_WIDTH},80%" ...
#
# For two-column layout:
#   header=$(fzf_header_2col \
#     "Left col title" "Right col title" \
#     "[K] kubeconfig" "[C] Check versions" \
#     "[U] Upgrade"    "[O] Update path" \
#     ""               "[D] Download client")
#   ... | fzf-tmux --header="$header" -p "${FZF_HEADER_WIDTH},80%" ...

# Exported variables (set after each header call — only valid if called
# outside a $() subshell; prefer fzf_header_popup_width for subshell usage)
FZF_HEADER_WIDTH=0
FZF_HEADER_LINES=0

# ── Calculate popup width from a pre-generated header ──────
# The first line of any generated header is the top border (┌───┐ or ┌───┬───┐).
# Its character count equals the box display width.
# Chrome accounts for fzf border (2), padding (2), selection/header indent (2),
# plus 2 safety margin = 8 total.
# ANSI escape codes in data are stripped before measuring visual width.
# Usage:
#   _hdr=$(fzf_header "Title" "line1" "line2")
#   _pw=$(fzf_header_popup_width "$_hdr")
#   ... | fzf-tmux --header="$_hdr" -p "${_pw},80%" ...
fzf_header_popup_width() {
    local header="$1" data="$2"
    local first_line max_w=0 line_len
    first_line=$(printf '%s\n' "$header" | head -1)
    max_w=${#first_line}
    # If data is provided, strip ANSI codes and measure visual width
    if [[ -n "$data" ]]; then
        local clean_data
        clean_data=$(printf '%s' "$data" | sed $'s/\033\\[[0-9;]*m//g')
        while IFS= read -r line; do
            line_len=${#line}
            (( line_len > max_w )) && max_w=$line_len
        done <<< "$clean_data"
    fi
    # fzf chrome: border(2) + padding(2) + indent(2) + safety(2) = 8
    local result=$(( max_w + 8 ))
    # Cap at tmux window width so popup never overflows the terminal
    local term_w
    term_w=$(tmux display-message -p '#{window_width}' 2>/dev/null) || term_w=0
    if (( term_w > 0 && result > term_w )); then
        result=$term_w
    fi
    echo "$result"
}

# ── Calculate optimal popup height ─────────────────────────
# Counts header lines + data lines + fzf chrome (border=2, input=1, info=1, margin=2).
# Usage:
#   _ph=$(fzf_header_popup_height "$_hdr" "$data_lines")
#   ... | fzf-tmux -p "${_pw},${_ph}" ...
fzf_header_popup_height() {
    local header="$1"
    local data="$2"
    local hdr_lines data_lines chrome
    hdr_lines=$(printf '%s\n' "$header" | wc -l)
    if [[ -n "$data" ]]; then
        data_lines=$(printf '%s\n' "$data" | wc -l)
    else
        data_lines=0
    fi
    chrome=6  # fzf border (2) + input line (1) + info line (1) + padding (2)
    local result=$(( hdr_lines + data_lines + chrome ))
    # Cap at tmux window height so popup never overflows the terminal
    local term_h
    term_h=$(tmux display-message -p '#{window_height}' 2>/dev/null) || term_h=0
    if (( term_h > 0 && result > term_h )); then
        result=$term_h
    fi
    echo "$result"
}

# ── Build a single-column boxed header ─────────────────────
# Args: title (first arg), then key-description lines
fzf_header() {
    local title="$1"
    shift
    local lines=("$@")
    local max_len=0

    # Find longest line
    for line in "${lines[@]}"; do
        (( ${#line} > max_len )) && max_len=${#line}
    done
    (( ${#title} > max_len )) && max_len=${#title}

    # Box inner width: sized to fit the longest content line
    # NOTE: Do NOT cap to tput cols here. The header is rendered inside
    # an fzf popup whose width differs from the terminal width.
    # Sizing by content ensures borders always align correctly.
    local box_inner=$(( max_len + 4 ))  # 2 padding each side
    (( box_inner < 20 )) && box_inner=20

    local border
    printf -v border '%*s' "$box_inner" ''
    border="${border// /─}"

    local result=""
    result+="┌${border}┐\n"

    # Title line
    if [[ -n "$title" ]]; then
        local pad=$(( box_inner - ${#title} ))
        local lp=$(( pad / 2 ))
        local rp=$(( pad - lp ))
        result+="│$(printf '%*s' "$lp" '')${title}$(printf '%*s' "$rp" '')│\n"
    else
        result+="│$(printf '%*s' "$box_inner" '')│\n"
    fi

    result+="│$(printf '%*s' "$box_inner" '')│\n"

    # Content lines
    for line in "${lines[@]}"; do
        local vl=${#line}
        local rpad=$(( box_inner - vl - 2 ))
        (( rpad < 0 )) && rpad=0
        result+="│  ${line}$(printf '%*s' "$rpad" '')│\n"
    done

    result+="│$(printf '%*s' "$box_inner" '')│\n"
    result+="└${border}┘\n"

    # Export dimensions for popup sizing
    # +2 for the │ borders on each side
    FZF_HEADER_WIDTH=$(( box_inner + 2 ))
    # lines: top + title + blank + content + blank + bottom
    FZF_HEADER_LINES=$(( ${#lines[@]} + 4 ))

    printf '%b' "$result"
}

# ── Build a two-column boxed header ────────────────────────
# Args: left_title, right_title, then pairs of "left_line" "right_line"
# Use empty string "" for blank entries in either column
fzf_header_2col() {
    local ltitle="$1" rtitle="$2"
    shift 2

    local -a left_lines=()
    local -a right_lines=()

    # Collect pairs
    while (( $# >= 2 )); do
        left_lines+=("$1")
        right_lines+=("$2")
        shift 2
    done
    # Handle odd trailing arg
    if (( $# == 1 )); then
        left_lines+=("$1")
        right_lines+=("")
    fi

    # Find max widths per column
    local lmax=0 rmax=0
    for line in "${left_lines[@]}"; do
        (( ${#line} > lmax )) && lmax=${#line}
    done
    for line in "${right_lines[@]}"; do
        (( ${#line} > rmax )) && rmax=${#line}
    done
    (( ${#ltitle} > lmax )) && lmax=${#ltitle}
    (( ${#rtitle} > rmax )) && rmax=${#rtitle}

    # Inner widths with padding (sized to content, not terminal)
    # NOTE: Do NOT cap to tput cols here. The header is rendered inside
    # an fzf popup whose width differs from the terminal width.
    # Sizing by content ensures borders always align correctly.
    local lcol=$(( lmax + 4 ))
    local rcol=$(( rmax + 4 ))

    local lborder rborder
    printf -v lborder '%*s' "$lcol" ''
    lborder="${lborder// /─}"
    printf -v rborder '%*s' "$rcol" ''
    rborder="${rborder// /─}"

    local result=""
    # Top border
    result+="┌${lborder}┬${rborder}┐\n"

    # Title row
    _2col_pad_line() {
        local text="$1" width="$2"
        local pad=$(( width - ${#text} ))
        local lp=$(( pad / 2 ))
        local rp=$(( pad - lp ))
        printf '%*s%s%*s' "$lp" '' "$text" "$rp" ''
    }

    result+="│$(_2col_pad_line "$ltitle" "$lcol")│$(_2col_pad_line "$rtitle" "$rcol")│\n"
    result+="│$(printf '%*s' "$lcol" '')│$(printf '%*s' "$rcol" '')│\n"

    # Content rows
    local count=${#left_lines[@]}
    for ((i=0; i<count; i++)); do
        local lt="${left_lines[$i]}"
        local rt="${right_lines[$i]}"
        local lrpad=$(( lcol - ${#lt} - 2 ))
        local rrpad=$(( rcol - ${#rt} - 2 ))
        (( lrpad < 0 )) && lrpad=0
        (( rrpad < 0 )) && rrpad=0

        if [[ -n "$lt" || -n "$rt" ]]; then
            result+="│  ${lt}$(printf '%*s' "$lrpad" '')│  ${rt}$(printf '%*s' "$rrpad" '')│\n"
        else
            result+="│$(printf '%*s' "$lcol" '')│$(printf '%*s' "$rcol" '')│\n"
        fi
    done

    result+="│$(printf '%*s' "$lcol" '')│$(printf '%*s' "$rcol" '')│\n"
    # Bottom border
    result+="└${lborder}┴${rborder}┘\n"

    # Export dimensions for popup sizing
    # +3 for the 3 │ borders (left, middle, right)
    FZF_HEADER_WIDTH=$(( lcol + rcol + 3 ))
    # lines: top + title + blank + content + blank + bottom
    FZF_HEADER_LINES=$(( count + 4 ))

    printf '%b' "$result"
}
