import 'dart:async';
import 'dart:io';

import 'package:l10m/src/utils/logger.dart';
import 'package:test/test.dart';

void main() {
  group('Logger', () {
    late Logger logger;

    setUp(() {
      logger = Logger();
      // Reset configuration
      logger.configure(verbose: false, useColors: false);
    });

    test('should be a singleton', () {
      final logger1 = Logger();
      final logger2 = Logger();
      expect(logger1, same(logger2));
    });

    test('should configure correctly', () {
      logger.configure(verbose: true, useColors: true);
      // Since we can't easily inspect private fields, we assume it works if no error is thrown
      // and behavior changes (which we'll test below by capturing print).
    });

    test('should log info message', () {
      expect(() => logger.i('test info'), prints(contains('[l10m] INFO  test info')));
    });

    test('should log success message', () {
      expect(() => logger.s('test success'), prints(contains('[l10m] SUCCESS  test success')));
    });

    test('should log warning message', () {
      expect(() => logger.w('test warning'), prints(contains('[l10m] WARN  test warning')));
    });

    // Note: Error logging uses stderr, which is harder to capture with `prints`.
    // We can skip verifying stderr content for now or use a custom zone.
    
    test('should log verbose message when verbose is true', () {
      logger.configure(verbose: true, useColors: false);
      expect(() => logger.v('test verbose'), prints(contains('[l10m] DEBUG  test verbose')));
    });

    test('should NOT log verbose message when verbose is false', () {
      logger.configure(verbose: false, useColors: false);
      expect(() => logger.v('test verbose'), prints(isEmpty));
    });

    test('should use colors when enabled', () {
      logger.configure(verbose: false, useColors: true);
      // \x1B[34m is blue (INFO)
      expect(() => logger.i('test color'), prints(contains('\x1B[34m')));
    });
    
    test('should NOT use colors when disabled', () {
      logger.configure(verbose: false, useColors: false);
      expect(() => logger.i('test no color'), prints(isNot(contains('\x1B['))));
    });
  });
}
