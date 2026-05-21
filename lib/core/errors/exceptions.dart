/// Exception classes for the data/infrastructure layer.
///
/// These exceptions are thrown by repositories and data sources, then
/// caught and mapped to [Failure] types in the use case layer.
/// They should never leak into the domain or presentation layers.

/// Exception thrown when a database operation fails.
///
/// Examples: SQL syntax error, failed transaction, schema migration error.
class DatabaseException implements Exception {
  const DatabaseException(this.message);

  /// A description of what went wrong in the database operation.
  final String message;

  @override
  String toString() => 'DatabaseException: $message';
}

/// Exception thrown when input validation fails at the data layer.
///
/// Examples: invalid data format during deserialization, constraint
/// violation before database insertion.
class ValidationException implements Exception {
  const ValidationException(this.message);

  /// A description of the validation error.
  final String message;

  @override
  String toString() => 'ValidationException: $message';
}

/// Exception thrown when a sync operation fails.
///
/// Examples: network error during upload, invalid server response,
/// protocol version mismatch.
class SyncException implements Exception {
  const SyncException(this.message);

  /// A description of the synchronization error.
  final String message;

  @override
  String toString() => 'SyncException: $message';
}
