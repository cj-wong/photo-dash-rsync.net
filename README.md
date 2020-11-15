# base.sh module for photo-dash

## Overview

The `photo-dash` project is a series of modules and an endpoint. This repository specifically is the base module in Bash (shell script) from which all other Bash-based scripts or modules should source.

[base.sh] is provided to be sourced by a new module.

For running new scripts, `cron` is recommended - instead of looping within the script, have `cron` call the script whenever needed.

## Usage

Clone (and fork) the repository to create modules in Bash for `photo-dash`.

## Requirements

This code is designed around the following:

- Bash
- `curl`: requests
- `jq`: JSON parsing

## Setup

0. Make sure both `curl` and `jq` are installed.
1. You should make changes as needed to the provided [configuration](config.json.example) to suit the new script/module. Any additions here should also be reflected in `config.sh`, which sits on the same level as the other files here. A snippet at the bottom of [base.sh] includes support for this file should it exist (i.e. `base.sh` will source it).
2. When creating your script/module, you may start with the given [example]. You should change `$name`, specifically removing any mention of `EXAMPLE`. Also, wherever colons (`:`) are listed, your code should go there. The colons are simply placeholders for content.
3. To send a request, use the format:

```bash
curl -X PUT -H 'Content-Type: application/json' "$ENDPOINT" \
    -d "{'module': '${name}', 'title': '${title}', 'sections': ${sections}}"
```

- `$ENDPOINT` is defined in [base.sh].
- `$name` is defined in your script, at the top. It's also present in the [example].
- `$title` is like `$name`: defined in your script and also in the example.
- `$sections` should be a JSON created in your script. It is up to you to define what to send to the endpoint.

## Disclaimer

See [LICENSE](LICENSE) for more detail.

[base.sh]: base.sh
[example]: example.sh
