#!/usr/bin/env bash
# ── Dynamic Slide Rendering Engine ─────────────────────────
# Responsive presentation slides for tmux project
# Automatically adapts to terminal dimensions on render
# and re-renders on terminal resize (SIGWINCH)

# ── Gruvbox Color Palette ──────────────────────────────────
C_RESET=$'\033[0m'
C_BOX=$'\033[38;5;223m'
C_TITLE_BD=$'\033[38;5;214m'
C_TITLE_TX=$'\033[1;38;5;214m'
C_SECT_BD=$'\033[38;5;142m'
C_TEXT=$'\033[38;5;223m'
C_HI=$'\033[38;5;208m'
C_KEY=$'\033[38;5;214m'
C_CODE=$'\033[38;5;109m'
C_GREEN=$'\033[38;5;142m'

# ── Internal State ─────────────────────────────────────────
_SL=()          # Slide output lines
_TW=0           # Terminal width
_TH=0           # Terminal height
_BW=0           # Box width (outer)
_IW=0           # Inner width (between │ borders)
_TBW=0          # Title box inner width
_TOFF=0         # Title box left offset
_TRPAD=0        # Title box right padding
_SBW=0          # Section box inner width
_SOFF=0         # Section box left offset
_SRPAD=0        # Section box right padding

# ── Helpers ────────────────────────────────────────────────
# Repeat a character N times (supports UTF-8)
_rep() {
    local c="$1" n="$2" s
    (( n <= 0 )) && return
    printf -v s '%*s' "$n" ''
    printf '%s' "${s// /$c}"
}

# Calculate visible length of a string (strips ANSI escape codes)
_vlen() {
    local clean
    clean=$(printf '%s' "$1" | sed -r 's/\x1b\[[0-9;]*m//g')
    echo "${#clean}"
}

# ── Dimension Calculations ─────────────────────────────────
_calc() {
    _TW=$(tput cols 2>/dev/null || echo 80)
    _TH=$(tput lines 2>/dev/null || echo 24)

    # Box width: responsive with margins
    _BW=$((_TW - 8))
    (( _BW < 40 )) && _BW=40
    (( _BW > 100 )) && _BW=100
    _IW=$((_BW - 2))

    # Title box: ~68% of inner width
    _TBW=$((_IW * 68 / 100))
    (( _TBW % 2 != 0 )) && ((_TBW++))
    _TOFF=$(( (_IW - _TBW - 2) / 2 ))
    _TRPAD=$(( _IW - _TOFF - _TBW - 2 ))

    # Section box: ~85% of inner width
    _SBW=$((_IW * 85 / 100))
    _SOFF=$(( (_IW - _SBW - 2) / 2 ))
    _SRPAD=$(( _IW - _SOFF - _SBW - 2 ))
}

# ── Core Line Builder ─────────────────────────────────────
# Wraps content in outer box borders │...│, padded to _IW visible chars
_bline() {
    local content="$1"
    local vl
    vl=$(_vlen "$content")
    local pad=$((_IW - vl))
    (( pad < 0 )) && pad=0
    _SL+=("${C_BOX}│${C_RESET}${content}$(printf '%*s' "$pad" '')${C_BOX}│${C_RESET}")
}

# ── Public API: Structure ──────────────────────────────────

# Reset slide content and recalculate dimensions
slide_init() {
    _SL=()
    _calc
}

# Top border of outer box
slide_top() {
    _SL+=("${C_BOX}┌$(_rep '─' "$_IW")┐${C_RESET}")
}

# Bottom border of outer box
slide_bottom() {
    _SL+=("${C_BOX}└$(_rep '─' "$_IW")┘${C_RESET}")
}

# Empty line inside the box
slide_blank() {
    _bline ""
}

# ── Public API: Title Box ──────────────────────────────────

# Open title box (top border)
slide_title_open() {
    local lp rp bd
    lp=$(_rep ' ' "$_TOFF")
    rp=$(_rep ' ' "$_TRPAD")
    bd=$(_rep '─' "$_TBW")
    _bline "${lp}${C_TITLE_BD}┌${bd}┐${C_BOX}${rp}"
}

