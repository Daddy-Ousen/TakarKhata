/// Represents the outcome of a synchronization operation.
///
/// Contains summary statistics about what was imported, exported,
/// and how many conflicts were encountered during the sync.
class SyncResult {
  /// Whether the sync operation completed successfully.
  final bool success;

  /// A human-readable message describing the sync outcome.
  final String message;

  /// Number of entities imported from the remote source.
  final int importedCount;

  /// Number of entities exported to the remote destination.
  final int exportedCount;

  /// Number of conflicts detected during the sync.
  final int conflictCount;

  /// Timestamp when this sync operation was performed.
  final DateTime timestamp;

  /// Creates a new [SyncResult] instance.
  ///
  /// All fields are required.
  const SyncResult({
    required this.success,
    required this.message,
    required this.importedCount,
    required this.exportedCount,
    required this.conflictCount,
    required this.timestamp,
  });

  /// Creates a copy of this result with the given fields replaced.
  SyncResult copyWith({
    bool? success,
    String? message,
    int? importedCount,
    int? exportedCount,
    int? conflictCount,
    DateTime? timestamp,
  }) {
    return SyncResult(
      success: success ?? this.success,
      message: message ?? this.message,
      importedCount: importedCount ?? this.importedCount,
      exportedCount: exportedCount ?? this.exportedCount,
      conflictCount: conflictCount ?? this.conflictCount,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SyncResult &&
          runtimeType == other.runtimeType &&
          success == other.success &&
          message == other.message &&
          importedCount == other.importedCount &&
          exportedCount == other.exportedCount &&
          conflictCount == other.conflictCount &&
          timestamp == other.timestamp;

  @override
  int get hashCode => Object.hash(
        success,
        message,
        importedCount,
        exportedCount,
        conflictCount,
        timestamp,
      );

  @override
  String toString() =>
      'SyncResult(success: $success, imported: $importedCount, '
      'exported: $exportedCount, conflicts: $conflictCount)';
}
