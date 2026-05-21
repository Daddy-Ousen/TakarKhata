/// Conflict resolution strategies for data synchronization.
enum SyncStrategy {
  lastWriteWins('Last Write Wins'),
  localFirst('Keep Local'),
  remoteFirst('Keep Remote'),
  manual('Manual Resolution');

  const SyncStrategy(this.label);

  /// Human-readable label for UI display.
  final String label;
}
