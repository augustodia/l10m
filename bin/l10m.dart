import 'dart:io';

import 'package:args/args.dart';
import 'package:l10m/l10m.dart' as l10m;

import 'package:l10m/src/services/config_loader.dart';

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption('module-path',
        abbr: 'm',
        help: 'Path to the modules folder')
    ..addOption('output-folder',
        abbr: 'o',
        help: 'Output folder for the generated files')
    ..addFlag('generate-root',
        negatable: true, help: 'Generate root translations')
    ..addOption('root-path',
        abbr: 'r',
        help:
            'Path to the root folder where the localization files are located')
    ..addOption('template-arb-file',
        abbr: 't',
        help: 'Path to the template arb file')
    ..addFlag('nullable-getter',
        help: 'Generate the getter methods as nullable',
        negatable: true)
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
    ..addFlag('help', abbr: 'h', help: 'Show the help', negatable: false);

  var argResults = parser.parse(arguments);

  if (argResults['help'] == true) {
    print(parser.usage);
    exit(0);
  }

  final configLoader = ConfigLoader();
  final config = await configLoader.loadConfig();

  String modulePath = argResults['module-path'] ?? config?.modulePath ?? 'lib/modules';
  String outputFolder = argResults['output-folder'] ?? config?.outputFolder ?? 'l10n/generated';
  bool generateRoot = argResults.wasParsed('generate-root')
      ? argResults['generate-root']
      : config?.generateRoot ?? true;
  String rootPath = argResults['root-path'] ?? config?.rootPath ?? 'lib';
  String templateArbFile = argResults['template-arb-file'] ?? config?.templateArbFile ?? 'intl_en.arb';
  bool nullableGetter = argResults.wasParsed('nullable-getter')
      ? argResults['nullable-getter']
      : config?.nullableGetter ?? true;
  String? generateModule = argResults['generate-module'];
  bool generateOnlyRoot = argResults['generate-only-root'];
  bool generateOnlyModule = argResults['generate-only-module'];

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

    exit(0);
  } catch (e) {
    stderr.writeln(e);
    exit(1);
  }
}
