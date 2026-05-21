import 'package:khatabook/core/enums/transaction_type.dart';
import 'package:khatabook/features/transactions/domain/entities/transaction_entry.dart'
    as domain;
import 'package:khatabook/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:khatabook/database/app_database.dart';
import 'package:drift/drift.dart';

/// Drift-backed implementation of [TransactionRepository].
class TransactionRepositoryImpl implements TransactionRepository {
  final AppDatabase _db;

  TransactionRepositoryImpl(this._db);

  domain.TransactionEntry _toDomain(Transaction row) {
    return domain.TransactionEntry(
      id: row.id,
      type: TransactionType.fromValue(row.type),
      amount: row.amount,
      accountId: row.accountId,
      destinationAccountId: row.destinationAccountId,
      categoryId: row.categoryId,
      transferFee: row.transferFee,
      transferGroupId: row.transferGroupId,
      notes: row.notes,
      transactionDate: row.transactionDate,
      createdAt: row.createdAt,
      modifiedAt: row.modifiedAt,
      syncVersion: row.syncVersion,
      isDeleted: row.isDeleted,
    );
  }

  TransactionsCompanion _toCompanion(domain.TransactionEntry entity) {
    return TransactionsCompanion(
      id: Value(entity.id),
      type: Value(entity.type.value),
      amount: Value(entity.amount),
      accountId: Value(entity.accountId),
      destinationAccountId: Value(entity.destinationAccountId),
      categoryId: Value(entity.categoryId),
      transferFee: Value(entity.transferFee),
      transferGroupId: Value(entity.transferGroupId),
      notes: Value(entity.notes),
      transactionDate: Value(entity.transactionDate),
      createdAt: Value(entity.createdAt),
      modifiedAt: Value(entity.modifiedAt),
      syncVersion: Value(entity.syncVersion),
      isDeleted: Value(entity.isDeleted),
    );
  }

  @override
  Future<List<domain.TransactionEntry>> getAllTransactions(
      {int? limit, int? offset}) async {
    final rows = await _db.transactionDao.getAllTransactions(
      limit: limit,
      offset: offset,
    );
    return rows.map(_toDomain).toList();
  }

  @override
  Future<domain.TransactionEntry?> getTransactionById(String id) async {
    final row = await _db.transactionDao.getTransactionById(id);
    return row != null ? _toDomain(row) : null;
  }

  @override
  Future<List<domain.TransactionEntry>> getTransactionsByAccount(
    String accountId, {
    DateTime? from,
    DateTime? to,
  }) async {
    final rows = await _db.transactionDao
        .getTransactionsByAccount(accountId, from: from, to: to);
    return rows.map(_toDomain).toList();
  }

  @override
  Future<List<domain.TransactionEntry>> getTransactionsByCategory(
    String categoryId, {
    DateTime? from,
    DateTime? to,
  }) async {
    final rows = await _db.transactionDao
        .getTransactionsByCategory(categoryId, from: from, to: to);
    return rows.map(_toDomain).toList();
  }

  @override
  Future<List<domain.TransactionEntry>> getTransactionsByDateRange(
    DateTime from,
    DateTime to,
  ) async {
    final rows = await _db.transactionDao.getTransactionsByDateRange(from, to);
    return rows.map(_toDomain).toList();
  }

  @override
  Future<List<domain.TransactionEntry>> getTransactionsByType(
    TransactionType type, {
    DateTime? from,
    DateTime? to,
  }) async {
    final rows = await _db.transactionDao
        .getTransactionsByType(type.value, from: from, to: to);
    return rows.map(_toDomain).toList();
  }

  @override
  Future<List<domain.TransactionEntry>> searchTransactions(String query) async {
    final rows = await _db.transactionDao.searchTransactions(query);
    return rows.map(_toDomain).toList();
  }

  @override
  Future<domain.TransactionEntry> createTransaction(
      domain.TransactionEntry transaction) async {
    await _db.transactionDao.insertTransaction(_toCompanion(transaction));
    return transaction;
  }

  @override
  Future<void> updateTransaction(domain.TransactionEntry transaction) async {
    await _db.transactionDao.updateTransaction(_toCompanion(transaction));
  }

  @override
  Future<void> deleteTransaction(String id) async {
    await _db.transactionDao.softDeleteTransaction(id);
  }

  @override
  Future<int> getIncomeTotal(DateTime from, DateTime to) async {
    return _db.transactionDao.getIncomeTotal(from, to);
  }

  @override
  Future<int> getExpenseTotal(DateTime from, DateTime to) async {
    return _db.transactionDao.getExpenseTotal(from, to);
  }

  @override
  Future<Map<String, int>> getExpensesByCategory(
      DateTime from, DateTime to) async {
    final rows = await _db.transactionDao.getExpensesByCategory(from, to);
    final result = <String, int>{};
    for (final row in rows) {
      final categoryId = row.readNullable<String>('category_id') ?? 'Uncategorized';
      final total = row.read<int>('total');
      result[categoryId] = total;
    }
    return result;
  }

  @override
  Stream<List<domain.TransactionEntry>> watchRecentTransactions(
      {int limit = 50}) {
    return _db.transactionDao.watchRecentTransactions(limit: limit).map(
          (rows) => rows.map(_toDomain).toList(),
        );
  }
}
