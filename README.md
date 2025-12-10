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
- `--check`: Validate translations without generating files. Useful for CI pipelines.
- `--help` or `-h`: Shows the help message with a list of available options.

## Configuration File

You can use a configuration file to avoid passing long arguments to the CLI.
Supported file names are `l10m.yaml`, `l10m.yml`, `l10m.json`, `.l10m.yaml`, `.l10m.yml`, `.l10m.json`.

Example `l10m.yaml`:

```yaml
module-path: lib/modules
output-folder: l10n/generated
root-path: lib
template-arb-file: intl_en.arb
nullable-getter: true
generate-root: true
modules:
  auth:
    output-folder: l10n/gen
    template-arb-file: intl_pt.arb
    nullable-getter: false
```

CLI arguments take precedence over configuration file settings.

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

After generating the files, you can combine them all into a common class to be used in the application:

translate.dart

```dart
import 'package:flutter/material.dart';

import 'l10n/generated/root_localizations.dart';
import 'modules/module1/l10n/generated/module1_localizations.dart';
import 'modules/module2/l10n/generated/module2_localizations.dart';
import 'modules/module3/l10n/generated/module3_localizations.dart';

class Translate {
  static List<LocalizationsDelegate> localizationsDelegates = [
    RootLocalizationsDelegate(),
    Module1LocalizationsDelegate(),
    Module2LocalizationsDelegate(),
    Module3LocalizationsDelegate(),
  ];

  static List<Locale> supportedLocales = [
    const Locale('en'),
    const Locale('es'),
  ];

  static RootLocalizations root(BuildContext context) {
    return RootLocalizations.of(context);
  }

  static Module1Localizations module1(BuildContext context) {
    return Module1Localizations.of(context);
  }

  static Module2Localizations module2(BuildContext context) {
    return Module2Localizations.of(context);
  }

  static Module3Localizations module3(BuildContext context) {
    return Module3Localizations.of(context);
  }
}
```

main.dart

```dart
import 'package:flutter/material.dart';

import 'translate.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: Translate.localizationsDelegates,
      supportedLocales: Translate.supportedLocales,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Translate.root(context).appTitle),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(Translate.module1(context).title),
            Text(Translate.module2(context).title),
            Text(Translate.module3(context).title),
          ],
        ),
      ),
    );
  }
}
```

In this structure:

- The `lib/l10n` folder contains general translations shared across modules.
- Each module has its own `l10n` folder within its directory (`lib/modules/module_name/l10n`) containing module-specific translations.

## Contributions

Contributions are welcome! If you have any suggestions, issues, or improvements, feel free to open issues and pull requests on the GitHub repository.

## License

This project is licensed under the MIT License. See the `LICENSE` file for details.

```

```
