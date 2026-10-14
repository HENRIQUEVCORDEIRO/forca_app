class EntriesLoadException implements Exception {
  final String message;
  final int? entryIndex;

  const EntriesLoadException(this.message, {this.entryIndex});

  @override
  String toString() {
    final location = entryIndex == null
        ? ''
        : ' (entrada de índice $entryIndex)';
    return 'EntriesLoadException: $message$location';
  }
}
