import 'package:drift/drift.dart';

/// Handles database schema migrations between versions.
///
/// Each migration is a function that takes a [Migrator] and performs
/// the necessary schema changes to upgrade from the previous version.
///
/// Usage in [AppDatabase.migration]:
/// ```dart
/// onUpgrade: (Migrator m, int from, int to) async {
///   await MigrationHelper.runMigrations(m, from, to);
/// },
/// ```
class MigrationHelper {
  MigrationHelper._();

  /// Map of migration functions keyed by their target schema version.
  ///
  /// Each function receives a [Migrator] and performs the upgrade steps
  /// needed to reach that version from the immediately preceding version.
  ///
  /// Example:
  /// ```dart
  /// 2: (m) async {
  ///   await m.addColumn(accounts, accounts.newColumn);
  /// },
  /// 3: (m) async {
  ///   await m.createTable(budgets);
  /// },
  /// ```
  static final Map<int, Future<void> Function(Migrator m)> migrations = {
    // Version 2 migration:
    // 2: (Migrator m) async {
    //   await m.addColumn(accounts, accounts.newColumn);
    // },
  };

  /// Runs all migrations sequentially from version [from] + 1 to [to].
  ///
  /// Migrations are applied in ascending version order. If a version
  /// has no registered migration function, it is silently skipped.
  ///
  /// Throws any exception raised by an individual migration function,
  /// halting further migrations.
  static Future<void> runMigrations(
    Migrator migrator,
    int from,
    int to,
  ) async {
    for (int version = from + 1; version <= to; version++) {
      final migration = migrations[version];
      if (migration != null) {
        await migration(migrator);
      }
    }
  }
}
