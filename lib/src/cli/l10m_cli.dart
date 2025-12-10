import 'dart:io';

import 'package:args/args.dart';
import 'package:l10m/l10m.dart' as l10m;
import 'package:l10m/src/services/aggregator_generator.dart';
import 'package:l10m/src/services/config_loader.dart';
import 'package:l10m/src/utils/logger.dart';
import 'package:path/path.dart' as path;

class L10mCli {
  final ConfigLoader _configLoader;
  final AggregatorGenerator _aggregatorGenerator;

  L10mCli({
    ConfigLoader? configLoader,
    AggregatorGenerator? aggregatorGenerator,
  })  : _configLoader = configLoader ?? ConfigLoader(),
        _aggregatorGenerator = aggregatorGenerator ?? AggregatorGenerator();

  Future<void> run(List<String> arguments) async {
    final parser = _createParser();
    final argResults = parser.parse(arguments);

    Logger().configure(
      verbose: argResults['verbose'] as bool,
      useColors: !(argResults['no-color'] as bool),
    );

    if (argResults['help'] == true) {
      print(parser.usage);
      exit(0);
    }

    final config = await _configLoader.loadConfig();

    String modulePath =
        argResults['module-path'] ?? config?.modulePath ?? 'lib/modules';
    String outputFolder =
        argResults['output-folder'] ?? config?.outputFolder ?? 'l10n/generated';
    bool generateRoot = argResults.wasParsed('generate-root')
        ? argResults['generate-root']
        : config?.generateRoot ?? true;
    String rootPath = argResults['root-path'] ?? config?.rootPath ?? 'lib';
    String templateArbFile = argResults['template-arb-file'] ??
        config?.templateArbFile ??
        'intl_en.arb';
    bool nullableGetter = argResults.wasParsed('nullable-getter')
        ? argResults['nullable-getter']
        : config?.nullableGetter ?? true;
    String? generateModule = argResults['generate-module'];
    bool generateOnlyRoot = argResults['generate-only-root'];
    bool generateOnlyModule = argResults['generate-only-module'];
    bool check = argResults['check'];
    String aggregatorFile = argResults['aggregator-file'];
    bool noAggregator = argResults['no-aggregator'];

    try {
      if (check) {
        await _runCheck(
          modulePath: modulePath,
          rootPath: rootPath,
          templateArbFile: templateArbFile,
          generateRoot: generateRoot,
          config: config,
        );
        return;
      }

      try {
        if (generateRoot) {
          await l10m.generateRootTranslations(
            rootPath: rootPath,
            outputFolder: outputFolder,
            templateArbFile: templateArbFile,
            nullableGetter: nullableGetter,
          );

          if (generateOnlyRoot) exit(0);
        }

        if (generateOnlyModule && generateModule != null) {
          await l10m.generateOnlyModuleTranslations(
            modulePath: modulePath,
            outputFolder: outputFolder,
            templateArbFile: templateArbFile,
            nullableGetter: nullableGetter,
            generateModule: generateModule,
          );
          exit(0);
        }

        await l10m.generateModulesTranslations(
            modulePath: modulePath,
            outputFolder: outputFolder,
            templateArbFile: templateArbFile,
            nullableGetter: nullableGetter,
            modules: config?.modules);
      } catch (e) {
        Logger().e(e.toString());
        // Continue to aggregator generation
      }

      if (!noAggregator) {
        await _aggregatorGenerator.generate(
          rootPath: rootPath,
          modulePath: modulePath,
          outputFolder: outputFolder,
          aggregatorOutputFile: aggregatorFile,
          modulesConfig: config?.modules,
        );
      }

      exit(0);
    } catch (e) {
      Logger().e(e.toString());
      exit(1);
    }
  }

  ArgParser _createParser() {
    return ArgParser()
      ..addOption('module-path',
          abbr: 'm', help: 'Path to the modules folder')
      ..addOption('output-folder',
          abbr: 'o', help: 'Output folder for the generated files')
      ..addFlag('generate-root',
          negatable: true, help: 'Generate root translations')
      ..addOption('root-path',
          abbr: 'r',
          help:
              'Path to the root folder where the localization files are located')
      ..addOption('template-arb-file',
          abbr: 't', help: 'Path to the template arb file')
      ..addFlag('nullable-getter',
          help: 'Generate the getter methods as nullable', negatable: true)
      ..addOption(
        'generate-module',
        abbr: 'g',
        help: 'Generate the module translations',
        defaultsTo: null,
      )
      ..addFlag(
        'generate-only-root',
        help: 'Generate only the root translations',
        negatable: false,
        defaultsTo: false,
      )
      ..addFlag(
        'generate-only-module',
        help: 'Generate only the module translations',
        negatable: false,
        defaultsTo: false,
      )
      ..addFlag(
        'check',
        help: 'Validate translations without generating files',
        negatable: false,
        defaultsTo: false,
      )
      ..addOption(
        'aggregator-file',
        help: 'Path to the generated aggregator file',
        defaultsTo: 'lib/translate.dart',
      )
      ..addFlag(
        'no-aggregator',
        help: 'Disable aggregator generation',
        negatable: false,
        defaultsTo: false,
      )
      ..addFlag(
        'verbose',
        abbr: 'v',
        help: 'Enable verbose logging',
        negatable: false,
        defaultsTo: false,
      )
      ..addFlag(
        'no-color',
        help: 'Disable colored output',
        negatable: false,
        defaultsTo: false,
      )
      ..addFlag('help', abbr: 'h', help: 'Show the help', negatable: false);
  }

  Future<void> _runCheck({
    required String modulePath,
    required String rootPath,
    required String templateArbFile,
    required bool generateRoot,
    l10m.L10mConfig? config,
  }) async {
    bool hasError = false;

    if (generateRoot) {
      try {
        await l10m.checkLocalizationKeys(
          path.join(rootPath, 'l10n'),
          templateArbFile,
        );
        await l10m.checkLocalizationKeys(
          path.join(rootPath, 'l10n'),
          templateArbFile,
        );
        Logger().s('Root translations are valid.');
      } catch (e) {
        Logger().e('Root translations validation failed: $e');
        hasError = true;
      }
    }

    final modulesDirectory = Directory(path.normalize(modulePath));
    if (await modulesDirectory.exists()) {
      final entries = modulesDirectory
          .listSync()
          .whereType<Directory>()
          .toList(growable: false);

      for (final featureDirectory in entries) {
        final featureName = path.basename(featureDirectory.path);
        final moduleConfig = config?.modules?[featureName];
        final arbDirectory = path.join(featureDirectory.path, 'l10n');
        final template = moduleConfig?.templateArbFile ?? templateArbFile;

        try {
          await l10m.checkLocalizationKeys(
            arbDirectory,
            template,
          );
          await l10m.checkLocalizationKeys(
            arbDirectory,
            template,
          );
          Logger().s('Module "$featureName" translations are valid.');
        } catch (e) {
          Logger().e(
              'Module "$featureName" translations validation failed: $e');
          hasError = true;
        }
      }
    }

    if (hasError) {
      exit(1);
    } else {
      exit(0);
    }
  }
}

