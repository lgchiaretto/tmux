#!/bin/bash
#
# build-static-tmux.sh - Build a fully static tmux binary for Linux
#
# This script compiles musl libc, libevent, ncurses, and tmux from source
# to produce a portable static binary that runs on various Linux distributions.
#
# Usage:
#   ./build-static-tmux.sh [-h] [-c] [-d] [-v VERSION]
#
# Options:
#   -h  Show help
#   -c  Compress binary with UPX
#   -d  Dump log on error
#   -v  Specify tmux version to build (default: 3.6)
#

set -e

# ANSI Color Codes
readonly RED="\033[0;31m"
readonly GREEN="\033[0;32m"
readonly BLUE="\033[0;34m"
readonly YELLOW="\033[0;33m"
readonly COLOR_END="\033[0m"

# Program basename
readonly PGM="${0##*/}"

# Script version
readonly SCRIPT_VERSION="1.0.0"

# How many lines of the error log should be displayed
readonly LOG_LINES=50

# OS and processor architecture detection
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
case "$(uname -m)" in
    "aarch64")
        ARCH="arm64"
        ;;
    "x86_64")
        ARCH="amd64"
        ;;
    *)
        ARCH=$(uname -m)
        ;;
esac

######################################
###### BEGIN VERSION DEFINITION ######
######################################
TMUX_VERSION="${TMUX_VERSION:-3.6}"
MUSL_VERSION="${MUSL_VERSION:-1.2.5}"
NCURSES_VERSION="${NCURSES_VERSION:-6.5}"
LIBEVENT_VERSION="${LIBEVENT_VERSION:-2.1.12}"
UPX_VERSION="${UPX_VERSION:-5.0.2}"
######################################
####### END VERSION DEFINITION #######
######################################

# Build directories
TMUX_STATIC_HOME="${TMUX_STATIC_HOME:-/tmp/tmux-static}"
LOG_DIR="${TMUX_STATIC_HOME}/log"

# Output binary name
TMUX_BIN="tmux.${OS}-${ARCH}"

# Download URLs
TMUX_ARCHIVE="tmux-${TMUX_VERSION}.tar.gz"
TMUX_URL="https://github.com/tmux/tmux/releases/download/${TMUX_VERSION}"

MUSL_ARCHIVE="musl-${MUSL_VERSION}.tar.gz"
MUSL_URL="https://musl.libc.org/releases/"

NCURSES_ARCHIVE="ncurses-${NCURSES_VERSION}.tar.gz"
NCURSES_URL="https://ftp.gnu.org/gnu/ncurses"

LIBEVENT_ARCHIVE="libevent-${LIBEVENT_VERSION}-stable.tar.gz"
LIBEVENT_URL="https://github.com/libevent/libevent/releases/download/release-${LIBEVENT_VERSION}-stable"

UPX_ARCHIVE="upx-${UPX_VERSION}-${ARCH}_${OS}.tar.xz"
UPX_URL="https://github.com/upx/upx/releases/download/v${UPX_VERSION}"

# Default options
USE_UPX="${USE_UPX:-0}"
DUMP_LOG_ON_ERROR="${DUMP_LOG_ON_ERROR:-0}"

#
# Print usage message
#
usage() {
    cat << EOF
NAME
    ${PGM} - build a static tmux release

SYNOPSIS
    ${PGM} [-h] [-c] [-d] [-v VERSION]

DESCRIPTION
    Build a fully static tmux binary using musl libc.

OPTIONS
    -h          Show this help message
    -c          Compress the binary with UPX
    -d          Dump log on error (show last ${LOG_LINES} lines)
    -v VERSION  Specify tmux version to build (default: ${TMUX_VERSION})

ENVIRONMENT VARIABLES
    USE_UPX             Set to "1" to compress with UPX (same as -c)
    DUMP_LOG_ON_ERROR   Set to "1" to dump logs on error (same as -d)
    TMUX_VERSION        tmux version to build
    MUSL_VERSION        musl libc version
    NCURSES_VERSION     ncurses version
    LIBEVENT_VERSION    libevent version
    TMUX_STATIC_HOME    Build directory (default: /tmp/tmux-static)

    http_proxy/https_proxy  Proxy settings for downloads

EXIT STATUS
    0   Success
    >0  Error

VERSION
    ${SCRIPT_VERSION}

EOF
}

