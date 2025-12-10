import 'dart:io';

enum LogLevel {
  verbose,
  info,
  success,
  warning,
  error,
}

class Logger {
  static final Logger _instance = Logger._internal();

  factory Logger() {
    return _instance;
  }

  Logger._internal();

  bool _verbose = false;
  bool _useColors = true;

  void configure({bool verbose = false, bool useColors = true}) {
    _verbose = verbose;
    _useColors = useColors;
  }

  void v(String message) {
    if (_verbose) {
      _print(message, level: LogLevel.verbose);
    }
  }

  void i(String message) {
    _print(message, level: LogLevel.info);
  }

  void s(String message) {
    _print(message, level: LogLevel.success);
  }

  void w(String message) {
    _print(message, level: LogLevel.warning);
  }

  void e(String message) {
    _print(message, level: LogLevel.error);
  }

  void _print(String message, {required LogLevel level}) {
    final prefix = _getPrefix(level);
    final color = _getColor(level);
    final reset = _useColors ? '\x1B[0m' : '';
    final coloredPrefix = _useColors ? '$color$prefix$reset' : prefix;
    
    // For error/warning, maybe use stderr?
    // But keeping it simple with print (stdout) for now unless it's critical.
    // Actually, CLI tools usually print errors to stderr.
    if (level == LogLevel.error) {
      stderr.writeln('[l10m] $coloredPrefix $message');
    } else {
      print('[l10m] $coloredPrefix $message');
    }
  }

  String _getPrefix(LogLevel level) {
    switch (level) {
      case LogLevel.success:
        return 'SUCCESS '; // Replaced emoji with text for safety, or use simple chars like [+]
      case LogLevel.warning:
        return 'WARN ';
      case LogLevel.error:
        return 'ERROR ';
      case LogLevel.info:
        return 'INFO ';
      case LogLevel.verbose:
        return 'DEBUG ';
    }
  }

  String _getColor(LogLevel level) {
    if (!_useColors) return '';
    switch (level) {
      case LogLevel.success:
        return '\x1B[32m'; // Green
      case LogLevel.warning:
        return '\x1B[33m'; // Yellow
      case LogLevel.error:
        return '\x1B[31m'; // Red
      case LogLevel.info:
        return '\x1B[34m'; // Blue
      case LogLevel.verbose:
        return '\x1B[36m'; // Cyan
    }
  }
}
