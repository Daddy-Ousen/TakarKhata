import 'package:drift/drift.dart';

/// Drift table definition for financial accounts.
///
/// Stores bank accounts, cash wallets, credit cards, and savings accounts.
/// The [type] column maps to [AccountType] enum values:
/// - 0 = debit
/// - 1 = credit
/// - 2 = cash
/// - 3 = savings
///
/// All monetary calculations are derived from the transactions ledger
/// rather than stored directly on the account row.
class Accounts extends Table {
  /// Unique identifier for the account (UUID string).
  TextColumn get id => text()();

  /// Display name of the account (e.g., "Main Checking", "Cash Wallet").
  TextColumn get name => text().withLength(min: 1, max: 100)();

  /// Account type stored as the integer value of [AccountType] enum.
  IntColumn get type => integer()();

  /// Optional Material icon name for display purposes.
  TextColumn get iconName => text().nullable()();

  /// Optional color value stored as an ARGB integer (e.g., 0xFF42A5F5).
  IntColumn get colorValue => integer().nullable()();

  /// Whether this account has been archived by the user.
  ///
  /// Archived accounts are hidden from the main list but their
  /// transaction history is preserved.
  BoolColumn get isArchived =>
      boolean().withDefault(const Constant(false))();

  /// User-defined sort position for ordering accounts in the UI.
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  /// Timestamp when this account was first created.
  DateTimeColumn get createdAt => dateTime()();

  /// Timestamp when this account was last modified.
  DateTimeColumn get modifiedAt => dateTime()();

  /// Monotonically increasing version number for sync conflict resolution.
  IntColumn get syncVersion =>
      integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {id};
}
