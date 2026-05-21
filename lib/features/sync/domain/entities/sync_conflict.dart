/// Represents a data conflict detected during synchronization.
///
/// When the same entity has been modified both locally and remotely
/// since the last sync, a [SyncConflict] is created to track the
/// differing versions and their resolution.
class SyncConflict {
  /// The type of entity involved in the conflict (e.g., 'account',
  /// 'transaction', 'category', 'loan').
  final String entityType;

  /// The unique identifier of the conflicting entity.
  final String entityId;

  /// The local version of the entity's data as a key-value map.
  final Map<String, dynamic> localData;

  /// The remote version of the entity's data as a key-value map.
  final Map<String, dynamic> remoteData;

  /// Timestamp when the local version was last modified.
  final DateTime localModifiedAt;

  /// Timestamp when the remote version was last modified.
  final DateTime remoteModifiedAt;

  /// Whether this conflict has been resolved.
  final bool resolved;

  /// The chosen resolution strategy for this conflict.
  /// - `'local'`: the local version was kept.
  /// - `'remote'`: the remote version was accepted.
  /// - `null`: not yet resolved.
  final String? resolution;

  /// Creates a new [SyncConflict] instance.
  ///
  /// [entityType], [entityId], [localData], [remoteData],
  /// [localModifiedAt], and [remoteModifiedAt] are required.
  /// Defaults: [resolved] = false, [resolution] = null.
  const SyncConflict({
    required this.entityType,
    required this.entityId,
    required this.localData,
    required this.remoteData,
    required this.localModifiedAt,
    required this.remoteModifiedAt,
    this.resolved = false,
    this.resolution,
  });

  /// Creates a copy of this conflict with the given fields replaced.
  SyncConflict copyWith({
    String? entityType,
    String? entityId,
    Map<String, dynamic>? localData,
    Map<String, dynamic>? remoteData,
    DateTime? localModifiedAt,
    DateTime? remoteModifiedAt,
    bool? resolved,
    String? resolution,
  }) {
    return SyncConflict(
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      localData: localData ?? this.localData,
      remoteData: remoteData ?? this.remoteData,
      localModifiedAt: localModifiedAt ?? this.localModifiedAt,
      remoteModifiedAt: remoteModifiedAt ?? this.remoteModifiedAt,
      resolved: resolved ?? this.resolved,
      resolution: resolution ?? this.resolution,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SyncConflict &&
          runtimeType == other.runtimeType &&
          entityType == other.entityType &&
          entityId == other.entityId;

  @override
  int get hashCode => Object.hash(entityType, entityId);

  @override
  String toString() =>
      'SyncConflict(entityType: $entityType, entityId: $entityId, '
      'resolved: $resolved, resolution: $resolution)';
}
