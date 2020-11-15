#!/usr/bin/env bash
#
# EXAMPLE script for photo-dash

# Functions should go between here and the module-level code

:

# Module-level code

root=$(dirname "$0")
. "${root}/base.sh"

name="photo-dash-EXAMPLE"
title="example.sh for photo-dash-base.sh"

if [[ -z "${PD+x}" || "$PD" != 0 ]]; then
    echo "You have problems with your configuration. Aborting ${name}." >&2
    exit 1
fi

# The rest of your script goes here, as needed.

:

# shellcheck disable=SC2154
curl -X PUT -H 'Content-Type: application/json' "$ENDPOINT" \
    -d "{'module': '${name}', 'title': '${title}', 'sections': ${sections}}"
