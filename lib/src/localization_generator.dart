import 'dart:io';

import 'package:path/path.dart' as path;

import 'package:l10m/errors/duplicate_key_exception.dart';
import 'package:l10m/errors/key_not_found_exception.dart';
import 'package:l10m/src/models/gen_l10n_request.dart';
import 'package:l10m/src/models/l10m_config.dart';
import 'package:l10m/src/services/arb_validator.dart';
import 'package:l10m/src/services/flutter_gen_l10n_runner.dart';
import 'package:l10m/src/utils/string_utils.dart';

enum _LogLevel { info, success, warning, error }

class LocalizationGenerator {
  LocalizationGenerator({
    FlutterGenL10nRunner? flutterRunner,
    ArbValidator? arbValidator,
  })  : _flutterRunner = flutterRunner ?? const FlutterGenL10nRunner(),
        _arbValidator = arbValidator ?? const ArbValidator();

  final FlutterGenL10nRunner _flutterRunner;
  final ArbValidator _arbValidator;

  Future<void> generateModulesTranslations({
    required String modulePath,
    required String outputFolder,
    required String templateArbFile,
    required bool nullableGetter,
    Map<String, ModuleConfig>? modules,
  }) async {
    final modulesDirectory = Directory(path.normalize(modulePath));
    final entries = modulesDirectory
        .listSync()
        .whereType<Directory>()
        .toList(growable: false);

    final flutterExecutable = await _flutterRunner.findFlutterExecutable();
    final errors = <String>[];

    for (final featureDirectory in entries) {
      final featureName = path.basename(featureDirectory.path);
      final moduleConfig = modules?[featureName];
      final arbDirectory = path.join(featureDirectory.path, 'l10n');
      final outputDirectory = path.join(
          featureDirectory.path, moduleConfig?.outputFolder ?? outputFolder);

      final error = await _generateLocalization(
        label: '"$featureName"',
        request: GenL10nRequest(
          arbDirectory: path.normalize(arbDirectory),
          outputDirectory: path.normalize(outputDirectory),
          outputClass:
              '${underscoreToCamelCase(capitalize(featureName))}Localizations',
          templateArbFile:
              moduleConfig?.templateArbFile ?? templateArbFile,
          outputLocalizationFile:
              '${camelCaseToUnderscore(featureName)}_localizations.dart',
          nullableGetter: moduleConfig?.nullableGetter ?? nullableGetter,
        ),
        flutterExecutable: flutterExecutable,
      );

      if (error != null) {
        errors.add(error);
      }
    }

    _throwIfAny(errors);
  }

  Future<void> generateOnlyModuleTranslations({
    required String modulePath,
    required String outputFolder,
    required String templateArbFile,
    required bool nullableGetter,
    required String generateModule,
  }) async {
    final featureDirectory =
        Directory(path.normalize(path.join(modulePath, generateModule)));

    final error = await _generateLocalization(
      label: '"$generateModule"',
      request: GenL10nRequest(
        arbDirectory: path.normalize(path.join(featureDirectory.path, 'l10n')),
        outputDirectory:
            path.normalize(path.join(featureDirectory.path, outputFolder)),
        outputClass:
            '${underscoreToCamelCase(capitalize(generateModule))}Localizations',
        templateArbFile: templateArbFile,
        outputLocalizationFile:
            '${camelCaseToUnderscore(generateModule)}_localizations.dart',
        nullableGetter: nullableGetter,
      ),
      flutterExecutable: await _flutterRunner.findFlutterExecutable(),
      skipIfMissingArbDir: true,
    );

    if (error != null) {
      throw Exception(error);
    }
  }

  Future<void> generateRootTranslations({
    required String rootPath,
    required String outputFolder,
    required String templateArbFile,
    required bool nullableGetter,
  }) async {
    final outputDirectory = path.normalize(path.join(rootPath, outputFolder));
    final arbDirectory = path.normalize(path.join(rootPath, 'l10n'));

    final error = await _generateLocalization(
      label: 'root',
      request: GenL10nRequest(
        arbDirectory: arbDirectory,
        outputDirectory: outputDirectory,
        outputClass: 'RootLocalizations',
        templateArbFile: templateArbFile,
        outputLocalizationFile: 'root_localizations.dart',
        nullableGetter: nullableGetter,
      ),
      flutterExecutable: await _flutterRunner.findFlutterExecutable(),
      skipIfMissingArbDir: true,
    );

    if (error != null) {
      throw Exception(error);
    }
  }

  Future<String?> _generateLocalization({
    required String label,
    required GenL10nRequest request,
    required String flutterExecutable,
    bool skipIfMissingArbDir = false,
  }) async {
    final arbDir = Directory(request.arbDirectory);

    if (!await arbDir.exists()) {
      if (skipIfMissingArbDir) {
        _log(
            'Skipping translations for $label because no .arb files were found.');
        return null;
      }

      return 'No translations found in ${request.arbDirectory} for $label';
    }

    _log('Generating translations for $label ...', level: _LogLevel.info);

    try {
      await _arbValidator.validate(
        request.arbDirectory,
        request.templateArbFile,
        generatedFolderPath: request.outputDirectory,
      );

      final result = await _flutterRunner.runGenL10n(
        flutterExecutable: flutterExecutable,
        arguments: request.toArgumentList(),
      );

      _logProcessStreams(result);

      if (result.exitCode != 0) {
        throw Exception(result.stderr.toString().trim().isEmpty
            ? result.stdout
            : result.stderr);
      }

      _log('Generated translations for $label.', level: _LogLevel.success);
      return null;
    } on KeyNotFoundException catch (e) {
      _log('Failed to generate translations for $label: ${e.toString()}',
          level: _LogLevel.error);
      return e.toString();
    } on DuplicateKeyException catch (e) {
      _log('Failed to generate translations for $label: ${e.toString()}',
          level: _LogLevel.error);
      return e.toString();
    } catch (e) {
      _log('Failed to generate translations for $label: $e',
          level: _LogLevel.error);
      return e.toString();
    }
  }

  void _logProcessStreams(ProcessResult result) {
    final stdoutContent = result.stdout.toString().trim();
    final stderrContent = result.stderr.toString().trim();

    if (stdoutContent.isNotEmpty) {
      for (final line in stdoutContent.split('\n')) {
        final message = line.trim();
        if (message.isNotEmpty) {
          _log(message, level: _LogLevel.info);
        }
      }
    }

    if (stderrContent.isNotEmpty) {
      for (final line in stderrContent.split('\n')) {
        final message = line.trim();
        if (message.isNotEmpty) {
          _log(message, level: _LogLevel.warning);
        }
      }
    }
  }

  void _throwIfAny(List<String> errors) {
    if (errors.isEmpty) {
      return;
    }

    throw Exception(errors.join('\n'));
  }

  void _log(String message, {_LogLevel level = _LogLevel.info}) {
    String prefix;
    switch (level) {
      case _LogLevel.success:
        prefix = '✅';
        break;
      case _LogLevel.warning:
        prefix = '⚠️';
        break;
      case _LogLevel.error:
        prefix = '❌';
        break;
      case _LogLevel.info:
      default:
        prefix = 'ℹ️ ';
        break;
    }

    print('[l10m] $prefix $message');
  }
}
