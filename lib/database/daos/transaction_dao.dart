import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/transactions_table.dart';

part 'transaction_dao.g.dart';

/// Data Access Object for transaction-related database operations.
///
/// Provides CRUD operations, filtering by account/category/date/type,
/// full-text search on notes, aggregate totals for reporting, and
/// reactive streams for UI updates.
///
/// All queries automatically exclude soft-deleted transactions
/// (where [isDeleted] is true) unless otherwise noted.
@DriftAccessor(tables: [Transactions])
class TransactionDao extends DatabaseAccessor<AppDatabase>
    with _$TransactionDaoMixin {
  /// Creates a [TransactionDao] attached to the given [db].
  TransactionDao(AppDatabase db) : super(db);

  /// Returns non-deleted transactions ordered by date descending.
  ///
  /// Supports optional pagination via [limit] and [offset].
  Future<List<Transaction>> getAllTransactions({
    int? limit,
    int? offset,
  }) {
    final query = select(transactions)
      ..where((t) => t.isDeleted.equals(false))
      ..orderBy([(t) => OrderingTerm.desc(t.transactionDate)]);

    if (limit != null) {
      query.limit(limit, offset: offset);
    }

    return query.get();
  }

  /// Returns the transaction with the given [id], or `null` if not found.
  ///
  /// This returns the transaction even if it has been soft-deleted,
  /// which is useful for undo and sync operations.
  Future<Transaction?> getTransactionById(String id) {
    return (select(transactions)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  /// Returns non-deleted transactions for the given [accountId].
  ///
  /// Matches transactions where either [accountId] is the primary
  /// account or the destination account (for transfers).
  ///
  /// Optionally filters to a date range with [from] and [to].
  Future<List<Transaction>> getTransactionsByAccount(
    String accountId, {
    DateTime? from,
    DateTime? to,
  }) {
    final query = select(transactions)
      ..where((t) {
        final conditions = <Expression<bool>>[
          t.isDeleted.equals(false),
          t.accountId.equals(accountId) |
              t.destinationAccountId.equals(accountId),
        ];

        if (from != null) {
          conditions.add(t.transactionDate.isBiggerOrEqualValue(from));
        }
        if (to != null) {
          conditions.add(t.transactionDate.isSmallerOrEqualValue(to));
        }

        return Expression.and(conditions);
      })
      ..orderBy([(t) => OrderingTerm.desc(t.transactionDate)]);

    return query.get();
  }

  /// Returns non-deleted transactions for the given [categoryId].
  ///
  /// Optionally filters to a date range with [from] and [to].
  Future<List<Transaction>> getTransactionsByCategory(
    String categoryId, {
    DateTime? from,
    DateTime? to,
  }) {
    final query = select(transactions)
      ..where((t) {
        final conditions = <Expression<bool>>[
          t.isDeleted.equals(false),
          t.categoryId.equals(categoryId),
        ];

        if (from != null) {
          conditions.add(t.transactionDate.isBiggerOrEqualValue(from));
        }
        if (to != null) {
          conditions.add(t.transactionDate.isSmallerOrEqualValue(to));
        }

        return Expression.and(conditions);
      })
      ..orderBy([(t) => OrderingTerm.desc(t.transactionDate)]);

    return query.get();
  }

  /// Returns non-deleted transactions within the date range [from]..[to].
  ///
  /// Both bounds are inclusive. Results ordered by date descending.
  Future<List<Transaction>> getTransactionsByDateRange(
    DateTime from,
    DateTime to,
  ) {
    return (select(transactions)
          ..where((t) =>
              t.isDeleted.equals(false) &
              t.transactionDate.isBiggerOrEqualValue(from) &
              t.transactionDate.isSmallerOrEqualValue(to))
          ..orderBy([(t) => OrderingTerm.desc(t.transactionDate)]))
        .get();
  }

  /// Returns non-deleted transactions of the given [type].
  ///
  /// [type] corresponds to [TransactionType] enum values:
  /// 0=income, 1=expense, 2=transfer, 3=openingBalance.
  ///
  /// Optionally filters to a date range with [from] and [to].
  Future<List<Transaction>> getTransactionsByType(
    int type, {
    DateTime? from,
    DateTime? to,
  }) {
    final query = select(transactions)
      ..where((t) {
        final conditions = <Expression<bool>>[
          t.isDeleted.equals(false),
          t.type.equals(type),
        ];

        if (from != null) {
          conditions.add(t.transactionDate.isBiggerOrEqualValue(from));
        }
        if (to != null) {
          conditions.add(t.transactionDate.isSmallerOrEqualValue(to));
        }

        return Expression.and(conditions);
      })
      ..orderBy([(t) => OrderingTerm.desc(t.transactionDate)]);

    return query.get();
  }

  /// Searches non-deleted transactions whose notes contain [query].
  ///
  /// The search is case-insensitive and matches partial strings.
  /// Returns results ordered by date descending.
  Future<List<Transaction>> searchTransactions(String query) {
    return (select(transactions)
          ..where((t) =>
              t.isDeleted.equals(false) &
              t.notes.like('%$query%'))
          ..orderBy([(t) => OrderingTerm.desc(t.transactionDate)]))
        .get();
  }

  /// Inserts a new transaction into the database.
  ///
  /// The [txn] companion must include at minimum: [id], [type],
  /// [amount], [accountId], [transactionDate], [createdAt], [modifiedAt].
  Future<void> insertTransaction(TransactionsCompanion txn) {
    return into(transactions).insert(txn);
  }

  /// Updates an existing transaction.
  ///
  /// The [txn] companion must include [id] to identify the row.
  Future<void> updateTransaction(TransactionsCompanion txn) {
    return (update(transactions)
          ..where((t) => t.id.equals(txn.id.value)))
        .write(txn);
  }

  /// Soft-deletes the transaction with the given [id].
  ///
  /// The row remains in the database with [isDeleted] set to true.
  /// It will be excluded from balance calculations and normal queries
  /// but remains available for sync and undo operations.
  Future<void> softDeleteTransaction(String id) {
    return (update(transactions)..where((t) => t.id.equals(id))).write(
      TransactionsCompanion(
        isDeleted: const Value(true),
        modifiedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Returns the total income (type=0) in cents for the given date range.
  ///
  /// Both [from] and [to] are inclusive bounds.
  Future<int> getIncomeTotal(DateTime from, DateTime to) async {
    final result = await customSelect(
      'SELECT COALESCE(SUM(amount), 0) AS total FROM transactions '
      'WHERE is_deleted = 0 AND type = 0 '
      'AND transaction_date >= ? AND transaction_date <= ?',
      variables: [
        Variable.withDateTime(from),
        Variable.withDateTime(to),
      ],
      readsFrom: {transactions},
    ).getSingle();

    return result.read<int>('total');
  }

  /// Returns the total expenses (type=1) in cents for the given date range.
  ///
  /// Both [from] and [to] are inclusive bounds.
  Future<int> getExpenseTotal(DateTime from, DateTime to) async {
    final result = await customSelect(
      'SELECT COALESCE(SUM(amount), 0) AS total FROM transactions '
      'WHERE is_deleted = 0 AND type = 1 '
      'AND transaction_date >= ? AND transaction_date <= ?',
      variables: [
        Variable.withDateTime(from),
        Variable.withDateTime(to),
      ],
      readsFrom: {transactions},
    ).getSingle();

    return result.read<int>('total');
  }

  /// Returns expenses grouped by category for the given date range.
  ///
  /// Each entry in the result contains:
  /// - `category_id` (String): the category identifier (may be null)
  /// - `total` (int): the total expense amount in cents
  ///
  /// Results are ordered by total descending (largest category first).
  /// Both [from] and [to] are inclusive bounds.
  Future<List<QueryRow>> getExpensesByCategory(
    DateTime from,
    DateTime to,
  ) {
    return customSelect(
      'SELECT category_id, COALESCE(SUM(amount), 0) AS total '
      'FROM transactions '
      'WHERE is_deleted = 0 AND type = 1 '
      'AND transaction_date >= ? AND transaction_date <= ? '
      'GROUP BY category_id '
      'ORDER BY total DESC',
      variables: [
        Variable.withDateTime(from),
        Variable.withDateTime(to),
      ],
      readsFrom: {transactions},
    ).get();
  }

  /// Returns income grouped by category for the given date range.
  ///
  /// Each entry in the result contains:
  /// - `category_id` (String): the category identifier (may be null)
  /// - `total` (int): the total income amount in cents
  ///
  /// Results are ordered by total descending.
  Future<List<QueryRow>> getIncomeByCategory(
    DateTime from,
    DateTime to,
  ) {
    return customSelect(
      'SELECT category_id, COALESCE(SUM(amount), 0) AS total '
      'FROM transactions '
      'WHERE is_deleted = 0 AND type = 0 '
      'AND transaction_date >= ? AND transaction_date <= ? '
      'GROUP BY category_id '
      'ORDER BY total DESC',
      variables: [
        Variable.withDateTime(from),
        Variable.withDateTime(to),
      ],
      readsFrom: {transactions},
    ).get();
  }

  /// Emits the most recent non-deleted transactions whenever changes occur.
  ///
  /// [limit] controls how many transactions are returned (default: 50).
  /// Useful for a dashboard "recent activity" widget.
  Stream<List<Transaction>> watchRecentTransactions({int limit = 50}) {
    return (select(transactions)
          ..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.transactionDate)])
          ..limit(limit))
        .watch();
  }

  /// Emits all non-deleted transactions for the given [accountId].
  ///
  /// Matches both primary and destination account references.
  Stream<List<Transaction>> watchTransactionsByAccount(String accountId) {
    return (select(transactions)
          ..where((t) =>
              t.isDeleted.equals(false) &
              (t.accountId.equals(accountId) |
                  t.destinationAccountId.equals(accountId)))
          ..orderBy([(t) => OrderingTerm.desc(t.transactionDate)]))
        .watch();
  }

  /// Returns the total number of non-deleted transactions.
  Future<int> getTransactionCount() async {
    final result = await customSelect(
      'SELECT COUNT(*) AS cnt FROM transactions WHERE is_deleted = 0',
      readsFrom: {transactions},
    ).getSingle();

    return result.read<int>('cnt');
  }
}
