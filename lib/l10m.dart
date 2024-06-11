// Função para capitalizar a primeira letra de uma string
import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;

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
  var errors = <String>[];
  // List of all modules inside the folder
  final modulePathNormalized = path.normalize(modulePath);

  var dir = Directory(modulePathNormalized);
  List<FileSystemEntity> features = dir.listSync();

  // Loop through each module
  for (var feature in features) {
    // Path to the current module
    final slash = Platform.isWindows ? '\\' : '/';
    String featureName = feature.path.split(slash).last;
    String featurePath = path.normalize('$modulePath/$featureName/l10n');

    String outputPath =
        path.normalize('$modulePath/$featureName/$outputFolder');

    try {
      // Verify if the module localization folder exists
      if (await Directory(featurePath).exists()) {
        print('🔄 Generating translations for "$featureName" folder');
        await checkLocalizationKeys(featurePath, templateArbFile);

        final flutterPath = await findFlutterExecutable();
        // Execute flutter gen-l10n for the current module
        ProcessResult result = await Process.run(flutterPath, [
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
        throw Exception(
            '❌ Failed to generate translations for "$featureName" folder: ${result.stderr.toString()} ${result.stdout}');
      } else {
        print(
            '▶▶ Skipped translations for "$featureName" folder because no translations where found in the specified path');
      }
    } on KeyNotFoundException catch (e) {
      errors.add(e.toString());
      print(
          '❌ Failed to generate translations because some keys were missing in the files');
    } catch (e) {
      errors.add(e.toString());
      print(e);
      print('❌ Failed to generate translations for "$featureName" folder');
    }
  }

  if (errors.isNotEmpty) {
    throw Exception(errors.join('\n'));
  }
}

Future<void> generateOnlyModuleTranslations({
  required String modulePath,
  required String outputFolder,
  required String templateArbFile,
  required bool nullableGetter,
  required String generateModule,
}) async {
  var errors = <String>[];
  // Path to the current module
  String featurePath = path.normalize('$modulePath/$generateModule/l10n');

  String outputPath =
      path.normalize('$modulePath/$generateModule/$outputFolder');

  try {
    // Verify if the module localization folder exists
    if (await Directory(featurePath).exists()) {
      print('🔄 Generating translations for "$generateModule" folder');
      await checkLocalizationKeys(featurePath, templateArbFile);

      String flutterPath = await findFlutterExecutable();
      // Execute flutter gen-l10n for the current module
      ProcessResult result = await Process.run(flutterPath, [
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
      throw Exception(
          '❌ Failed to generate translations for "$generateModule": ${result.stderr.toString()} ${result.stdout}');
    } else {
      print(
          '▶▶ Skipped translations for "$generateModule" folder because no translations where found in the specified path');
    }
  } on KeyNotFoundException catch (e) {
    errors.add(e.toString());
    print(
        '❌ Failed to generate translations because some keys were missing in the files');
  } catch (e) {
    errors.add(e.toString());
    print(e);
    print('❌ Failed to generate translations for "$generateModule" folder');
  }

  if (errors.isNotEmpty) {
    throw Exception(errors.join('\n'));
  }
}

Future<void> generateRootTranslations({
  required String rootPath,
  required String outputFolder,
  required String templateArbFile,
  required bool nullableGetter,
}) async {
  var errors = <String>[];

  final outputPath = path.normalize('$rootPath/$outputFolder');
  final rootPathDir = path.normalize('$rootPath/l10n');

  try {
    if (await Directory(rootPathDir).exists()) {
      print('🔄 Generating translations for root folder');

      await checkLocalizationKeys(rootPathDir, templateArbFile);

      String flutterPath = await findFlutterExecutable();
      ProcessResult result = await Process.run(flutterPath, [
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
        if (!nullableGetter) '--no-nullable-getter'
      ]);

      if (result.stdout.toString().isEmpty &&
          result.stderr.toString().isEmpty) {
        print('✅ Generated translations for root folder');
        return;
      }

      if (result.stdout.toString().isNotEmpty) print(result.stdout);
      if (result.stderr.toString().isNotEmpty) print(result.stderr);
      throw Exception(
          '❌ Failed to generate translations for root folder: ${result.stderr.toString()} ${result.stdout}');
    } else {
      print(
          '▶▶ Skipped translations for root folder because no translations where found in the specified path');
    }
  } on KeyNotFoundException catch (e) {
    errors.add(e.toString());
    print(
        '❌ Failed to generate translations because some keys were missing in the files');
  } catch (e) {
    errors.add(e.toString());
    print(e);
    print('❌ Failed to generate translations for root folder');
  }

  if (errors.isNotEmpty) {
    throw Exception(errors.join('\n'));
  }
}

Future<void> checkLocalizationKeys(
    String folderPath, String templateArbFile) async {
  var errors = <String>[];

  try {
    final directory = Directory(folderPath);
    final arbFiles =
        directory.listSync().where((file) => file.path.endsWith('.arb'));

    // Read the template file and extract all keys
    final templateContent =
        await File(path.normalize('$folderPath/$templateArbFile'))
            .readAsString();
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
        errors.add(
            'Key "${entry.key}" was not found in the following files: ${entry.value.join(', ')}');
      }

      throw KeyNotFoundException();
    }
  } on KeyNotFoundException catch (e) {
    errors.add(e.toString());
  } catch (e) {
    errors.add(e.toString());
  }

  if (errors.isNotEmpty) {
    throw Exception(errors.join('\n'));
  }
}

Future<String> findFlutterExecutable() async {
  // Obter o PATH do sistema
  String? path = Platform.environment['PATH'];

  if (path != null) {
    // Separar o PATH em diretórios individuais
    List<String> directories = path.split(Platform.isWindows ? ';' : ':');

    // Tentar encontrar o executável flutter em cada diretório
    for (String dir in directories) {
      String flutterPath =
          Platform.isWindows ? '$dir\\flutter.bat' : '$dir/flutter';

      if (await File(flutterPath).exists()) {
        return flutterPath;
      }
    }
  }

  return 'flutter';
}
