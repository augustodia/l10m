## 1.0.0

- Massive refactor splitting the generator into reusable services and utilities while keeping the public API intact.
- Added duplicate key detection with automatic cleanup of generated outputs before failing.
- Enhanced CLI feedback with log levels and emoji prefixes for successes, warnings, and errors.
- Improved error messages for missing/duplicate keys and cleanup failures.

## 0.4.1 - 0.4.3

- 🐛 Fix bug only generate root

## 0.4.0

- Added support to Windows

## 0.3.1 - 0.3.5

- Improvments erros messages

## 0.3.0

- Added flag `--generate-only-root` to generate only the root folder
- Added flag `--generate-only-module` to generate only the module folder
- Added option `-generate-module` or `-g` to generate the module folder. This option is only active if the flag `--generate-only-module` is active.

## 0.2.0

- (Breaking changes) Added flag `--[no-]nullable-getter` to enable or disable the nullable getter. By default is true (nullable getters)

## 0.1.4

- Added flag `--[no-]generate-root` to disable the generation of the root folder

## 0.1.3

- Update README.md
- Upgrade dependencies

## 0.1.2

- Update README.md

## 0.1.1

- Update README.md

## 0.1.0

- Apply the new structure for the library

## 0.0.3

- Remove unnecessary codes

## 0.0.2

- Format code.

## 0.0.1

- Initial version.