#
# Log message with color
#
log() {
    printf "%b\n" "${BLUE}$1${COLOR_END}"
}

#
# Check the result of a command and print status
#
checkResult() {
    if [ "$1" -eq 0 ]; then
        printf "%b\n" "${GREEN}[OK]${COLOR_END}"
    else
        printf "%b\n" "${RED}[ERROR]${COLOR_END}"
        echo ""
        if [ "${DUMP_LOG_ON_ERROR}" = "0" ]; then
            echo "Check Buildlog in ${LOG_DIR}/${LOG_FILE}"
        else
            echo "Last ${LOG_LINES} lines from ${LOG_DIR}/${LOG_FILE}:"
            echo "-----------------------------------------------"
            if [ -f "${LOG_DIR}/${LOG_FILE}" ]; then
                tail -n "${LOG_LINES}" "${LOG_DIR}/${LOG_FILE}"
            else
                echo "Logfile ${LOG_DIR}/${LOG_FILE} not found!"
            fi
            echo ""
            printf "%b\n" "${RED}Build aborted${COLOR_END}"
        fi
        exit "$1"
    fi
}

#
# Check if a program exists
#
programExists() {
    LOG_FILE="dependencies.log"
    if command -v "$1" > /dev/null 2>&1; then
        return 0
    else
        echo "$1 is not available, please install and try again!" >> "${LOG_DIR}/${LOG_FILE}" 2>&1
        return 1
    fi
}

#
# Install dependencies for Fedora/RHEL
#
install_dependencies_fedora() {
    log "Checking/installing dependencies for Fedora/RHEL..."
    
    local packages="gcc make wget tar gzip xz bison"
    local missing_packages=""
    
    for pkg in $packages; do
        if ! rpm -q "$pkg" > /dev/null 2>&1; then
            missing_packages="$missing_packages $pkg"
        fi
    done
    
    if [ -n "$missing_packages" ]; then
        log "Installing missing packages:$missing_packages"
        sudo dnf install -y $missing_packages
    else
        log "All dependencies already installed"
    fi
}

#
# Create build directories
#
create_directories() {
    log "Creating build directories..."
    mkdir -p "${TMUX_STATIC_HOME}"/{src,lib,bin,include}
    mkdir -p "${LOG_DIR}"
}

#
# Clean up previous builds
#
cleanup() {
    log "Cleaning up previous builds..."
    rm -rf "${TMUX_STATIC_HOME:?}/include/"*
    rm -rf "${TMUX_STATIC_HOME:?}/lib/"*
    rm -rf "${TMUX_STATIC_HOME:?}/bin/"*
    rm -rf "${LOG_DIR:?}/"*

    rm -rf "${TMUX_STATIC_HOME:?}/src/upx-${UPX_VERSION}-${ARCH}_${OS}"
    rm -rf "${TMUX_STATIC_HOME:?}/src/musl-${MUSL_VERSION}"
    rm -rf "${TMUX_STATIC_HOME:?}/src/libevent-${LIBEVENT_VERSION}-stable"
    rm -rf "${TMUX_STATIC_HOME:?}/src/ncurses-${NCURSES_VERSION}"
    rm -rf "${TMUX_STATIC_HOME:?}/src/tmux-${TMUX_VERSION}"
}

