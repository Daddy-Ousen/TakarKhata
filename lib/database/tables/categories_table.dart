import 'package:drift/drift.dart';

/// Drift table definition for transaction categories.
///
/// Categories are user-defined labels (e.g., "Food", "Rent", "Salary")
/// assigned to income and expense transactions for budgeting and
/// reporting purposes.
///
/// Categories support archiving so historical data remains intact
/// when a category is no longer actively used.
class Categories extends Table {
  /// Unique identifier for the category (UUID string).
  TextColumn get id => text()();

  /// Display name of the category (e.g., "Groceries", "Transportation").
  TextColumn get name => text().withLength(min: 1, max: 50)();

  /// Optional Material icon name for display purposes.
  TextColumn get iconName => text().nullable()();

  /// Optional color value stored as an ARGB integer (e.g., 0xFFEF5350).
  IntColumn get colorValue => integer().nullable()();

  /// Whether this category has been archived by the user.
  ///
  /// Archived categories are hidden from selection lists but remain
  /// linked to existing transactions.
  BoolColumn get isArchived =>
      boolean().withDefault(const Constant(false))();

  /// User-defined sort position for ordering categories in the UI.
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  /// Timestamp when this category was first created.
  DateTimeColumn get createdAt => dateTime()();

  /// Timestamp when this category was last modified.
  DateTimeColumn get modifiedAt => dateTime()();

  /// Monotonically increasing version number for sync conflict resolution.
  IntColumn get syncVersion =>
      integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {id};
}
