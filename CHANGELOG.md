# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

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
