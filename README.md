# l10m

`l10m` is a Dart library for generating module translations files.

## Usage

To use this library, add `l10m` as a dependency in your `pubspec.yaml` file.

```yaml
dependencies:
  l10m: any
```

Then, import the library in your code:

`import 'package:l10m/l10m.dart`;`

## Command-line Interface

The `l10m` library provides a command-line interface for generating translation files

You can run the command-line interface with the following options:

- `--module-path` or `-m`: Path to the modules folder. Defaults to lib/modules.
- `--output-folder` or `-o`: Output folder for the generated files. Defaults to l10n/generated.
- `--root-path` or `-r`: Path to the root folder where the localization files are located. Defaults to lib.
- `--template-arb-file` or `-t`: Path to the template arb file. Defaults to intl_en.arb.
- `--help` or `-h`: Show the help.

## Example usage

`dart run l10m -m lib/modules -o l10n/generated -r lib -t intl_en.arb`
This will generate the root translations and module translations based on the provided paths and template arb file.

### output:

```YAML
lib/
--l10n/
----generated/
------root_localizations.dart
------root_localizations_en.dart
------root_localizations_es.dart
----intl_en.arb // File previously located in the root folder
----intl_es.arb // File previously located in the root folder
--modules/
----module1/
------generated/
--------module1_localizations.dart
--------module1_localizations_en.dart
--------module1_localizations_es.dart
------intl_en.arb // File previously located in the module folder
------intl_es.arb // File previously located in the module folder
----module2/
------generated/
--------module2_localizations.dart
--------module2_localizations_en.dart
--------module2_localizations_es.dart
------intl_en.arb // File previously located in the module folder
------intl_es.arb // File previously located in the module folder
----module3/
------generated/
--------module3_localizations.dart
--------module3_localizations_en.dart
--------module3_localizations_es.dart
------intl_en.arb // File previously located in the module folder
------intl_es.arb // File previously located in the module folder
```
