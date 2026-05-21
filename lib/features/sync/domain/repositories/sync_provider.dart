import 'package:khatabook/features/sync/domain/entities/sync_config.dart';
import 'package:khatabook/features/sync/domain/entities/sync_result.dart';
import 'package:khatabook/features/sync/domain/entities/sync_conflict.dart';

/// Abstract synchronization provider.
///
/// Implement this interface for different sync backends (e.g., local
/// file export/import, cloud storage, peer-to-peer). Each implementation
/// handles the specifics of data transport and format while the domain
/// layer remains agnostic.
abstract class SyncProvider {
  /// Export all data that has changed since the last sync.
  ///
  /// Uses [config] to determine the sync strategy, encryption settings,
  /// and the timestamp of the last successful sync. Returns a [SyncResult]
  /// describing the outcome of the export operation.
  Future<SyncResult> exportData(SyncConfig config);

  /// Import data from an external source.
  ///
  /// Uses [config] for conflict resolution strategy and encryption.
  /// The [data] parameter contains the raw imported payload whose
  /// format depends on the specific provider implementation.
  /// Returns a [SyncResult] describing the outcome of the import.
  Future<SyncResult> importData(SyncConfig config, dynamic data);

  /// Detect conflicts between local and remote data.
  ///
  /// Compares [remoteData] against the local database to identify
  /// entities that have been modified on both sides since the last sync.
  /// Returns a list of [SyncConflict] instances that need resolution.
  Future<List<SyncConflict>> detectConflicts(dynamic remoteData);

  /// The display name of this sync provider for UI presentation.
  ///
  /// For example: "Local File", "Google Drive", "Dropbox".
  String get providerName;

  /// Whether this sync provider is currently available for use.
  ///
  /// Checks prerequisites such as network connectivity, authentication
  /// status, or file system access. Returns `true` if the provider
  /// is ready to perform sync operations.
  Future<bool> isAvailable();
}