#
# Build musl libc
#
build_musl() {
    echo ""
    echo "musl ${MUSL_VERSION}"
    echo "------------------"

    LOG_FILE="musl-${MUSL_VERSION}.log"

    cd "${TMUX_STATIC_HOME}/src" || exit 1
    
    if [ ! -f "${MUSL_ARCHIVE}" ]; then
        printf "Downloading..."
        wget --no-verbose "${MUSL_URL}/${MUSL_ARCHIVE}" > "${LOG_DIR}/${LOG_FILE}" 2>&1
        checkResult $?
    fi

    printf "Extracting...."
    tar xzf "${MUSL_ARCHIVE}"
    checkResult $?

    cd "musl-${MUSL_VERSION}" || exit 1

    printf "Configuring..."
    ./configure \
        --enable-gcc-wrapper \
        --disable-shared \
        --prefix="${TMUX_STATIC_HOME}" \
        --bindir="${TMUX_STATIC_HOME}/bin" \
        --includedir="${TMUX_STATIC_HOME}/include" \
        --libdir="${TMUX_STATIC_HOME}/lib" >> "${LOG_DIR}/${LOG_FILE}" 2>&1
    checkResult $?

    printf "Compiling....."
    make >> "${LOG_DIR}/${LOG_FILE}" 2>&1
    checkResult $?

    printf "Installing...."
    make install >> "${LOG_DIR}/${LOG_FILE}" 2>&1
    checkResult $?

    export CC="${TMUX_STATIC_HOME}/bin/musl-gcc -static"
}

#
# Build libevent
#
build_libevent() {
    echo ""
    echo "libevent ${LIBEVENT_VERSION}-stable"
    echo "------------------"

    LOG_FILE="libevent-${LIBEVENT_VERSION}-stable.log"

    cd "${TMUX_STATIC_HOME}/src" || exit 1
    
    if [ ! -f "${LIBEVENT_ARCHIVE}" ]; then
        printf "Downloading..."
        wget --no-verbose "${LIBEVENT_URL}/${LIBEVENT_ARCHIVE}" > "${LOG_DIR}/${LOG_FILE}" 2>&1
        checkResult $?
    fi

    printf "Extracting...."
    tar xzf "${LIBEVENT_ARCHIVE}"
    checkResult $?

    cd "libevent-${LIBEVENT_VERSION}-stable" || exit 1

    printf "Configuring..."
    ./configure \
        --prefix="${TMUX_STATIC_HOME}" \
        --includedir="${TMUX_STATIC_HOME}/include" \
        --libdir="${TMUX_STATIC_HOME}/lib" \
        --disable-shared \
        --disable-openssl \
        --disable-libevent-regress \
        --disable-samples \
        >> "${LOG_DIR}/${LOG_FILE}" 2>&1
    checkResult $?

    printf "Compiling....."
    make >> "${LOG_DIR}/${LOG_FILE}" 2>&1
    checkResult $?

    printf "Installing...."
    make install >> "${LOG_DIR}/${LOG_FILE}" 2>&1
    checkResult $?
}

#
# Build ncurses
#
build_ncurses() {
    echo ""
    echo "ncurses ${NCURSES_VERSION}"
    echo "------------------"

    LOG_FILE="ncurses-${NCURSES_VERSION}.log"

    cd "${TMUX_STATIC_HOME}/src" || exit 1
    
    if [ ! -f "${NCURSES_ARCHIVE}" ]; then
        printf "Downloading..."
        wget --no-verbose "${NCURSES_URL}/${NCURSES_ARCHIVE}" > "${LOG_DIR}/${LOG_FILE}" 2>&1
        checkResult $?
    fi

    printf "Extracting...."
    tar xzf "${NCURSES_ARCHIVE}"
    checkResult $?

    cd "ncurses-${NCURSES_VERSION}" || exit 1

    printf "Configuring..."
    ./configure \
        --prefix="${TMUX_STATIC_HOME}" \
        --includedir="${TMUX_STATIC_HOME}/include" \
        --libdir="${TMUX_STATIC_HOME}/lib" \
        --enable-pc-files \
        --with-pkg-config="${TMUX_STATIC_HOME}/lib/pkgconfig" \
        --with-pkg-config-libdir="${TMUX_STATIC_HOME}/lib/pkgconfig" \
        --without-ada \
        --without-cxx \
        --without-cxx-binding \
        --without-tests \
        --without-manpages \
        --without-debug \
        --disable-lib-suffixes \
        --with-ticlib \
        --with-termlib \
        --with-default-terminfo-dir=/usr/share/terminfo \
        --with-terminfo-dirs=/etc/terminfo:/lib/terminfo:/usr/share/terminfo \
        >> "${LOG_DIR}/${LOG_FILE}" 2>&1
    checkResult $?

    printf "Compiling....."
    make >> "${LOG_DIR}/${LOG_FILE}" 2>&1
    checkResult $?

    printf "Installing...."
    make install.libs >> "${LOG_DIR}/${LOG_FILE}" 2>&1
    checkResult $?
}

