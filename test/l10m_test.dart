import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:l10m/errors/duplicate_key_exception.dart';
import 'package:l10m/l10m.dart';

void main() {
  group('Tests lib/l10m.dart', () {
    late Directory directory;

    setUp(() async {
      directory = await Directory.systemTemp.createTemp();
      resetMocktailState();
    });

    tearDown(() async {
      await directory.delete(recursive: true);
      resetMocktailState();
    });

    test('Test capitalize', () {
      expect(capitalize('test'), equals('Test'));
      expect(capitalize('TEST'), equals('TEST'));
      expect(capitalize('tEST'), equals('TEST'));
    });

    test('when checkLocalizationKeys is called withou exception', () async {
      final file = File(path.normalize('${directory.path}/intl_en.arb'));
      await file.writeAsString('{"key1": "value1", "key2": "value2"}');

      final file2 = File(path.normalize('${directory.path}/app_pt.arb'));
      await file2.writeAsString('{"key1": "value1", "key2": "value2"}');

      final file3 = File(path.normalize('${directory.path}/app_es.arb'));
      await file3.writeAsString('{"key1": "value1", "key2": "value2"}');

      expect(checkLocalizationKeys(directory.path, 'intl_en.arb'), completes);
    });

    test('when checkLocalizationKeys is called with exception', () async {
      final file = File(path.normalize('${directory.path}/intl_en.arb'));
      await file.writeAsString('{"key1": "value1", "key2": "value2"}');

      final file2 = File(path.normalize('${directory.path}/app_pt.arb'));
      await file2.writeAsString('{"key1": "value1"}');

      final file3 = File(path.normalize('${directory.path}/app_es.arb'));
      await file3.writeAsString('{"key1": "value1", "key2": "value2"}');

      expect(checkLocalizationKeys(directory.path, 'intl_en.arb'),
          throwsException);
    });

    test(
        'when checkLocalizationKeys finds duplicate keys it removes generated folder',
        () async {
      final file = File(path.normalize('${directory.path}/intl_en.arb'));
      await file.writeAsString('{"key1": "value1", "key2": "value2"}');

      final duplicateFile =
          File(path.normalize('${directory.path}/intl_pt.arb'));
      await duplicateFile.writeAsString(
          '{"key1": "value1", "key1": "value2", "key2": "value2"}');

      final generatedDir =
          Directory(path.normalize('${directory.path}/generated'));
      generatedDir.createSync(recursive: true);
      final generatedFile =
          File(path.normalize('${generatedDir.path}/old_localizations.dart'));
      await generatedFile.writeAsString('old-content');

      await expectLater(
        () => checkLocalizationKeys(directory.path, 'intl_en.arb',
            generatedFolderPath: generatedDir.path),
        throwsA(isA<DuplicateKeyException>()),
      );

      expect(await Directory(generatedDir.path).exists(), isFalse);
    });

    test('when generateRootTranslations is called withou exception', () async {
      final l10nDirectory =
          Directory(path.normalize(path.normalize('${directory.path}/l10n')));
      l10nDirectory.createSync();

      final file = File(path.normalize('${l10nDirectory.path}/intl_en.arb'));
      await file.writeAsString('{"key1": "value1", "key2": "value2"}');

      final file2 = File(path.normalize('${l10nDirectory.path}/app_pt.arb'));
      await file2.writeAsString('{"key1": "value1", "key2": "value2"}');

      final file3 = File(path.normalize('${l10nDirectory.path}/app_es.arb'));
      await file3.writeAsString('{"key1": "value1", "key2": "value2"}');

      final outputPath = 'l10n/output';

      await generateRootTranslations(
          rootPath: directory.path,
          outputFolder: outputPath,
          templateArbFile: 'intl_en.arb',
          nullableGetter: false);

      final generatedFile = File(path
          .normalize('${directory.path}/$outputPath/root_localizations.dart'));
      expect(await generatedFile.exists(), isTrue);
    });

    test('when generateRootTranslations is called with exception', () async {
      final l10nDirectory = Directory(path.normalize('${directory.path}/l10n'));
      l10nDirectory.createSync();

      final file = File(path.normalize('${l10nDirectory.path}/intl_en.arb'));
      await file.writeAsString('{"key1": "value1", "key2": "value2"}');

      final file2 = File(path.normalize('${l10nDirectory.path}/app_pt.arb'));
      await file2.writeAsString('{"key1": "value1"}');

      final file3 = File(path.normalize('${l10nDirectory.path}/app_es.arb'));
      await file3.writeAsString('{"key1": "value1", "key2": "value2"}');

      final generatedFile = File(
          path.normalize('${directory.path}/output/root_localizations.dart'));
      expect(await generatedFile.exists(), isFalse);
    });

    test(
        'when generateRootTranslations finds duplicate keys it removes generated folder',
        () async {
      final l10nDirectory = Directory(path.normalize('${directory.path}/l10n'));
      l10nDirectory.createSync();

      final templateFile =
          File(path.normalize('${l10nDirectory.path}/intl_en.arb'));
      await templateFile.writeAsString('{"key1": "value1", "key2": "value2"}');

      final duplicateFile =
          File(path.normalize('${l10nDirectory.path}/intl_pt.arb'));
      await duplicateFile.writeAsString(
          '{"key1": "value1", "key1": "value2", "key2": "value2"}');

      final otherLanguage =
          File(path.normalize('${l10nDirectory.path}/intl_es.arb'));
      await otherLanguage.writeAsString('{"key1": "value1", "key2": "value2"}');

      final outputFolder = 'l10n/output';
      final outputDirectory =
          Directory(path.normalize('${directory.path}/$outputFolder'));
      outputDirectory.createSync(recursive: true);
      final generatedFile = File(
          path.normalize('${outputDirectory.path}/root_localizations.dart'));
      await generatedFile.writeAsString('old-content');

      await expectLater(
        generateRootTranslations(
          rootPath: directory.path,
          outputFolder: outputFolder,
          templateArbFile: 'intl_en.arb',
          nullableGetter: false,
        ),
        throwsA(isA<Exception>()),
      );

      expect(await outputDirectory.exists(), isFalse);
    });

    test('when generateModulesTranslations is called withou exception',
        () async {
      final moduleDirectory =
          Directory(path.normalize('${directory.path}/modules'));
      moduleDirectory.createSync();

      final featureDirectory =
          Directory(path.normalize('${moduleDirectory.path}/feature'));
      featureDirectory.createSync();

      final l10nDirectory =
          Directory(path.normalize('${featureDirectory.path}/l10n'));
      l10nDirectory.createSync();

      final file = File(path.normalize('${l10nDirectory.path}/intl_en.arb'));
      await file.writeAsString('{"key1": "value1", "key2": "value2"}');

      final file2 = File(path.normalize('${l10nDirectory.path}/intl_pt.arb'));
      await file2.writeAsString('{"key1": "value1", "key2": "value2"}');

      final file3 = File(path.normalize('${l10nDirectory.path}/intl_es.arb'));
      await file3.writeAsString('{"key1": "value1", "key2": "value2"}');

      await generateModulesTranslations(
        modulePath: moduleDirectory.path,
        outputFolder: 'output',
        templateArbFile: 'intl_en.arb',
        nullableGetter: true,
      );

      final generatedFile = File(path.normalize(
          '${featureDirectory.path}/output/feature_localizations.dart'));
      expect(await generatedFile.exists(), isTrue);
    });

    test(
        'when generateModulesTranslations generates underscored file name for camelCase module directory',
        () async {
      final moduleDirectory =
          Directory(path.normalize('${directory.path}/modules'));
      moduleDirectory.createSync();

      final featureName = 'FeatureToTest';

      final featureDirectory =
          Directory(path.normalize('${moduleDirectory.path}/$featureName'));
      featureDirectory.createSync();

      final l10nDirectory =
          Directory(path.normalize('${featureDirectory.path}/l10n'));
      l10nDirectory.createSync();

      final file = File(path.normalize('${l10nDirectory.path}/intl_en.arb'));
      await file.writeAsString('{"key1": "value1", "key2": "value2"}');

      final file2 = File(path.normalize('${l10nDirectory.path}/app_pt.arb'));
      await file2.writeAsString('{"key1": "value1", "key2": "value2"}');

      final file3 = File(path.normalize('${l10nDirectory.path}/app_es.arb'));
      await file3.writeAsString('{"key1": "value1", "key2": "value2"}');

      await generateModulesTranslations(
        modulePath: moduleDirectory.path,
        outputFolder: 'output',
        templateArbFile: 'intl_en.arb',
        nullableGetter: true,
      );

      final generatedFile = File(
          '${featureDirectory.path}/output/feature_to_test_localizations.dart');

      final fileName = generatedFile.path.split('/').last;

      expect(fileName, equals('feature_to_test_localizations.dart'));
      expect(await generatedFile.exists(), isTrue);
    });

    test('when generateModulesTranslations is called with exception', () async {
      final moduleDirectory =
          Directory(path.normalize('${directory.path}/modules'));
      moduleDirectory.createSync();

      final featureDirectory =
          Directory(path.normalize('${moduleDirectory.path}/feature'));
      featureDirectory.createSync();

      final l10nDirectory =
          Directory(path.normalize('${featureDirectory.path}/l10n'));
      l10nDirectory.createSync();

      final file = File(path.normalize('${l10nDirectory.path}/intl_en.arb'));
      await file.writeAsString('{"key1": "value1", "key2": "value2"}');

      final file2 = File(path.normalize('${l10nDirectory.path}/app_pt.arb'));
      await file2.writeAsString('{"key1": "value1"}');

      final file3 = File(path.normalize('${l10nDirectory.path}/app_es.arb'));
      await file3.writeAsString('{"key1": "value1", "key2": "value2"}');

      final generatedFile = File(path.normalize(
          '${featureDirectory.path}/output/feature_localizations.dart'));
      expect(await generatedFile.exists(), isFalse);
    });

    test(
        'when generateOnlyModule only specified module translations are generated',
        () async {
      final moduleDirectory =
          Directory(path.normalize('${directory.path}/modules'));
      moduleDirectory.createSync();

      final featureDirectory =
          Directory(path.normalize('${moduleDirectory.path}/feature'));
      featureDirectory.createSync();

      final feature2Directory =
          Directory(path.normalize('${moduleDirectory.path}/feature2'));
      feature2Directory.createSync();

      final l10nDirectory =
          Directory(path.normalize('${featureDirectory.path}/l10n'));
      l10nDirectory.createSync();

      final file = File(path.normalize('${l10nDirectory.path}/intl_en.arb'));
      await file.writeAsString('{"key1": "value1", "key2": "value2"}');

      final file2 = File(path.normalize('${l10nDirectory.path}/app_pt.arb'));
      await file2.writeAsString('{"key1": "value1", "key2": "value2"}');

      final file3 = File(path.normalize('${l10nDirectory.path}/app_es.arb'));
      await file3.writeAsString('{"key1": "value1", "key2": "value2"}');

      await generateOnlyModuleTranslations(
        modulePath: moduleDirectory.path,
        outputFolder: 'output',
        templateArbFile: 'intl_en.arb',
        nullableGetter: true,
        generateModule: 'feature',
      );

      final generatedFile = File(path.normalize(
          '${featureDirectory.path}/output/feature_localizations.dart'));
      expect(await generatedFile.exists(), isTrue);

      final notGeneratedFile = File(path.normalize(
          '${feature2Directory.path}/output/feature2_localizations.dart'));
      expect(await notGeneratedFile.exists(), isFalse);
    });
  });
}
