log_success() {
    echo -e "${CLR_GREEN}[ERROR]${CLR_RESET} $@" >&2
}

log_info() {
    echo -e "${CLR_BLUE}[INFO]${CLR_RESET} $@"
}

log_error() {
    echo -e "${CLR_RED}[ERROR]${CLR_RESET} $@" >&2
}

log_debug() {
    
    if [ $(trim_whitespace "$DEBUG") = "true" ]; then
        echo -e "${CLR_YELLOW}[DEBUG]${CLR_RESET} $@" >&2
    fi
}

log_verbose() {
    if [ $(trim_whitespace "$SHOW_POLSKIE_VERBOSE_LOGS") = "true" ]; then
        echo -e "${CLR_YELLOW}[VERBOSE]${CLR_RESET} $@" >&2
    fi
}