#
# Build tmux
#
build_tmux() {
    echo ""
    echo "tmux ${TMUX_VERSION}"
    echo "------------------"

    LOG_FILE="tmux-${TMUX_VERSION}.log"

    cd "${TMUX_STATIC_HOME}/src" || exit 1
    
    if [ ! -f "${TMUX_ARCHIVE}" ]; then
        printf "Downloading..."
        wget --no-verbose "${TMUX_URL}/${TMUX_ARCHIVE}" > "${LOG_DIR}/${LOG_FILE}" 2>&1
        checkResult $?
    fi

    printf "Extracting...."
    tar xzf "${TMUX_ARCHIVE}"
    checkResult $?

    cd "tmux-${TMUX_VERSION}" || exit 1

    printf "Configuring..."
    ./configure --prefix="${TMUX_STATIC_HOME}" \
        --enable-static \
        --includedir="${TMUX_STATIC_HOME}/include" \
        --libdir="${TMUX_STATIC_HOME}/lib" \
        CFLAGS="-I${TMUX_STATIC_HOME}/include" \
        LDFLAGS="-L${TMUX_STATIC_HOME}/lib" \
        CPPFLAGS="-I${TMUX_STATIC_HOME}/include" \
        LIBEVENT_LIBS="-L${TMUX_STATIC_HOME}/lib -levent" \
        LIBNCURSES_CFLAGS="-I${TMUX_STATIC_HOME}/include/ncurses" \
        LIBNCURSES_LIBS="-L${TMUX_STATIC_HOME}/lib -lncurses" \
        LIBTINFO_CFLAGS="-I${TMUX_STATIC_HOME}/include/ncurses" \
        LIBTINFO_LIBS="-L${TMUX_STATIC_HOME}/lib -ltinfo" >> "${LOG_DIR}/${LOG_FILE}" 2>&1
    checkResult $?

    printf "Compiling....."
    make >> "${LOG_DIR}/${LOG_FILE}" 2>&1
    checkResult $?

    printf "Installing...."
    make install >> "${LOG_DIR}/${LOG_FILE}" 2>&1
    checkResult $?
}

