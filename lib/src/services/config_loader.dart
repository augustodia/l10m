import 'dart:io';
import 'package:yaml/yaml.dart';
import 'package:l10m/src/models/l10m_config.dart';

class ConfigLoader {
  Future<L10mConfig?> loadConfig() async {
    final configFile = _findConfigFile();
    if (configFile == null) {
      return null;
    }

    final content = await configFile.readAsString();
    if (configFile.path.endsWith('.yaml') || configFile.path.endsWith('.yml')) {
      return _parseYaml(content);
    } else {
      // Assuming JSON if not YAML, though we only look for .l10m.yaml/json
      // But for now let's stick to what we found.
      // Actually, if we want to support JSON properly we might need dart:convert
      // But yaml package can parse JSON too as it is a superset.
      return _parseYaml(content);
    }
  }

  File? _findConfigFile() {
    final files = [
      'l10m.yaml',
      'l10m.yml',
      'l10m.json',
      '.l10m.yaml',
      '.l10m.yml',
      '.l10m.json',
    ];

    for (final file in files) {
      final f = File(file);
      if (f.existsSync()) {
        return f;
      }
    }
    return null;
  }

  L10mConfig _parseYaml(String content) {
    final yamlMap = loadYaml(content);
    if (yamlMap is Map) {
      return L10mConfig.fromJson(Map<String, dynamic>.from(_convertYamlMap(yamlMap)));
    }
    return const L10mConfig();
  }

  Map<String, dynamic> _convertYamlMap(Map map) {
    final result = <String, dynamic>{};
    for (final entry in map.entries) {
      if (entry.value is Map) {
        result[entry.key.toString()] = _convertYamlMap(entry.value);
      } else {
        result[entry.key.toString()] = entry.value;
      }
    }
    return result;
  }
}
