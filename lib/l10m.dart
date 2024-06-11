// Função para capitalizar a primeira letra de uma string
import 'dart:convert';
import 'dart:io';

import 'package:l10m/errors/key_not_found_exception.dart';

String capitalize(String text) {
  return text[0].toUpperCase() + text.substring(1);
}

String underscoreToCamelCase(String text) {
  return text.split('_').map((e) => capitalize(e)).join();
}

String camelCaseToUnderscore(String text) {
  return text.replaceAllMapped(RegExp(r'[A-Z]'), (match) {
    if (match.start == 0) {
      return match.group(0)!.toLowerCase();
    } else {
      return '_${match.group(0)!.toLowerCase()}';
    }
  });
}

Future<void> generateModulesTranslations({
  required String modulePath,
  required String outputFolder,
  required String templateArbFile,
  required bool nullableGetter,
}) async {
  // List of all modules inside the folder
  var dir = Directory(modulePath);
  List<FileSystemEntity> features = dir.listSync();

  // Loop through each module
  for (var feature in features) {
    // Path to the current module
    String featureName = feature.path.split('/').last;
    String featurePath = '$modulePath/$featureName/l10n';

    String outputPath = '$modulePath/$featureName/$outputFolder';

    try {
      // Verify if the module localization folder exists
      if (await Directory(featurePath).exists()) {
        print('🔄 Generating translations for "$featureName" folder');
        await checkLocalizationKeys(featurePath, templateArbFile);
        // Execute flutter gen-l10n for the current module
        ProcessResult result = await Process.run('flutter', [
          'gen-l10n',
          '--arb-dir',
          featurePath,
          '--output-dir',
          outputPath,
          '--no-synthetic-package',
          '--output-class',
          '${underscoreToCamelCase(capitalize(featureName))}Localizations',
          '--template-arb-file',
          templateArbFile,
          '--output-localization-file',
          '${camelCaseToUnderscore(featureName)}_localizations.dart',
          if (!nullableGetter) '--no-nullable-getter'
        ]);

        if (result.stdout.toString().isEmpty &&
            result.stderr.toString().isEmpty) {
          print('✅ Generated translations for "$featureName" folder');
          return;
        }

        if (result.stdout.toString().isNotEmpty) print(result.stdout);
        if (result.stderr.toString().isNotEmpty) print(result.stderr);
        print('❌ Failed to generate translations for "$featureName" folder');
      } else {
        print(
            '▶▶ Skipped translations for "$featureName" folder because no translations where found in the specified path');
      }
    } on KeyNotFoundException {
      print(
          '❌ Failed to generate translations because some keys were missing in the files');
    } catch (e) {
      print(e);
      print('❌ Failed to generate translations for "$featureName" folder');
    }
  }
}

Future<void> generateOnlyModuleTranslations({
  required String modulePath,
  required String outputFolder,
  required String templateArbFile,
  required bool nullableGetter,
  required String generateModule,
}) async {
  // Path to the current module
  String featurePath = '$modulePath/$generateModule/l10n';

  String outputPath = '$modulePath/$generateModule/$outputFolder';

  try {
    // Verify if the module localization folder exists
    if (await Directory(featurePath).exists()) {
      print('🔄 Generating translations for "$generateModule" folder');
      await checkLocalizationKeys(featurePath, templateArbFile);
      // Execute flutter gen-l10n for the current module
      ProcessResult result = await Process.run('flutter', [
        'gen-l10n',
        '--arb-dir',
        featurePath,
        '--output-dir',
        outputPath,
        '--no-synthetic-package',
        '--output-class',
        '${underscoreToCamelCase(capitalize(generateModule))}Localizations',
        '--template-arb-file',
        templateArbFile,
        '--output-localization-file',
        '${camelCaseToUnderscore(generateModule)}_localizations.dart',
        if (!nullableGetter) '--no-nullable-getter'
      ]);

      if (result.stdout.toString().isEmpty &&
          result.stderr.toString().isEmpty) {
        print('✅ Generated translations for "$generateModule" folder');
        return;
      }

      if (result.stdout.toString().isNotEmpty) print(result.stdout);
      if (result.stderr.toString().isNotEmpty) print(result.stderr);
      print('❌ Failed to generate translations for "$generateModule" folder');
    } else {
      print(
          '▶▶ Skipped translations for "$generateModule" folder because no translations where found in the specified path');
    }
  } on KeyNotFoundException {
    print(
        '❌ Failed to generate translations because some keys were missing in the files');
  } catch (e) {
    print(e);
    print('❌ Failed to generate translations for "$generateModule" folder');
  }
}

Future<void> generateRootTranslations(
    {required String rootPath,
    required String outputFolder,
    required String templateArbFile}) async {
  final outputPath = '$rootPath/$outputFolder';
  final rootPathDir = '$rootPath/l10n';
  try {
    if (await Directory(rootPathDir).exists()) {
      print('🔄 Generating translations for root folder');
      await checkLocalizationKeys(rootPathDir, templateArbFile);

      ProcessResult result = await Process.run('flutter', [
        'gen-l10n',
        '--arb-dir',
        rootPathDir,
        '--output-dir',
        outputPath,
        '--no-synthetic-package',
        '--output-class',
        'RootLocalizations',
        '--template-arb-file',
        templateArbFile,
        '--output-localization-file',
        'root_localizations.dart',
        '--no-nullable-getter'
      ]);

      if (result.stdout.toString().isEmpty &&
          result.stderr.toString().isEmpty) {
        print('✅ Generated translations for root folder');
        return;
      }

      if (result.stdout.toString().isNotEmpty) print(result.stdout);
      if (result.stderr.toString().isNotEmpty) print(result.stderr);

      print('❌ Failed to generate translations for root folder');
    } else {
      print(
          '▶▶ Skipped translations for root folder because no translations where found in the specified path');
    }
  } on KeyNotFoundException {
    print(
        '❌ Failed to generate translations because some keys were missing in the files');
  } catch (e) {
    print(e);
    print('❌ Failed to generate translations for root folder');
  }
}

Future<void> checkLocalizationKeys(String path, String templateArbFile) async {
  try {
    final directory = Directory(path);
    final arbFiles =
        directory.listSync().where((file) => file.path.endsWith('.arb'));

    // Read the template file and extract all keys
    final templateContent = await File('$path/$templateArbFile').readAsString();
    final templateJson = jsonDecode(templateContent) as Map<String, dynamic>;
    final templateKeys = templateJson.keys.toSet();

    final missingKeys = <String, List<String>>{};

    for (final file in arbFiles) {
      final content = await File(file.path).readAsString();
      final json = jsonDecode(content) as Map<String, dynamic>;

      // Check if all keys from the template file exist in the current file
      for (final key in templateKeys) {
        if (!json.containsKey(key)) {
          if (!missingKeys.containsKey(key)) {
            missingKeys[key] = [];
          }

          missingKeys[key]!.add(file.path);
        }
      }
    }

    if (missingKeys.isNotEmpty) {
      for (final entry in missingKeys.entries) {
        print(
            'The key "${entry.key}" is missing in the following files: ${entry.value.join(', ')}');
      }

      throw KeyNotFoundException(
          keyNotFound: missingKeys.keys.first, files: missingKeys.values.first);
    }
  } on KeyNotFoundException {
    rethrow;
  } catch (e) {
    rethrow;
  }
}
