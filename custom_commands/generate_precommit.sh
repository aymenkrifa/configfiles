# generate_precommit - Generate and install pre-commit configuration
#
# Usage:
#   generate_precommit [-t tool] <path_to_project>
#
# Arguments:
#   path_to_project     Path to the project where .pre-commit-config.yaml will be created
#
# Options:
#   -t tool             Specify the linter tool to use: 'ruff' (default) or 'black'
#
# Examples:
#   generate_precommit /path/to/my/project
#   generate_precommit -t black /path/to/my/project
#
# This function will:
#   1. Create a .pre-commit-config.yaml file in the specified project directory
#   2. Install pre-commit hooks if not already installed
#   3. Automatically update all hooks to their latest versions
#
generate_precommit() {

    RED='\033[0;31m'
    GREEN='\033[0;32m'
    BOLD='\033[1m'
    NC='\033[0m'

    local tool="ruff"

    while getopts ":t" opt; do
        case ${opt} in
        t)
            tool=$OPTARG
            ;;
        \?)
            echo "Invalid option: $OPTARG" 1>&2
            return 1
            ;;
        esac
    done
    shift $((OPTIND - 1))

    if [ $# -eq 0 ]; then
        echo "Usage: generate_precommit [-t tool] <path_to_project>"
        echo "Options:"
        echo "  -t tool: Specify the tool to use (ruff or black)"
        return 1
    fi

    local project_path="$(realpath $1)"

    if [ -f "$project_path/.pre-commit-config.yaml" ]; then
        echo -e "${RED}A .pre-commit-config.yaml file already exists at ${BOLD}$project_path/.pre-commit-config.yaml${NC}"
        return 1
    fi

    cat >"$project_path/.pre-commit-config.yaml" <<EOF
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v6.0.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-added-large-files
      - id: debug-statements
      - id: check-json
        language_version: python3

  - repo: https://github.com/asottile/reorder-python-imports
    rev: v3.16.0
    hooks:
      - id: reorder-python-imports

EOF

    if [ "$tool" = "ruff" ]; then
        cat >>"$project_path/.pre-commit-config.yaml" <<EOF
  - repo: https://github.com/astral-sh/ruff-pre-commit
    rev: v0.15.12
    hooks:
      - id: ruff
        args: [--fix]
      - id: ruff-format
EOF
    elif [ "$tool" = "black" ]; then
        cat >>"$project_path/.pre-commit-config.yaml" <<EOF
  - repo: https://github.com/psf/black
    rev: 24.10.0
    hooks:
      - id: black
EOF
    else
        echo -e "${RED}Invalid tool specified ('ruff' or 'black'): ${BOLD}$tool${NC}"
        return 1
    fi

    echo -e "${GREEN}The Pre-commit configuration sample file has been created at ${BOLD}$project_path/.pre-commit-config.yaml${NC}"

    if ! command -v pre-commit &>/dev/null; then
        echo "pre-commit could not be found, installing..."
        pip install pre-commit
    fi
    pre-commit install

    echo -e "${GREEN}Updating pre-commit hooks...${NC}"
    pre-commit autoupdate
}