# Plain text line inside title box (centered, single color)
slide_title_text() {
    local text="$1" color="${2:-$C_TITLE_TX}"
    local tl=${#text}
    local pl=$(( (_TBW - tl) / 2 ))
    local pr=$(( _TBW - tl - pl ))
    local lp rp
    lp=$(_rep ' ' "$_TOFF")
    rp=$(_rep ' ' "$_TRPAD")
    _bline "${lp}${C_TITLE_BD}│$(printf '%*s' "$pl" '')${color}${text}${C_RESET}$(printf '%*s' "$pr" '')${C_TITLE_BD}│${C_BOX}${rp}"
}

# Rich text line inside title box (centered, may contain ANSI codes)
slide_title_rich() {
    local text="$1"
    local tl
    tl=$(_vlen "$text")
    local pl=$(( (_TBW - tl) / 2 ))
    local pr=$(( _TBW - tl - pl ))
    local lp rp
    lp=$(_rep ' ' "$_TOFF")
    rp=$(_rep ' ' "$_TRPAD")
    _bline "${lp}${C_TITLE_BD}│$(printf '%*s' "$pl" '')${text}${C_RESET}$(printf '%*s' "$pr" '')${C_TITLE_BD}│${C_BOX}${rp}"
}

# Empty line inside title box
slide_title_blank() {
    local lp rp
    lp=$(_rep ' ' "$_TOFF")
    rp=$(_rep ' ' "$_TRPAD")
    _bline "${lp}${C_TITLE_BD}│$(printf '%*s' "$_TBW" '')│${C_BOX}${rp}"
}

# Close title box (bottom border)
slide_title_close() {
    local lp rp bd
    lp=$(_rep ' ' "$_TOFF")
    rp=$(_rep ' ' "$_TRPAD")
    bd=$(_rep '─' "$_TBW")
    _bline "${lp}${C_TITLE_BD}└${bd}┘${C_BOX}${rp}"
}

# ── Public API: Section Header Box ─────────────────────────

# Section header with bordered box (centered)
slide_section() {
    local text="$1"
    local tl=${#text}
    local pl=$(( (_SBW - tl) / 2 ))
    local pr=$(( _SBW - tl - pl ))
    local lp rp bd
    lp=$(_rep ' ' "$_SOFF")
    rp=$(_rep ' ' "$_SRPAD")
    bd=$(_rep '─' "$_SBW")
    _bline "${lp}${C_SECT_BD}┌${bd}┐${C_BOX}${rp}"
    _bline "${lp}${C_SECT_BD}│${C_TEXT}$(printf '%*s' "$pl" '')${text}$(printf '%*s' "$pr" '')${C_SECT_BD}│${C_BOX}${rp}"
    _bline "${lp}${C_SECT_BD}└${bd}┘${C_BOX}${rp}"
}

# ── Public API: Content Lines ──────────────────────────────

# Text line with optional color and indent
slide_text() {
    local text="$1" color="${2:-$C_TEXT}" indent="${3:-4}"
    _bline "$(printf '%*s' "$indent" '')${color}${text}${C_RESET}"
}

# Bullet point (• prefix)
slide_bullet() {
    local text="$1" indent="${2:-4}"
    _bline "$(printf '%*s' "$indent" '')${C_HI}•${C_TEXT} ${text}${C_RESET}"
}

# Checkmark item (✓ prefix)
slide_check() {
    local text="$1" indent="${2:-4}"
    _bline "$(printf '%*s' "$indent" '')${C_HI}✓${C_TEXT} ${text}${C_RESET}"
}

# Key binding: KEY followed by DESCRIPTION
slide_key() {
    local key="$1" desc="$2" indent="${3:-6}" kw="${4:-14}"
    local kpad=$((kw - ${#key}))
    (( kpad < 1 )) && kpad=1
    _bline "$(printf '%*s' "$indent" '')${C_KEY}${key}$(printf '%*s' "$kpad" '')${C_TEXT}${desc}${C_RESET}"
}

# Code line with optional comment
slide_code() {
    local code="$1" comment="$2" indent="${3:-6}" cw="${4:-32}"
    if [ -n "$comment" ]; then
        local cpad=$((cw - ${#code}))
        (( cpad < 1 )) && cpad=1
        _bline "$(printf '%*s' "$indent" '')${C_KEY}${code}$(printf '%*s' "$cpad" '')${C_CODE}# ${comment}${C_RESET}"
    else
        _bline "$(printf '%*s' "$indent" '')${C_KEY}${code}${C_RESET}"
    fi
}

# Labeled section (colored label + text on same line)
slide_label() {
    local label="$1" text="$2" indent="${3:-4}"
    _bline "$(printf '%*s' "$indent" '')${C_HI}${label}${C_TEXT} ${text}${C_RESET}"
}

# Highlighted text (green)
slide_highlight() {
    local text="$1" indent="${2:-4}"
    _bline "$(printf '%*s' "$indent" '')${C_GREEN}${text}${C_RESET}"
}

# Accent text (blue/code color)
slide_accent() {
    local text="$1" indent="${2:-4}"
    _bline "$(printf '%*s' "$indent" '')${C_CODE}${text}${C_RESET}"
}

# Centered text within the box
slide_center() {
    local text="$1" color="${2:-$C_TEXT}"
    local tl=${#text}
    local pl=$(( (_IW - tl) / 2 ))
    (( pl < 0 )) && pl=0
    _bline "$(printf '%*s' "$pl" '')${color}${text}${C_RESET}"
}

# ── Rendering ──────────────────────────────────────────────

# Internal: clear screen and draw all lines with centering
_render() {
    clear
    local total=${#_SL[@]}

    # Vertical centering
    local vpad=$(( (_TH - total) / 2 ))
    (( vpad < 0 )) && vpad=0

    # Horizontal centering
    local hpad=$(( (_TW - _BW) / 2 ))
    (( hpad < 0 )) && hpad=0

    # Hide cursor during render
    tput civis 2>/dev/null

    for ((i=0; i<vpad; i++)); do echo; done
    for line in "${_SL[@]}"; do
        printf '%*s%s\n' "$hpad" '' "$line"
    done
}

# Render slide with automatic resize support
# Usage: slide_present build_function_name
slide_present() {
    local build_fn="$1"

    _rebuild() {
        "$build_fn"
        _render
    }

    _rebuild
    trap '_rebuild' WINCH

    # Keep window alive, re-render on resize
    while true; do
        if read -r -s -n 1 key 2>/dev/null; then
            case "$key" in
                q|Q) break ;;
            esac
        fi
    done

    # Restore cursor and drop to shell if user presses q
    tput cnorm 2>/dev/null
    PS1="" exec bash --norc --noprofile
}
