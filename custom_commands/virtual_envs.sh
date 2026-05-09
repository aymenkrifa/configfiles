# virtualenv - Wrapper for virtualenv that auto-activates created environments
# uv - Wrapper for uv package manager with auto-activation for venv creation
#
# Usage:
#   virtualenv <path>              Create and activate a virtual environment
#   virtualenv <options>           Pass options directly to virtualenv
#   uv venv [path]                 Create and activate a uv venv (default: .venv)
#   uv <command> [args]            Pass any other uv command through
#
# Examples:
#   virtualenv my_env              Creates and activates 'my_env'
#   virtualenv --python=3.11 env   Creates with Python 3.11 and activates
#   uv venv                        Creates and activates .venv
#   uv venv my_project             Creates and activates my_project
#   uv pip install requests        Runs uv pip install
#
# Features:
#   - Automatically activates newly created environments
#   - Color-coded output messages for clarity
#

GREEN='\033[0;32m'
BOLD='\033[1m'
NC='\033[0m'

function virtualenv() {

    command virtualenv "$@" && {
        if [[ $1 != -* ]]; then
            source $1/bin/activate
            echo -e "\n${GREEN}${BOLD}[CustomCommands]${NC} Virtual environment has been activated."
        fi
    }
}

function uv() {
    if [[ "$1" == "--help" ]]; then
        command uv --help
        return
    fi

    if [[ $# -ge 1 && $1 == "venv" ]]; then
        if [[ $# -ge 2 && $2 == -* ]]; then
            command uv venv "$2"
        else
            if [[ $# -eq 2 ]]; then
                VENV_NAME=$2
            else
                VENV_NAME=".venv"
            fi
            command uv venv "$VENV_NAME"
            source "$VENV_NAME/bin/activate"
            echo -e "\n${GREEN}${BOLD}[CustomCommands]${NC} Virtual environment '$VENV_NAME' has been activated."
        fi
    else
        command uv "$@"
    fi
}