class DuplicateKeyException implements Exception {
  DuplicateKeyException(this.message);

  final String message;

  @override
  String toString() => message;
}
