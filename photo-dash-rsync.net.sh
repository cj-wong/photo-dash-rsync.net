#!/usr/bin/env bash
#
# EXAMPLE script for photo-dash

# Functions should go between here and the module-level code

# Get quota from rsync.net via ssh.
# Globals:
#   None
# Arguments:
#   $1: either user@host or only host
# Returns:
#   all return codes: depends on ssh
function rsync.net::get_quota() {
    ssh "$1" quota
}

# Process the quota to JSON.
# Globals:
#   COLORS: a bash array of colors
#   NAME: name of the module, i.e. photo-dash-rsync.net
#   TITLE: title of the dash image
# Arguments:
#   $1: a filesystem's quota
# Returns:
#   any: depends on jq and the quota message
function rsync.net::quota_to_json() {
    local line # Initial line extracted from output
    local fs # Filesystem name of the input
    local usage # Current usage
    local soft_quota # Maximum allotted storage
    local half_quota # Half of maximum allotted storage
    local hard_quota # Storage with overage
    local percent_used # ${usage}*100/${soft_quota}
    local color # Depends on percent_used; under 50, under 100, or above
    local files # Number of files in storage
    local json # JSON to be printed to stdout
    local section # An individual section
    local sections # All the sections combined
    local value # The "value" field
    local range # Range for gauge section
    local color_arr # Array of $COLORS
    line=$(echo "$1" | sed 's/[\tG]/ /g' | tr -s ' ')
    fs=$(echo "$line" | cut -d' ' -f1)
    usage=$(echo "$line" | cut -d' ' -f2)
    soft_quota=$(echo "$line" | cut -d' ' -f3)
    half_quota=$(echo "scale=1; ${soft_quota}/2" | bc)
    hard_quota=$(echo "$line" | cut -d' ' -f4)
    # Set the color of some text elements relative to percent used.
    percent_used=$(echo "scale=3; ${usage}*100/${soft_quota}" | bc \
        | sed -E 's/^(-?)\./\10./')
    if less_than "$percent_used" 50; then
        color="${COLORS[0]}"
    elif less_than "$percent_used" 100; then
        color="${COLORS[1]}"
    else
        color="${COLORS[2]}"
    fi
    files=$(echo "$line" | cut -d' ' -f5)

    # Section 1: Text, usage
    value="Current usage [${unit}]: ${usage}"
    sections=$(jq -n 'inputs' << END
[
    {
        "type": "text",
        "color": "#FFFFFF",
        "value": "$value"
    }

]
END
    )

    # Section 2: Text, limits
    value="Limits        [${unit}]: ${soft_quota} (${hard_quota})"
    section=$(jq -n 'inputs' << END
[
    {
        "type": "text",
        "color": "#FFFFFF",
        "value": "$value"
    }

]
END
    )
    sections=$(echo "$sections" | jq ".|= .+ ${section}")

    # Section 3: Text, percentage used
    value="Percent usage     : ${percent_used}%"
    section=$(jq -n 'inputs' << END
[
    {
        "type": "text",
        "color": "$color",
        "value": "$value"
    }

]
END
    )
    sections=$(echo "$sections" | jq ".|= .+ ${section}")

    # Section 4: Text, number of files
    value="Files             : ${files}"
    section=$(jq -n 'inputs' << END
[
    {
        "type": "text",
        "color": "#FFFFFF",
        "value": "$value"
    }

]
END
    )
    sections=$(echo "$sections" | jq ".|= .+ ${section}")

    # Section 5: Gauge
    value="$usage"
    range="[0, $half_quota, $soft_quota, $hard_quota]"
    color_arr=$(array_bash_to_json COLORS)
    section=$(jq -n 'inputs' << END
[
    {
        "type": "gauge",
        "color": $color_arr,
        "range": $range,
        "value": $value
    }
]
END
    )
    sections=$(echo "$sections" | jq ".|= .+ ${section}")

    # Add sections to main JSON
    json=$(jq -n '{module: $name, title: $title}' \
        --arg name "${NAME}-${account}_${fs}" \
        --arg title "${TITLE} [**${account}] [${fs}]")

    # Send JSON payload to stdout
    echo "$json" | jq ".sections|= $sections"
}

# Determine whether a number is less than another. Supports floating point.
# Globals:
#   None
# Arguments:
#   $1: left operand
#   $2: right operand
# Returns:
#   0: if left operand is less than right operand
#   1: if left operand is greater than or equal to right operand
function less_than() {
    if [[ $(echo "${1} < ${2}" | bc) == 1 ]]; then
        return 0
    else
        return 1
    fi
}

# Convert a bash array to JSON array.
# Globals:
#   None
# Arguments:
#   $1: left operand
# Returns:
#   any: depends on jq and the array contents
function array_bash_to_json() {
    local -n src="$1"
    local dest
    local el
    dest=$(jq -n '[]') # Create an empty array
    for el in "${src[@]}"; do
        dest=$(echo "$dest" | jq ".|= .+ [\"$el\"]")
    done

    echo "$dest"
}


# Module-level code

COLORS=(
    '#00FF00'
    '#FFFF00'
    '#FF0000'
)

root=$(dirname "$0")
. "${root}/base.sh"

NAME="photo-dash-rsync.net"
TITLE="rsync.net Storage"

if [[ -z "${PD+x}" || "$PD" != 0 ]]; then
    echo "You have problems with your configuration. Aborting ${NAME}." >&2
    exit 1
elif base::in_quiet_hours; then
    echo "Currently in quiet hours. Skipping."
    exit 0
fi

# The rest of your script goes here, as needed.

quota=$(rsync.net::get_quota "$USER_HOST")
systems=$(echo "$quota" \
    | grep -E "^[^ ]+[[:space:]]+([0-9\.]+[[:space:]]*){1,}$")
# Extract only last 3 digits of account number.
account=$(echo "$quota" \
    | head --lines=1 | rev | cut --delimiter=' ' --fields=1 \
    | grep -E --only-matching '[0-9]{3}' | rev)
unit=$(echo "$quota" | grep "^ \*" | rev | cut --delimiter=' ' --fields=1 | rev)
while read -r system; do
    if ! JSON=$(rsync.net::quota_to_json "$system"); then
        echo "Could not generate JSON." >&2
        continue
    else
        curl -X PUT -H 'Content-Type: application/json' "$ENDPOINT" -d "$JSON"
        # Minimize spamming the endpoint with a sleep.
        sleep 10
    fi
done <<< "$systems"
