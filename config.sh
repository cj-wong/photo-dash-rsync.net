# shellcheck shell=bash
#
# Extra configuration for photo-dash-rsync.net

# Generate the SSH command args to be used.
# Globals:
#   None
# Arguments:
#   None
# Returns:
#   0: args were successfully created
function config::ssh_args() {
    local user
    local host
    user=$(jq -r '.ssh_user' "${ROOT}/config.json")
    host=$(jq -r '.ssh_host' "${ROOT}/config.json")
    # shellcheck disable=SC2034
    # USER_HOST is used in the main script; no need to export.
    if [ -n "$user" ]; then
        USER_HOST="${user}@${host}"
    else
        USER_HOST="$host"
    fi
}

# Module-level code

if [ -z "${ROOT:+x}" ]; then
    ROOT=$(dirname "${BASH_SOURCE[0]}")
fi

config::ssh_args
