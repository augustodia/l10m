import 'package:args/args.dart';
import 'package:l10m/l10m.dart' as l10m;

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption('module-path',
        abbr: 'm',
        defaultsTo: 'lib/modules',
        help: 'Path to the modules folder')
    ..addOption('output-folder',
        abbr: 'o',
        defaultsTo: 'l10n/generated',
        help: 'Output folder for the generated files')
    ..addFlag('generate-root',
        negatable: true, help: 'Generate root translations', defaultsTo: true)
    ..addOption('root-path',
        abbr: 'r',
        defaultsTo: 'lib',
        help:
            'Path to the root folder where the localization files are located')
    ..addOption('template-arb-file',
        abbr: 't',
        defaultsTo: 'intl_en.arb',
        help: 'Path to the template arb file')
    ..addFlag('nullable-getter',
        help: 'Generate the getter methods as nullable',
        negatable: true,
        defaultsTo: true)
    ..addFlag('help', abbr: 'h', help: 'Show the help', negatable: false);

  var argResults = parser.parse(arguments);

  if (argResults['help'] == true) {
    print(parser.usage);
    return;
  }

  String modulePath = argResults['module-path'];
  String outputFolder = argResults['output-folder'];
  bool generateRoot = argResults['generate-root'];
  String rootPath = argResults['root-path'];
  String templateArbFile = argResults['template-arb-file'];
  bool nullableGetter = argResults['nullable-getter'];

  if (generateRoot) {
    await l10m.generateRootTranslations(
        rootPath: rootPath,
        outputFolder: outputFolder,
        templateArbFile: templateArbFile);
  }

  l10m.generateModulesTranslations(
      modulePath: modulePath,
      outputFolder: outputFolder,
      templateArbFile: templateArbFile,
      nullableGetter: nullableGetter);
}
