# [rsync.net] for [photo-dash]

## Overview

The `photo-dash` project is a series of modules and an endpoint. This repository specifically features some integration with [rsync.net], specifically in regards to quotas.

## Usage

After [setup](#setup), run [photo-dash-rsync.net.sh].

## Requirements

This code is designed around the following:

- Bash
- `bc`: math
- `curl`: requests
- `jq`: JSON parsing
- `ssh` should already be set up with password-less login, ideally restricting a key to only call the `quota` command
    - have a look at the [example](resources/authorized_keys) for ideas

## Setup

0. Make sure both `bc`, `curl`, and `jq` are installed on your local machine. You should also already have `ssh` installed and set up on the [rsync.net] host. You may restrict the command for your key to only call `quota`. You should also add an entry to `~/.ssh/config` for quicker access.
1. Copy and rename the [configuration](config.json.example) to `config.json`. Both `ssh_host` and `endpoint` are not optional; `ssh_user` is optional. `ssh_host` is your host but can be represented in `~/.ssh/config`, a more granular approach to host management.
2. Try connecting to the host, preferably with a command like this: `ssh rsync.net quota`. (In this example, `rsync.net` is a host configuration with user and server defined.) You will need to accept the [fingerprint] before your command will continue. If you plan to run this automatically, also make sure that password-less login works.
3. Run [photo-dash-rsync.net.sh], preferably with `cron`.

## Disclaimer

This project is not affiliated with or endorsed by [rsync.net]. See [LICENSE](LICENSE) for more detail.

[photo-dash]: https://github.com/cj-wong/photo-dash
[rsync.net]: https://www.rsync.net
[fingerprint]: https://www.rsync.net/resources/fingerprints.txt
[base.sh]: base.sh
[example]: example.sh
[photo-dash-rsync.net.sh]: photo-dash-rsync.net.sh
