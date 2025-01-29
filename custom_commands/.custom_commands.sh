# This Bash function overrides the pip command to use uv pip when inside a virtual environment created by uv.
# It automatically detects UV environments and falls back to standard pip if uv is unavailable or the environment isn’t UV-based.
# Includes clear feedback for each operation.

# In short: Overrides 'pip' based on the virtual environment. Uses 'uv pip' if the environment was created by 'uv', otherwise uses 'pip'.
RED='\033[0;31m'
GREEN='\033[0;32m'
BOLD='\033[1m'
NC='\033[0m'

function pip() {
    if [[ -z "$VIRTUAL_ENV" ]]; then
        printf "%bNo virtual environment is activated. Running %b'pip %s'%b\n" \
               "$RED" "$BOLD" "$*" "$NC"
        command pip "$@"
        return
    fi

    local cfg="$VIRTUAL_ENV/pyvenv.cfg"
    if [[ ! -f "$cfg" ]]; then
        printf "%bpyvenv.cfg file does not exist. Running %b'pip %s'%b\n" \
               "$RED" "$BOLD" "$*" "$NC"
        command pip "$@"
        return
    fi

    if ! grep -q '^uv =' "$cfg"; then
        printf "%bRunning %b'pip %s'%b\n" \
               "$GREEN" "$BOLD" "$*" "$NC"
        command pip "$@"
        return
    fi

    if ! command -v uv >/dev/null 2>&1; then
        printf "%b'uv' command not found. Running %b'pip %s'%b\n" \
               "$RED" "$BOLD" "$*" "$NC"
        command pip "$@"
        return
    fi

    printf "%bRunning %b'uv pip %s'%b\n" \
           "$GREEN" "$BOLD" "$*" "$NC"
    uv pip "$@"
}
