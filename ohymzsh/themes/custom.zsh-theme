# Benchmark Theme: modern, performance-focused prompt
# Configuration: control path display
: ${BENCHMARK_THEME_SHORT_PATH:=true}

# Python display configuration
: ${BENCHMARK_THEME_PYTHON_ICON:=false}     # Show/hide Python emoji icon
: ${BENCHMARK_THEME_PYTHON_PREFIX:="v"}    # Version prefix (e.g., "py", "v", "python")

# Minimalistic Color Palette - Monochrome Gray Scale
local minimal_white="%F{255}"      # Bright white
local minimal_light_gray="%F{250}" # Light gray
local minimal_medium_gray="%F{244}" # Medium gray
local minimal_dark_gray="%F{238}"  # Dark gray
local minimal_accent="%F{252}"     # Subtle accent
local reset_color="%f"

# Git status function
function git_prompt_info() {
  if git rev-parse --git-dir > /dev/null 2>&1; then
    local branch=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
    local git_status=""
    
    # Check for uncommitted changes
    if ! git diff --quiet 2>/dev/null; then
      git_status="${minimal_medium_gray}●${reset_color}"  # Filled circle - uncommitted changes
    elif ! git diff --cached --quiet 2>/dev/null; then
      git_status="${minimal_light_gray}◐${reset_color}"   # Half circle - staged changes
    else
      git_status="${minimal_dark_gray}○${reset_color}"    # Empty circle - clean repo
    fi
    
    echo " ${minimal_dark_gray}on${reset_color} ${minimal_dark_gray}git:${reset_color}${minimal_white}${branch}${reset_color} ${git_status}"
  fi
}

# Performance indicator
function perf_indicator() {
  local load=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | sed 's/,//')
  local load_int=$(echo "$load * 100" | bc 2>/dev/null | cut -d. -f1 2>/dev/null || echo "0")
  
  if [[ $load_int -lt 50 ]]; then
    echo "${benchmark_green}◉${reset_color}"
  elif [[ $load_int -lt 100 ]]; then
    echo "${benchmark_yellow}◉${reset_color}"
  else
    echo "${benchmark_red}◉${reset_color}"
  fi
}

# Time function
function benchmark_time() {
  echo "${benchmark_gray}[${benchmark_blue}$(date '+%H:%M:%S')${benchmark_gray}]${reset_color}"
}

# Virtual environment function
function venv_prompt_info() {
  if [[ -n "$VIRTUAL_ENV" ]]; then
    local venv_name=$(basename "$VIRTUAL_ENV")
    echo " ${minimal_dark_gray}(${minimal_light_gray}${venv_name}${minimal_dark_gray})${reset_color}"
  fi
}

# Python version function
function python_version_info() {
  if command -v python3 > /dev/null 2>&1; then
    local py_version=$(python3 --version 2>&1 | awk '{print $2}' | cut -d. -f1,2)
    local python_icon=""
    
    # Add Python icon if enabled
    if [[ "$BENCHMARK_THEME_PYTHON_ICON" == "true" ]]; then
      python_icon="${minimal_accent}🐍${reset_color} "
    fi
    
    echo " ${minimal_dark_gray}via${reset_color} ${python_icon}${minimal_light_gray}${BENCHMARK_THEME_PYTHON_PREFIX}${py_version}${reset_color}"
  fi
}

# Path display function
function path_info() {
  if [[ "$BENCHMARK_THEME_SHORT_PATH" == "true" ]]; then
    echo "%F{26}%1~${reset_color}"  # Show only current directory name in classic blue
  else
    echo "%F{26}%~${reset_color}"   # Show full path in classic blue
  fi
}

# Toggle function for easy switching
function toggle_path_display() {
  if [[ "$BENCHMARK_THEME_SHORT_PATH" == "true" ]]; then
    export BENCHMARK_THEME_SHORT_PATH=false
    echo "Path display: Full path enabled"
  else
    export BENCHMARK_THEME_SHORT_PATH=true
    echo "Path display: Short path enabled (directory name only)"
  fi
}

# Main prompt
PROMPT='
$(venv_prompt_info) $(path_info)$(python_version_info)$(git_prompt_info)$(execution_time_info)
${minimal_white}❯${reset_color} '

# Right prompt with execution time
function preexec() {
  timer=$(($(date +%s%0N)/1000000))
}

# Execution time function
function execution_time_info() {
  if [[ -n "$_benchmark_exec_time" ]]; then
    echo " ${minimal_dark_gray}took${reset_color} ${minimal_medium_gray}${_benchmark_exec_time}${reset_color}"
  fi
}

function precmd() {
  if [ $timer ]; then
    local now=$(($(date +%s%0N)/1000000))
    local elapsed=$(($now-$timer))
    
    if [[ $elapsed -gt 0 ]]; then
      local seconds=$(echo "scale=3; $elapsed/1000" | bc)
      # Add leading zero only for decimals that start with a dot
      if [[ $seconds =~ ^\. ]]; then
        seconds="0${seconds}"
      fi
      # Remove leading zeros from the whole number part
      seconds=$(echo "$seconds" | sed 's/^0*\([0-9]\)/\1/')
      _benchmark_exec_time="${seconds}s"
    else
      unset _benchmark_exec_time
    fi
    unset timer
  else
    unset _benchmark_exec_time
  fi
  
  # Clear right prompt
  RPROMPT=""
}

# LS Colors to match theme
export LS_COLORS="di=1;34:ln=1;36:so=1;35:pi=1;33:ex=1;32:bd=1;33:cd=1;33:su=1;31:sg=1;31:tw=1;34:ow=1;34"

# Additional customizations
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
