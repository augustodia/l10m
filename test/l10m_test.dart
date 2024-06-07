import 'dart:io';
import 'package:l10m/errors/key_not_found_exception.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
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
      final file = File('${directory.path}/intl_en.arb');
      await file.writeAsString('{"key1": "value1", "key2": "value2"}');

      final file2 = File('${directory.path}/app_pt.arb');
      await file2.writeAsString('{"key1": "value1", "key2": "value2"}');

      final file3 = File('${directory.path}/app_es.arb');
      await file3.writeAsString('{"key1": "value1", "key2": "value2"}');

      expect(checkLocalizationKeys(directory.path, 'intl_en.arb'), completes);
    });

    test('when checkLocalizationKeys is called with exception', () async {
      final file = File('${directory.path}/intl_en.arb');
      await file.writeAsString('{"key1": "value1", "key2": "value2"}');

      final file2 = File('${directory.path}/app_pt.arb');
      await file2.writeAsString('{"key1": "value1"}');

      final file3 = File('${directory.path}/app_es.arb');
      await file3.writeAsString('{"key1": "value1", "key2": "value2"}');

      expect(
        checkLocalizationKeys(directory.path, 'intl_en.arb'),
        throwsA(isA<KeyNotFoundException>()
            .having((e) => e.keyNotFound, 'keyNotFound', 'key2')),
      );
    });

    test('when generateRootTranslations is called withou exception', () async {
      final l10nDirectory = Directory('${directory.path}/l10n');
      l10nDirectory.createSync();

      final file = File('${l10nDirectory.path}/intl_en.arb');
      await file.writeAsString('{"key1": "value1", "key2": "value2"}');

      final file2 = File('${l10nDirectory.path}/app_pt.arb');
      await file2.writeAsString('{"key1": "value1", "key2": "value2"}');

      final file3 = File('${l10nDirectory.path}/app_es.arb');
      await file3.writeAsString('{"key1": "value1", "key2": "value2"}');

      final outputPath = 'l10n/output';

      await generateRootTranslations(
          rootPath: directory.path,
          outputFolder: outputPath,
          templateArbFile: 'intl_en.arb');

      final generatedFile =
          File('${directory.path}/$outputPath/root_localizations.dart');
      expect(await generatedFile.exists(), isTrue);
    });

    test('when generateRootTranslations is called with exception', () async {
      final l10nDirectory = Directory('${directory.path}/l10n');
      l10nDirectory.createSync();

      final file = File('${l10nDirectory.path}/intl_en.arb');
      await file.writeAsString('{"key1": "value1", "key2": "value2"}');

      final file2 = File('${l10nDirectory.path}/app_pt.arb');
      await file2.writeAsString('{"key1": "value1"}');

      final file3 = File('${l10nDirectory.path}/app_es.arb');
      await file3.writeAsString('{"key1": "value1", "key2": "value2"}');

      final generatedFile =
          File('${directory.path}/output/root_localizations.dart');
      expect(await generatedFile.exists(), isFalse);
    });

    test('when generateModulesTranslations is called withou exception',
        () async {
      final moduleDirectory = Directory('${directory.path}/modules');
      moduleDirectory.createSync();

      final featureDirectory = Directory('${moduleDirectory.path}/feature');
      featureDirectory.createSync();

      final l10nDirectory = Directory('${featureDirectory.path}/l10n');
      l10nDirectory.createSync();

      final file = File('${l10nDirectory.path}/intl_en.arb');
      await file.writeAsString('{"key1": "value1", "key2": "value2"}');

      final file2 = File('${l10nDirectory.path}/app_pt.arb');
      await file2.writeAsString('{"key1": "value1", "key2": "value2"}');

      final file3 = File('${l10nDirectory.path}/app_es.arb');
      await file3.writeAsString('{"key1": "value1", "key2": "value2"}');

      await generateModulesTranslations(
        modulePath: moduleDirectory.path,
        outputFolder: 'output',
        templateArbFile: 'intl_en.arb',
        nullableGetter: true,
      );

      final generatedFile =
          File('${featureDirectory.path}/output/feature_localizations.dart');
      expect(await generatedFile.exists(), isTrue);
    });

    test(
        'when generateModulesTranslations generates underscored file name for camelCase module directory',
        () async {
      final moduleDirectory = Directory('${directory.path}/modules');
      moduleDirectory.createSync();

      final featureName = 'FeatureToTest';

      final featureDirectory =
          Directory('${moduleDirectory.path}/$featureName');
      featureDirectory.createSync();

      final l10nDirectory = Directory('${featureDirectory.path}/l10n');
      l10nDirectory.createSync();

      final file = File('${l10nDirectory.path}/intl_en.arb');
      await file.writeAsString('{"key1": "value1", "key2": "value2"}');

      final file2 = File('${l10nDirectory.path}/app_pt.arb');
      await file2.writeAsString('{"key1": "value1", "key2": "value2"}');

      final file3 = File('${l10nDirectory.path}/app_es.arb');
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
      final moduleDirectory = Directory('${directory.path}/modules');
      moduleDirectory.createSync();

      final featureDirectory = Directory('${moduleDirectory.path}/feature');
      featureDirectory.createSync();

      final l10nDirectory = Directory('${featureDirectory.path}/l10n');
      l10nDirectory.createSync();

      final file = File('${l10nDirectory.path}/intl_en.arb');
      await file.writeAsString('{"key1": "value1", "key2": "value2"}');

      final file2 = File('${l10nDirectory.path}/app_pt.arb');
      await file2.writeAsString('{"key1": "value1"}');

      final file3 = File('${l10nDirectory.path}/app_es.arb');
      await file3.writeAsString('{"key1": "value1", "key2": "value2"}');

      final generatedFile =
          File('${featureDirectory.path}/output/feature_localizations.dart');
      expect(await generatedFile.exists(), isFalse);
    });
  });
}
