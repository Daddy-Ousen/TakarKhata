import 'package:khatabook/core/enums/transaction_type.dart';
import 'package:khatabook/features/transactions/domain/entities/transaction_entry.dart';

/// Repository contract for transaction operations.
///
/// Defines the interface that data layer implementations must fulfill
/// to provide transaction persistence. Supports querying by account,
/// category, date range, and type, as well as aggregate calculations.
abstract class TransactionRepository {
  /// Get all transactions with optional pagination.
  ///
  /// Results are ordered by [TransactionEntry.transactionDate] descending.
  /// Use [limit] and [offset] for pagination. Excludes soft-deleted entries.
  Future<List<TransactionEntry>> getAllTransactions({
    int? limit,
    int? offset,
  });

  /// Get a single transaction by its unique [id].
  ///
  /// Returns `null` if no transaction with the given [id] exists
  /// or if it has been soft-deleted.
  Future<TransactionEntry?> getTransactionById(String id);

  /// Get all transactions for a specific account.
  ///
  /// Returns transactions where [TransactionEntry.accountId] or
  /// [TransactionEntry.destinationAccountId] matches [accountId].
  /// Optionally filter by date range with [from] and [to].
  Future<List<TransactionEntry>> getTransactionsByAccount(
    String accountId, {
    DateTime? from,
    DateTime? to,
  });

  /// Get all transactions assigned to a specific category.
  ///
  /// Optionally filter by date range with [from] and [to].
  Future<List<TransactionEntry>> getTransactionsByCategory(
    String categoryId, {
    DateTime? from,
    DateTime? to,
  });

  /// Get all transactions within a specific date range.
  ///
  /// Both [from] and [to] are inclusive boundaries.
  /// Results are ordered by [TransactionEntry.transactionDate] descending.
  Future<List<TransactionEntry>> getTransactionsByDateRange(
    DateTime from,
    DateTime to,
  );

  /// Get all transactions of a specific type.
  ///
  /// Optionally filter by date range with [from] and [to].
  Future<List<TransactionEntry>> getTransactionsByType(
    TransactionType type, {
    DateTime? from,
    DateTime? to,
  });

  /// Search transactions by matching [query] against notes and
  /// other text fields.
  ///
  /// Returns transactions where the [query] substring is found
  /// in [TransactionEntry.notes] or related entity names.
  Future<List<TransactionEntry>> searchTransactions(String query);

  /// Create a new transaction and persist it.
  ///
  /// Returns the created [TransactionEntry] with any generated fields
  /// populated. The caller is responsible for updating account balances.
  Future<TransactionEntry> createTransaction(TransactionEntry transaction);

  /// Update an existing transaction with new field values.
  ///
  /// The [transaction]'s [TransactionEntry.id] must match an existing record.
  /// Throws if the transaction does not exist.
  Future<void> updateTransaction(TransactionEntry transaction);

  /// Soft-delete a transaction by its [id].
  ///
  /// Sets [TransactionEntry.isDeleted] to `true` rather than removing
  /// the record. The transaction will be excluded from query results.
  Future<void> deleteTransaction(String id);

  /// Get the total income amount in cents for the given date range.
  ///
  /// Sums [TransactionEntry.amount] for all income transactions
  /// between [from] and [to] (inclusive).
  Future<int> getIncomeTotal(DateTime from, DateTime to);

  /// Get the total expense amount in cents for the given date range.
  ///
  /// Sums [TransactionEntry.amount] for all expense transactions
  /// between [from] and [to] (inclusive).
  Future<int> getExpenseTotal(DateTime from, DateTime to);

  /// Get expense totals grouped by category for the given date range.
  ///
  /// Returns a map where keys are category IDs and values are the
  /// total expense amounts in cents for that category.
  Future<Map<String, int>> getExpensesByCategory(DateTime from, DateTime to);

  /// Watch recent transactions as a stream for reactive UI updates.
  ///
  /// Emits a new list whenever the underlying data changes.
  /// Results are ordered by [TransactionEntry.transactionDate] descending,
  /// limited to [limit] entries.
  Stream<List<TransactionEntry>> watchRecentTransactions({int limit = 50});
}
