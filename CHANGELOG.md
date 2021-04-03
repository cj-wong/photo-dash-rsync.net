# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [0.2.3] - 2021-04-03
### Changed
- Cleaned up documentation (return codes).

### Fixed
- Fixed parameter substitution of `+x` in `[ -z "${matched_name+x}" ]` to `:+x`; this checks both whether `$matched_name` is empty and whether `$matched_name` was declared. Specifically, in the old syntax, if `$matched_name` was empty but declared, it would be substituted with `x`. In the new syntax, the substitution only takes place if `$matched_name` is empty (regardless of declaration).
- Fixed incorrect condition `if [[ -z "${QUIET_START:+x}" || -z "${QUIET_START:+x}" ]]`: the second `QUIET_START` has been changed to `QUIET_END`.

## [0.2.2] - 2021-02-03
### Fixed
- Fixed unit for quota not being properly retrieved.

## [0.2.1] - 2021-02-02
### Added
- Added last 3 digits of account to each image as necessary, in the header.

### Fixed
- Issue #2: The script now uses the right unit, instead of the hard-coded `GB`.
- Issue #3: The JSON payload now uses the last 3 digits of account and the filesystem name to ensure each account and its respective filesystems can be represented with an image.
    - A caveat to this change is that the old `photo-dash-rsync.net.jpg` on `photo-dash`'s end will have to be deleted, or else the file will remain on the photo frame.

## [0.2.0] - 2021-01-05
### Changed
- As a result of issue #1, multiple filesystems, if present, are now supported.
- The exit code for the script no longer depends on JSON parsing. Failed parses are simply skipped.
- The text elements in JSON are now broken into more lines to reduce cluttering. The total number of lines now, excluding the gauge, is now 4 (previously 2); altogether, that's 6 lines of data.

### Fixed
- Issue #1:
    - The `quota` command output should no longer affect (read: break) JSON creation.

## [0.1.2] - 2020-12-07
### Fixed
- Fixed JSON parse issue after `quota` syntax changed

## [0.1.1] - 2020-11-18
### Added
- Added `array_bash_to_json()` to convert a Bash array to a JSON array. This is primarily used to convert the array for colors in the gauge.

### Fixed
- In the payload JSON, `"name"` was actually supposed to be `"module"`.
- I unfortunately misunderstood how `jq` combines JSONs. Subsequently, the section-building part in `rsync.net::quota_to_json()` starts with an array, not a key (`"sections"`) and an array.
- Properly converted the array of colors into a JSON array. See the note for `array_bash_to_json()`.
- For some reason, the gauge `"value"` must be unquoted, or it'll be converted to string.

## [0.1.0] - 2020-11-17
### Added
- Initial version
