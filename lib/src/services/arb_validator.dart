import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;

import 'package:l10m/errors/duplicate_key_exception.dart';
import 'package:l10m/errors/key_not_found_exception.dart';

class ArbValidator {
  const ArbValidator();

  Future<void> validate(
    String folderPath,
    String templateArbFile, {
    String? generatedFolderPath,
  }) async {
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
        'Template arb file "$templateArbFile" was not found in $folderPath',
      );
    }

    final templateContent = await templateFile.readAsString();
    final templateJson = jsonDecode(templateContent) as Map<String, dynamic>;
    final templateKeys = templateJson.keys.toSet();

    final missingKeys = <String, List<String>>{};
    final duplicateKeys = <String, Set<String>>{};

    for (final file in arbFiles) {
      final content = await file.readAsString();
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
          'Removed generated localization files at $normalizedPath due to duplicate keys.',
        );
      }
    } catch (e) {
      print(
        'Failed to remove generated localization files at $normalizedPath: $e',
      );
    }
  }
}
