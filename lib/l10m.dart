// Função para capitalizar a primeira letra de uma string
import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;

import 'package:l10m/errors/key_not_found_exception.dart';
import 'package:l10m/errors/duplicate_key_exception.dart';

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
        await checkLocalizationKeys(featurePath, templateArbFile,
            generatedFolderPath: outputPath);

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

        if (result.stdout.toString().isNotEmpty) print(result.stdout);
        if (result.stderr.toString().isNotEmpty) print(result.stderr);

        if (result.exitCode == 0) {
          print('✅ Generated translations for "$featureName" folder');
          continue;
        }

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
    } on DuplicateKeyException catch (e) {
      errors.add(e.toString());
      print(e);
      print(
          'Failed to generate translations because duplicate keys were found in the files');
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
      await checkLocalizationKeys(featurePath, templateArbFile,
          generatedFolderPath: outputPath);

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

      if (result.stdout.toString().isNotEmpty) print(result.stdout);
      if (result.stderr.toString().isNotEmpty) print(result.stderr);

      if (result.exitCode == 0) {
        print('✅ Generated translations for "$generateModule" folder');
        return;
      }

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
  } on DuplicateKeyException catch (e) {
    errors.add(e.toString());
    print(e);
    print(
        'Failed to generate translations because duplicate keys were found in the files');
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

      await checkLocalizationKeys(rootPathDir, templateArbFile,
          generatedFolderPath: outputPath);

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

      if (result.stdout.toString().isNotEmpty) print(result.stdout);
      if (result.stderr.toString().isNotEmpty) print(result.stderr);

      if (result.exitCode == 0) {
        print('✅ Generated translations for root folder');
        return;
      }

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
  } on DuplicateKeyException catch (e) {
    errors.add(e.toString());
    print(e);
    print(
        'Failed to generate translations because duplicate keys were found in the files');
  } catch (e) {
    errors.add(e.toString());
    print(e);
    print('❌ Failed to generate translations for root folder');
  }

  if (errors.isNotEmpty) {
    throw Exception(errors.join('\n'));
  }
}

Future<void> checkLocalizationKeys(String folderPath, String templateArbFile,
    {String? generatedFolderPath}) async {
  final directory = Directory(folderPath);

  if (!await directory.exists()) {
    return;
  }

  final arbFiles = directory
      .listSync()
      .whereType<File>()
      .where((file) => file.path.endsWith('.arb'))
      .toList();

  if (arbFiles.isEmpty) {
    return;
  }

  final templateFile =
      File(path.normalize(path.join(folderPath, templateArbFile)));

  if (!await templateFile.exists()) {
    throw Exception(
        'Template arb file "$templateArbFile" was not found in $folderPath');
  }

  final templateContent = await templateFile.readAsString();
  final templateJson = jsonDecode(templateContent) as Map<String, dynamic>;
  final templateKeys = templateJson.keys.toSet();

  final missingKeys = <String, List<String>>{};
  final duplicateKeys = <String, Set<String>>{};

  for (final file in arbFiles) {
    final content = await File(file.path).readAsString();
    final duplicates = _findDuplicateKeys(content);

    if (duplicates.isNotEmpty) {
      duplicateKeys[file.path] = duplicates;
    }

    final json = jsonDecode(content) as Map<String, dynamic>;

    for (final key in templateKeys) {
      if (!json.containsKey(key)) {
        missingKeys.putIfAbsent(key, () => []).add(file.path);
      }
    }
  }

  if (duplicateKeys.isNotEmpty) {
    await _deleteGeneratedLocalization(generatedFolderPath);

    final message = duplicateKeys.entries
        .map((entry) =>
            'Duplicate key(s) ${entry.value.join(', ')} found in file ${path.normalize(entry.key)}')
        .join('\n');

    throw DuplicateKeyException(message);
  }

  if (missingKeys.isNotEmpty) {
    final message = missingKeys.entries
        .map((entry) =>
            'Key "${entry.key}" was not found in the following files: ${entry.value.map(path.normalize).join(', ')}')
        .join('\n');

    throw KeyNotFoundException(message);
  }
}

Set<String> _findDuplicateKeys(String content) {
  final seen = <String>{};
  final duplicates = <String>{};
  var index = 0;

  while (index < content.length) {
    if (content[index] != '"') {
      index++;
      continue;
    }

    index++;
    final buffer = StringBuffer();
    var escaped = false;

    while (index < content.length) {
      final current = content[index];

      if (escaped) {
        buffer.write(current);
        escaped = false;
        index++;
        continue;
      }

      if (current == '\\') {
        escaped = true;
        index++;
        continue;
      }

      if (current == '"') {
        break;
      }

      buffer.write(current);
      index++;
    }

    if (index >= content.length) {
      break;
    }

    final key = buffer.toString();
    index++;

    while (index < content.length &&
        (content[index] == ' ' ||
            content[index] == '\n' ||
            content[index] == '\r' ||
            content[index] == '\t')) {
      index++;
    }

    if (index < content.length && content[index] == ':') {
      if (!seen.add(key)) {
        duplicates.add(key);
      }
    }
  }

  return duplicates;
}

Future<void> _deleteGeneratedLocalization(String? generatedFolderPath) async {
  if (generatedFolderPath == null || generatedFolderPath.isEmpty) {
    return;
  }

  final normalizedPath = path.normalize(generatedFolderPath);
  final directory = Directory(normalizedPath);

  try {
    if (await directory.exists()) {
      await directory.delete(recursive: true);
      print(
          'Removed generated localization files at $normalizedPath due to duplicate keys.');
    }
  } catch (e) {
    print(
        'Failed to remove generated localization files at $normalizedPath: $e');
  }
}

Future<String> findFlutterExecutable() async {
  // Get the PATH environment variable
  String? path = Platform.environment['PATH'];

  if (path != null) {
    // Split the PATH into individual directories
    List<String> directories = path.split(Platform.isWindows ? ';' : ':');

    // Check each directory for the flutter executable
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
