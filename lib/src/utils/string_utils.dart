String capitalize(String text) {
  if (text.isEmpty) {
    return text;
  }

  return text[0].toUpperCase() + text.substring(1);
}

String underscoreToCamelCase(String text) {
  if (text.isEmpty) {
    return text;
  }

  return text
      .split('_')
      .where((segment) => segment.isNotEmpty)
      .map(capitalize)
      .join();
}

String camelCaseToUnderscore(String text) {
  if (text.isEmpty) {
    return text;
  }

  return text.replaceAllMapped(RegExp(r'[A-Z]'), (match) {
    final letter = match.group(0)!.toLowerCase();
    return match.start == 0 ? letter : '_$letter';
  });
}
