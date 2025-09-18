import 'dart:io';

class FlutterGenL10nRunner {
  const FlutterGenL10nRunner();

  Future<String> findFlutterExecutable() async {
    final pathVariable = Platform.environment['PATH'];

    if (pathVariable != null) {
      final directories = pathVariable
          .split(Platform.isWindows ? ';' : ':')
          .where((p) => p.isNotEmpty);

      for (final directory in directories) {
        final flutterPath = Platform.isWindows
            ? '$directory\\flutter.bat'
            : '$directory/flutter';

        if (await File(flutterPath).exists()) {
          return flutterPath;
        }
      }
    }

    return 'flutter';
  }

  Future<ProcessResult> runGenL10n({
    required String flutterExecutable,
    required List<String> arguments,
  }) async {
    return Process.run(flutterExecutable, arguments);
  }
}
