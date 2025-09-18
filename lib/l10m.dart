import 'dart:async';

import 'package:l10m/src/localization_generator.dart';
import 'package:l10m/src/services/arb_validator.dart';
import 'package:l10m/src/services/flutter_gen_l10n_runner.dart';

export 'src/utils/string_utils.dart'
    show capitalize, underscoreToCamelCase, camelCaseToUnderscore;

final LocalizationGenerator _generator = LocalizationGenerator();
const ArbValidator _validator = ArbValidator();
const FlutterGenL10nRunner _flutterRunner = FlutterGenL10nRunner();

Future<void> generateModulesTranslations({
  required String modulePath,
  required String outputFolder,
  required String templateArbFile,
  required bool nullableGetter,
}) {
  return _generator.generateModulesTranslations(
    modulePath: modulePath,
    outputFolder: outputFolder,
    templateArbFile: templateArbFile,
    nullableGetter: nullableGetter,
  );
}

Future<void> generateOnlyModuleTranslations({
  required String modulePath,
  required String outputFolder,
  required String templateArbFile,
  required bool nullableGetter,
  required String generateModule,
}) {
  return _generator.generateOnlyModuleTranslations(
    modulePath: modulePath,
    outputFolder: outputFolder,
    templateArbFile: templateArbFile,
    nullableGetter: nullableGetter,
    generateModule: generateModule,
  );
}

Future<void> generateRootTranslations({
  required String rootPath,
  required String outputFolder,
  required String templateArbFile,
  required bool nullableGetter,
}) {
  return _generator.generateRootTranslations(
    rootPath: rootPath,
    outputFolder: outputFolder,
    templateArbFile: templateArbFile,
    nullableGetter: nullableGetter,
  );
}

Future<void> checkLocalizationKeys(
  String folderPath,
  String templateArbFile, {
  String? generatedFolderPath,
}) {
  return _validator.validate(
    folderPath,
    templateArbFile,
    generatedFolderPath: generatedFolderPath,
  );
}

Future<String> findFlutterExecutable() {
  return _flutterRunner.findFlutterExecutable();
}
