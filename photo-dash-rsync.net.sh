#!/usr/bin/env bash
#
# EXAMPLE script for photo-dash

# Functions should go between here and the module-level code

# Get quota from rsync.net via ssh
# Globals:
# Arguments:
#   $1: either user@host or only host
# Returns:
#   all return codes: depends on ssh
function rsync.net::get_quota() {
    ssh "$1" quota
}

# Process the quota to JSON
# Globals:
# Arguments:
#   $1: the full quota text
# Returns:
#   any: depends on jq and the quota message
function rsync.net::quota_to_json() {
    local line # Initial line extracted from output
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
    local color_arr # Array of $colors
    local IFS # Separator
    line=$(echo "$1" | tail -n1 | sed 's/[\tG]/ /g' | tr -s ' ')
    usage=$(echo "$line" | cut -d' ' -f2)
    soft_quota=$(echo "$line" | cut -d' ' -f3)
    half_quota=$(echo "scale=1; ${soft_quota}/2" | bc)
    hard_quota=$(echo "$line" | cut -d' ' -f4)
    percent_used=$(echo "scale=3; ${usage}*100/${soft_quota}" | bc \
        | sed -E 's/^(-?)\./\10./')
    if less_than "$percent_used" 50; then
        color="${colors[0]}"
    elif less_than "$percent_used" 100; then
        color="${colors[1]}"
    else
        color="${colors[2]}"
    fi
    files=$(echo "$line" | cut -d' ' -f5)

    # Section 1: Text
    value="Current usage (GB): ${usage} / ${soft_quota} (limit: ${hard_quota}"
    sections=$(jq -n 'inputs' << END
{
    "sections": [
        {
            "type": "text",
            "color": "$color",
            "value": "$value"
        }
    ]
}
END
        )

    # Section 2: Text
    value="Files in storage: ${files} | Percent usage: ${percent_used}%"
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
    sections=$(echo "$sections" | jq ".sections|= .+ ${section}")

    # Section 3: Gauge
    value="$usage"
    range="[0, $half_quota, $soft_quota, $hard_quota]"
    color_arr=$(IFS=',' && echo "${color[*]}")
    section=$(jq -n 'inputs' << END
[
    {
        "type": "gauge",
        "color": "$color_arr",
        "range": "$range",
        "value": "$value"
    }
]
END
    )
    sections=$(echo "$sections" | jq ".sections|= .+ ${section}")

    # Add sections to main JSON
    json=$(jq -n '{name: $name, title: $title}' \
        --arg name "$name" \
        --arg title "$title")

    # Complete response sent to stdout
    echo "$json" | jq ".sections|= $sections"
}

# Process the quota to JSON
# Globals:
# Arguments:
#   $1: left operand
#   $2: right operand
# Returns:
#   any: depends on jq and the quota message
function less_than() {
    if [[ $(echo "${1} < ${2}" | bc) == 1 ]]; then
        return 0
    else
        return 1
    fi
}

# Module-level code

colors=(
    '#00FF00'
    '#FFFF00'
    '#FF0000'
)

root=$(dirname "$0")
. "${root}/base.sh"

name="photo-dash-rsync.net"
title="rsync.net Storage Statistics"

if [[ -z "${PD+x}" || "$PD" != 0 ]]; then
    echo "You have problems with your configuration. Aborting ${name}." >&2
    exit 1
fi

# The rest of your script goes here, as needed.

quota=$(rsync.net::get_quota "$USER_HOST")
if ! JSON=$(rsync.net::quota_to_json "$quota"); then
    echo "Could not generate JSON." >&2
    exit 1
else
    curl -X PUT -H 'Content-Type: application/json' "$ENDPOINT" -d "$JSON"
fi
