class GenL10nRequest {
  const GenL10nRequest({
    required this.arbDirectory,
    required this.outputDirectory,
    required this.outputClass,
    required this.templateArbFile,
    required this.outputLocalizationFile,
    required this.nullableGetter,
  });

  final String arbDirectory;
  final String outputDirectory;
  final String outputClass;
  final String templateArbFile;
  final String outputLocalizationFile;
  final bool nullableGetter;

  List<String> toArgumentList() {
    return [
      'gen-l10n',
      '--arb-dir',
      arbDirectory,
      '--output-dir',
      outputDirectory,
      '--no-synthetic-package',
      '--output-class',
      outputClass,
      '--template-arb-file',
      templateArbFile,
      '--output-localization-file',
      outputLocalizationFile,
      if (!nullableGetter) '--no-nullable-getter',
    ];
  }
}
