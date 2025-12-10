import 'dart:io';

import 'package:l10m/src/models/l10m_config.dart';
import 'package:l10m/src/utils/string_utils.dart';
import 'package:path/path.dart' as path;

class AggregatorGenerator {
  Future<void> generate({
    required String rootPath,
    required String modulePath,
    required String outputFolder,
    required String aggregatorOutputFile,
    Map<String, ModuleConfig>? modulesConfig,
  }) async {
    final modulesDirectory = Directory(path.normalize(modulePath));
    final entries = modulesDirectory.existsSync()
        ? modulesDirectory
            .listSync()
            .whereType<Directory>()
            .toList(growable: false)
        : <Directory>[];

    final buffer = StringBuffer();
    final imports = <String>[];
    final delegates = <String>[];
    final getters = <String>[];

    // Root
    final rootOutput = path.join(rootPath, outputFolder);
    final rootClass = 'RootLocalizations';
    final rootFile = 'root_localizations.dart';
    final rootImportPath = path.relative(
        path.join(rootOutput, rootFile),
        from: path.dirname(aggregatorOutputFile));

    imports.add("import '$rootImportPath';");
    delegates.add('${rootClass}Delegate()');
    getters.add('''
  static $rootClass root(BuildContext context) {
    return $rootClass.of(context);
  }
''');

    // Modules
    for (final featureDirectory in entries) {
      final featureName = path.basename(featureDirectory.path);
      final moduleConfig = modulesConfig?[featureName];
      final outputDirectory = path.join(
          featureDirectory.path, moduleConfig?.outputFolder ?? outputFolder);
      
      final moduleClass = '${underscoreToCamelCase(capitalize(featureName))}Localizations';
      final moduleFile = '${camelCaseToUnderscore(featureName)}_localizations.dart';
      final moduleImportPath = path.relative(
          path.join(outputDirectory, moduleFile),
          from: path.dirname(aggregatorOutputFile));

      imports.add("import '$moduleImportPath';");
      delegates.add('${moduleClass}Delegate()');
      getters.add('''
  static $moduleClass ${underscoreToCamelCase(featureName)}(BuildContext context) {
    return $moduleClass.of(context);
  }
''');
    }

    final locales = <String>{};
    
    // Scan root for locales
    final rootArbDirectory = Directory(path.join(rootPath, 'l10n'));
    if (rootArbDirectory.existsSync()) {
      locales.addAll(_findLocales(rootArbDirectory));
    }

    // Scan modules for locales
    for (final featureDirectory in entries) {
      final arbDirectory = Directory(path.join(featureDirectory.path, 'l10n'));
      if (arbDirectory.existsSync()) {
        locales.addAll(_findLocales(arbDirectory));
      }
    }

    buffer.writeln("import 'package:flutter/material.dart';");
    buffer.writeln();
    buffer.writeln(imports.join('\n'));
    buffer.writeln();
    buffer.writeln('class Translate {');
    buffer.writeln('  static List<LocalizationsDelegate> localizationsDelegates = [');
    for (final delegate in delegates) {
      buffer.writeln('    $delegate,');
    }
    buffer.writeln('  ];');
    buffer.writeln();
    buffer.writeln('  static List<Locale> supportedLocales = [');
    for (final locale in locales) {
      final parts = locale.split('_');
      if (parts.length == 2) {
        buffer.writeln("    const Locale('${parts[0]}', '${parts[1]}'),");
      } else {
        buffer.writeln("    const Locale('$locale'),");
      }
    }
    buffer.writeln('  ];');
    buffer.writeln();
    buffer.writeln(getters.join('\n'));
    buffer.writeln('}');

    final file = File(aggregatorOutputFile);
    if (!await file.parent.exists()) {
      await file.parent.create(recursive: true);
    }
    await file.writeAsString(buffer.toString());
    print('✅ Generated aggregator at $aggregatorOutputFile');
  }

  Set<String> _findLocales(Directory directory) {
    final locales = <String>{};
    final files = directory.listSync().whereType<File>();
    final regex = RegExp(r'intl_([a-zA-Z0-9_]+)\.arb');

    for (final file in files) {
      final match = regex.firstMatch(path.basename(file.path));
      if (match != null) {
        locales.add(match.group(1)!);
      }
    }
    return locales;
  }
}