#
# Strip and optionally compress the binary
#
finalize_binary() {
    cd "${TMUX_STATIC_HOME}" || exit 1

    # Copy and strip binary
    cp "${TMUX_STATIC_HOME}/bin/tmux" "${TMUX_STATIC_HOME}/bin/${TMUX_BIN}"
    cp "${TMUX_STATIC_HOME}/bin/${TMUX_BIN}" "${TMUX_STATIC_HOME}/bin/${TMUX_BIN}.stripped"
    
    printf "Stripping....."
    strip "${TMUX_STATIC_HOME}/bin/${TMUX_BIN}.stripped"
    checkResult $?

    # Compress with UPX if requested
    if [ "${USE_UPX}" = "1" ]; then
        LOG_FILE="upx-${UPX_VERSION}.log"
        echo ""
        echo "Compressing binary with UPX ${UPX_VERSION}"
        echo "--------------------------------"
        
        cd "${TMUX_STATIC_HOME}/src" || exit 1
        
        if [ ! -f "${UPX_ARCHIVE}" ]; then
            printf "Downloading..."
            wget --no-verbose "${UPX_URL}/${UPX_ARCHIVE}" >> "${LOG_DIR}/${LOG_FILE}" 2>&1
            checkResult $?
        fi
        
        tar xJf "${UPX_ARCHIVE}"
        cd "upx-${UPX_VERSION}-${ARCH}_${OS}" || exit 1
        mv upx "${TMUX_STATIC_HOME}/bin/"

        cp "${TMUX_STATIC_HOME}/bin/${TMUX_BIN}.stripped" "${TMUX_STATIC_HOME}/bin/${TMUX_BIN}.upx"
        printf "Compressing..."
        "${TMUX_STATIC_HOME}/bin/upx" -q --best --ultra-brute "${TMUX_STATIC_HOME}/bin/${TMUX_BIN}.upx" >> "${LOG_DIR}/${LOG_FILE}" 2>&1
        checkResult $?
    fi

    # Compress final binaries
    echo ""
    echo "Resulting files:"
    echo "----------------"
    
    gzip -f "${TMUX_STATIC_HOME}/bin/${TMUX_BIN}"
    echo "Standard tmux binary:   ${TMUX_STATIC_HOME}/bin/${TMUX_BIN}.gz"
    
    gzip -f "${TMUX_STATIC_HOME}/bin/${TMUX_BIN}.stripped"
    echo "Stripped tmux binary:   ${TMUX_STATIC_HOME}/bin/${TMUX_BIN}.stripped.gz"

    if [ "${USE_UPX}" = "1" ]; then
        gzip -f "${TMUX_STATIC_HOME}/bin/${TMUX_BIN}.upx"
        echo "Compressed tmux binary: ${TMUX_STATIC_HOME}/bin/${TMUX_BIN}.upx.gz"
    fi
}

#
# Parse command line arguments
#
parse_args() {
    while getopts "hcdv:" option; do
        case $option in
            h)
                usage
                exit 0
                ;;
            c)
                USE_UPX=1
                ;;
            d)
                DUMP_LOG_ON_ERROR=1
                ;;
            v)
                TMUX_VERSION="$OPTARG"
                TMUX_ARCHIVE="tmux-${TMUX_VERSION}.tar.gz"
                ;;
            *)
                usage
                exit 1
                ;;
        esac
    done
}

#
# Main function
#
main() {
    parse_args "$@"

    # Clear screen if terminal is available
    if [ -t 1 ]; then
        clear 2>/dev/null || true
    fi

    log "*********************************************"
    log "** Starting to build a static tmux release **"
    log "*********************************************"
    echo ""

    echo "Current settings"
    echo "----------------"
    echo "TMUX_VERSION:      ${TMUX_VERSION}"
    echo "USE_UPX:           ${USE_UPX}"
    echo "DUMP_LOG_ON_ERROR: ${DUMP_LOG_ON_ERROR}"
    echo "BUILD_DIR:         ${TMUX_STATIC_HOME}"
    echo "OUTPUT:            ${TMUX_BIN}"
    echo ""

    # Start timer
    TIME_START=$(date +%s)

    # Setup
    create_directories
    cleanup

    # Check dependencies
    echo ""
    echo "Dependencies"
    echo "------------"
    printf "gcc..........."
    programExists "gcc"
    checkResult $?
    printf "yacc.........."
    programExists "yacc"
    checkResult $?

    # Build all components
    build_musl
    build_libevent
    build_ncurses
    build_tmux
    finalize_binary

    # Print duration
    echo ""
    echo "----------------------------------------"
    TIME_END=$(date +%s)
    TIME_DIFF=$((TIME_END - TIME_START))
    echo "Duration: $((TIME_DIFF / 3600))h $(((TIME_DIFF / 60) % 60))m $((TIME_DIFF % 60))s"
    echo ""

    log "Build completed successfully!"
}

# Run main function
main "$@"
