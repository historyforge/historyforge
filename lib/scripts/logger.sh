#!/usr/bin/env bash

# Logger helper script for HistoryForge
# Get the calling script name in a shell-agnostic way
CALLING_SCRIPT=""
if [[ -n "${BASH_SOURCE[1]}" ]]; then
    # Bash
    CALLING_SCRIPT="${BASH_SOURCE[1]}"
elif [[ -n "${ZSH_ARGZERO:t:r}" ]]; then
    # Zsh
    CALLING_SCRIPT="${ZSH_ARGZERO:t:r}"
elif [[ -n "$0" && "$0" != "-bash" && "$0" != "-zsh" ]]; then
    # Use $0 if available and not an interactive shell
    CALLING_SCRIPT="$0"
else
    # Ultimate fallback - use the parent process name
    CALLING_SCRIPT=$(ps -o comm= -p $PPID 2>/dev/null || echo "unknown")
fi

# Extract just the filename without path and extension
LOG_NAME=$(basename "${CALLING_SCRIPT%.*}")
[[ "$LOG_NAME" == "unknown" || -z "$LOG_NAME" ]] && LOG_NAME="logger"

# Set up logging that strips colors from log file but preserves them in console
LOG_FILE="$DEVCONTAINER_LOG_DIR/$LOG_NAME.log"

add_timestamp() {
    while IFS= read -r line; do
        echo "[$(date '+%Y-%m-%dT%H:%M:%S.%N')] $line"
    done
}

# Logger helper script for HistoryForge
exec > >(tee >(sed 's/\x1b\[[0-9;]*m//g' | add_timestamp >> "$LOG_FILE")) 2>&1

# Color definitions (fallback if not set)
RED=${RED:-'\033[0;31m'}
GREEN=${GREEN:-'\033[0;32m'}
YELLOW=${YELLOW:-'\033[1;33m'}
BLUE=${BLUE:-'\033[0;34m'}
RESET=${RESET:-'\033[0m'}

log_info() {
    echo -e "${BLUE}📄  [INFO] $1${RESET}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  [WARNING] $1${RESET}"
}

log_error() {
    echo -e "${RED}❌  [ERROR] $1${RESET}"
}

log_success() {
    echo -e "${GREEN}✅  [SUCCESS] $1${RESET}"
}

log_standard_icon() {
    echo -e "${YELLOW}$1  $2${RESET}"
}

log_standard() {
    echo -e "${YELLOW}$1${RESET}"
}