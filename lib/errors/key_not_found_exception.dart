class KeyNotFoundException implements Exception {
  final String keyNotFound;
  final List files;

  KeyNotFoundException({required this.keyNotFound, required this.files});

  @override
  String toString() {
    return 'Key "$keyNotFound" is missing in some files: ${files.join(', ')}';
  }
}
