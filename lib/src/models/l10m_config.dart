class L10mConfig {
  final String? modulePath;
  final String? outputFolder;
  final String? rootPath;
  final String? templateArbFile;
  final bool? nullableGetter;
  final bool? generateRoot;
  final Map<String, ModuleConfig>? modules;

  const L10mConfig({
    this.modulePath,
    this.outputFolder,
    this.rootPath,
    this.templateArbFile,
    this.nullableGetter,
    this.generateRoot,
    this.modules,
  });

  factory L10mConfig.fromJson(Map<String, dynamic> json) {
    return L10mConfig(
      modulePath: json['module-path'] as String?,
      outputFolder: json['output-folder'] as String?,
      rootPath: json['root-path'] as String?,
      templateArbFile: json['template-arb-file'] as String?,
      nullableGetter: json['nullable-getter'] as bool?,
      generateRoot: json['generate-root'] as bool?,
      modules: (json['modules'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(
          key,
          ModuleConfig.fromJson(value as Map<String, dynamic>),
        ),
      ),
    );
  }
}

class ModuleConfig {
  final String? outputFolder;
  final String? templateArbFile;
  final bool? nullableGetter;

  const ModuleConfig({
    this.outputFolder,
    this.templateArbFile,
    this.nullableGetter,
  });

  factory ModuleConfig.fromJson(Map<String, dynamic> json) {
    return ModuleConfig(
      outputFolder: json['output-folder'] as String?,
      templateArbFile: json['template-arb-file'] as String?,
      nullableGetter: json['nullable-getter'] as bool?,
    );
  }
}
