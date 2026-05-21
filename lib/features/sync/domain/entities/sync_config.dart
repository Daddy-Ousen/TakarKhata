import 'package:khatabook/core/enums/sync_strategy.dart';

/// Configuration for data synchronization operations.
///
/// Holds the settings needed to perform a sync, including the
/// conflict resolution strategy, optional encryption, and
/// metadata about the last successful sync.
class SyncConfig {
  /// The strategy used to resolve conflicts during sync.
  final SyncStrategy strategy;

  /// Optional password for encrypting/decrypting exported data.
  /// When null, data is exported without encryption.
  final String? encryptionPassword;

  /// Timestamp of the last successful synchronization.
  /// Null if no sync has been performed yet.
  final DateTime? lastSyncTimestamp;

  /// Schema version of the sync data format.
  /// Used to detect and handle format migrations during import.
  final int syncSchemaVersion;

  /// Creates a new [SyncConfig] instance.
  ///
  /// [strategy] and [syncSchemaVersion] are required.
  const SyncConfig({
    required this.strategy,
    this.encryptionPassword,
    this.lastSyncTimestamp,
    required this.syncSchemaVersion,
  });

  /// Creates a copy of this config with the given fields replaced.
  SyncConfig copyWith({
    SyncStrategy? strategy,
    String? encryptionPassword,
    DateTime? lastSyncTimestamp,
    int? syncSchemaVersion,
  }) {
    return SyncConfig(
      strategy: strategy ?? this.strategy,
      encryptionPassword: encryptionPassword ?? this.encryptionPassword,
      lastSyncTimestamp: lastSyncTimestamp ?? this.lastSyncTimestamp,
      syncSchemaVersion: syncSchemaVersion ?? this.syncSchemaVersion,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SyncConfig &&
          runtimeType == other.runtimeType &&
          strategy == other.strategy &&
          encryptionPassword == other.encryptionPassword &&
          lastSyncTimestamp == other.lastSyncTimestamp &&
          syncSchemaVersion == other.syncSchemaVersion;

  @override
  int get hashCode => Object.hash(
        strategy,
        encryptionPassword,
        lastSyncTimestamp,
        syncSchemaVersion,
      );

  @override
  String toString() =>
      'SyncConfig(strategy: $strategy, lastSync: $lastSyncTimestamp, '
      'schemaVersion: $syncSchemaVersion)';
}
