# shellcheck shell=bash
#
# Base source-only script in Bash for photo-dash

# Set up quiet hours for the module.
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   0: if curl succeeded
#   any other integer: depends on curl's exit status
function base::setup_quiet_hours() {
    curl "${ENDPOINT}/quiet" --output "${ROOT}/quiet_hours.json"
    base::load_quiet_hours
}

# Load quiet hours into variables with the same name as their origin keys.
# This function may fail if the quiet hours endpoint returns an invalid JSON.
# Globals:
#   JSON: ${ROOT}/quiet_hours.json
#   QUIET_START: integer; when quiet hours begin
#   QUIET_END: integer; when quiet hours stop
# Arguments:
#   None
# Returns:
#   0: if no errors occurred
#   any other integer: depends on jq's exit status
function base::load_quiet_hours() {
    local point
    for point in "quiet_start" "quiet_end"; do
        point_upper=$(echo "$point" | tr '[:lower:]' '[:upper:]')
        declare "$point_upper=$(jq -r ".${point}" "${ROOT}/quiet_hours.json")"
    done
}

# Check whether the current time is within quiet hours.
# Globals:
#   QUIET_START: integer; when quiet hours begin
#   QUIET_END: integer; when quiet hours stop
# Arguments:
#   None
# Returns:
#   0: if within quiet hours
#   1: otherwise
function base::in_quiet_hours() {
    local hour
    hour=$(date +'%H')
    if [ "$QUIET_START" -gt "$QUIET_END" ]; then
        if [[ "$hour" -ge "$QUIET_START" || "$hour" -lt "$QUIET_END" ]]; then
            return 0
        fi
    elif [[ "$QUIET_START" -le "$hour" && "$hour" -lt "$QUIET_END" ]]; then
        return 0
    fi

    return 1
}

# Check specifically if app dependencies are met
# Globals:
#   PD: photo-dash module status; 0 for no errors, 1 for errors
# Arguments:
#   None
# Returns:
#   0: if all app dependencies are available
#   1: otherwise
function base::check_apps() {
    local errors
    errors=0
    for req in "${REQS[@]}"; do
        if ! command -v "$req" > /dev/null 2>&1; then
            echo "${req} is not installed." >&2
            errors=1
        fi
    done

    return "$errors"
}

# Check that dependencies and files are available
# Globals:
#   PD: photo-dash module status; 0 for no errors, 1 for errors
# Arguments:
#   None
# Returns:
#   0: if all dependencies and files are available
#   1: otherwise
function base::check_dependencies() {
    if ! base::check_apps; then
        echo "One or more required apps are not installed." >&2
        PD=1
    elif [ ! -f "$JSON" ]; then
        echo "config.json was not found." >&2
        PD=1
    else
        PD=0
    fi

    export PD
    return "$PD"
}

# Module-level code

ROOT=$(dirname "${BASH_SOURCE[0]}")
JSON="${ROOT}/config.json"

REQS=(
    curl
    jq
)

if ! base::check_dependencies; then
    echo "Dependencies and/or files are missing."
else
    ENDPOINT=$(jq -r '.endpoint' "$JSON")
    base::setup_quiet_hours
fi

# Additional configuration may be listed below, or sourced from another file
if [ -f "${ROOT}/config.sh" ]; then
    . "${ROOT}/config.sh"
fi
