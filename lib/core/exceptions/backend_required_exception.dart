class BackendRequiredException implements Exception {
  final String message;
  BackendRequiredException(this.message);

  @override
  String toString() => message;
}
