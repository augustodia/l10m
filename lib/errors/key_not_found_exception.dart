class KeyNotFoundException implements Exception {
  KeyNotFoundException([this.message = 'Missing localization keys detected.']);

  final String message;

  @override
  String toString() => message;
}
