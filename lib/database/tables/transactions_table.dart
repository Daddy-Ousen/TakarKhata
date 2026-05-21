import 'package:drift/drift.dart';

/// Drift table definition for financial transactions.
///
/// Each row represents a single ledger entry that affects one or two
/// accounts. The [type] column maps to [TransactionType] enum values:
/// - 0 = income (credits the account)
/// - 1 = expense (debits the account)
/// - 2 = transfer (debits source, credits destination)
/// - 3 = openingBalance (sets initial balance)
///
/// All monetary values ([amount], [transferFee]) are stored as integers
/// representing cents to avoid floating-point precision issues.
///
/// Soft deletion is used via [isDeleted] to preserve audit history
/// and enable undo functionality.
class Transactions extends Table {
  /// Unique identifier for the transaction (UUID string).
  TextColumn get id => text()();

  /// Transaction type stored as the integer value of [TransactionType] enum.
  IntColumn get type => integer()();

  /// Transaction amount in cents (always positive).
  ///
  /// The sign/direction is determined by [type]:
  /// - income: added to account balance
  /// - expense: subtracted from account balance
  /// - transfer: subtracted from source, added to destination
  IntColumn get amount => integer()();

  /// The primary account affected by this transaction.
  ///
  /// For income/expense/openingBalance: the account being credited/debited.
  /// For transfers: the source account (money leaves this account).
  TextColumn get accountId => text()();

  /// The destination account for transfer transactions.
  ///
  /// Only populated when [type] is transfer (2). Null for all other types.
  TextColumn get destinationAccountId => text().nullable()();

  /// The category assigned to this transaction.
  ///
  /// Null for transfers and opening balances, which are not categorized.
  TextColumn get categoryId => text().nullable()();

  /// Fee charged for transfer transactions, in cents.
  ///
  /// Deducted from the source account in addition to the transfer [amount].
  /// Defaults to 0 for non-transfer transactions.
  IntColumn get transferFee =>
      integer().withDefault(const Constant(0))();

  /// Groups related transfer transactions together.
  ///
  /// When a transfer creates paired entries, they share the same group ID
  /// so they can be edited or deleted as a unit.
  TextColumn get transferGroupId => text().nullable()();

  /// Optional user-provided notes or memo for the transaction.
  TextColumn get notes => text().nullable().withLength(max: 500)();

  /// The date the transaction occurred (user-selected).
  ///
  /// This may differ from [createdAt] if the user backdates or
  /// forward-dates a transaction.
  DateTimeColumn get transactionDate => dateTime()();

  /// Timestamp when this transaction record was first created.
  DateTimeColumn get createdAt => dateTime()();

  /// Timestamp when this transaction record was last modified.
  DateTimeColumn get modifiedAt => dateTime()();

  /// Monotonically increasing version number for sync conflict resolution.
  IntColumn get syncVersion =>
      integer().withDefault(const Constant(1))();

  /// Whether this transaction has been soft-deleted.
  ///
  /// Soft-deleted transactions are excluded from balance calculations
  /// and query results but remain in the database for sync and audit.
  BoolColumn get isDeleted =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
