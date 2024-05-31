# l10m

`l10m` is a Dart library for generating module translation files, designed to facilitate the localization of modular applications.

## Usage

To use this library, add `l10m` as a dependency in your `pubspec.yaml` file.

```yaml
dev_dependencies:
  l10m: any
```

## Command-line Interface

The `l10m` library provides a command-line interface for generating translation files. This interface allows you to specify various parameters to customize the generation process.

You can run the command-line interface with the following options:

- `--module-path` or `-m`: Specifies the path to the modules folder. Defaults to `lib/modules`.
- `--output-folder` or `-o`: Specifies the output folder for the generated files. Defaults to `l10n/generated`.
- `--root-path` or `-r`: Specifies the path to the root folder where the localization files are located. Defaults to `lib`.
- `--template-arb-file` or `-t`: Specifies the path to the template ARB file. Defaults to `intl_en.arb`.
- `--help` or `-h`: Shows the help message with a list of available options.

### Example Usage

To generate translation files, you can use the following command:

```bash
dart run l10m -m lib/modules -o l10n/generated -r lib -t intl_en.arb
```

This command will generate both the root translations and module-specific translations based on the provided paths and template ARB file.

## Output Structure

The current approach is to use translations in the `lib/l10n` folder as "general" translations shared among modules. Files located within `lib/module/module1/l10n` will be specific to that module.

### General Translations

General translations are stored in the `lib/l10n` folder. These translations are shared across multiple modules and provide a common set of localized strings.

### Module-specific Translations

Module-specific translations are stored in the `lib/modules/<module_name>/l10n` folder. These translations are unique to each module and provide localized strings that are specific to that module's functionality.

### Example Output Structure

Here is an example of what the output structure might look like:

```yaml
lib/
--l10n/
----generated/
------root_localizations.dart
------root_localizations_en.dart
------root_localizations_es.dart
----intl_en.arb  # File previously located in the root folder
----intl_es.arb  # File previously located in the root folder
--modules/
----module1/
------l10n/
--------generated/
----------module1_localizations.dart
----------module1_localizations_en.dart
----------module1_localizations_es.dart
--------intl_en.arb  # File previously located in the module folder
--------intl_es.arb  # File previously located in the module folder
----module2/
------l10n/
--------generated/
----------module2_localizations.dart
----------module2_localizations_en.dart
----------module2_localizations_es.dart
--------intl_en.arb  # File previously located in the module folder
--------intl_es.arb  # File previously located in the module folder
----module3/
------l10n/
--------generated/
----------module3_localizations.dart
----------module3_localizations_en.dart
----------module3_localizations_es.dart
--------intl_en.arb  # File previously located in the module folder
--------intl_es.arb  # File previously located in the module folder
```

In this structure:

- The `lib/l10n` folder contains general translations shared across modules.
- Each module has its own `l10n` folder within its directory (`lib/modules/module_name/l10n`) containing module-specific translations.

## Contributions

Contributions are welcome! If you have any suggestions, issues, or improvements, feel free to open issues and pull requests on the GitHub repository.

## License

This project is licensed under the MIT License. See the `LICENSE` file for details.
