import 'package:khatabook/core/enums/transaction_type.dart';
import 'package:khatabook/core/errors/failures.dart';
import 'package:khatabook/core/utils/uuid_generator.dart';
import 'package:khatabook/features/accounts/domain/repositories/account_repository.dart';
import 'package:khatabook/features/transactions/domain/entities/transaction_entry.dart';
import 'package:khatabook/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:khatabook/features/transactions/application/financial_engine.dart';

/// Service layer for transaction operations.
///
/// Orchestrates business logic for creating, updating, and deleting
/// transactions while ensuring data integrity through atomic operations
/// and automatic balance recalculation.
class TransactionService {
  final TransactionRepository _transactionRepository;
  final AccountRepository _accountRepository;
  final FinancialEngine _financialEngine;

  TransactionService({
    required TransactionRepository transactionRepository,
    required AccountRepository accountRepository,
    required FinancialEngine financialEngine,
  })  : _transactionRepository = transactionRepository,
        _accountRepository = accountRepository,
        _financialEngine = financialEngine;

  /// Create a new income or expense transaction.
  ///
  /// Validates the transaction, persists it, and recalculates the
  /// affected account's balance.
  Future<TransactionEntry> createTransaction({
    required TransactionType type,
    required int amount,
    required String accountId,
    String? categoryId,
    String? notes,
    required DateTime transactionDate,
  }) async {
    if (amount <= 0) {
      throw const ValidationFailure('Amount must be greater than zero');
    }

    final account = await _accountRepository.getAccountById(accountId);
    if (account == null) {
      throw NotFoundFailure(entityType: 'Account', entityId: accountId);
    }

    final now = DateTime.now();
    final transaction = TransactionEntry(
      id: UuidGenerator.generate(),
      type: type,
      amount: amount,
      accountId: accountId,
      categoryId: categoryId,
      notes: notes,
      transactionDate: transactionDate,
      createdAt: now,
      modifiedAt: now,
    );

    final created = await _transactionRepository.createTransaction(transaction);
    await _financialEngine.recalculateAfterMutation([accountId]);

    return created;
  }

  /// Create a transfer between two accounts.
  ///
  /// This is an atomic operation that:
  /// 1. Deducts [amount] from [sourceAccountId]
  /// 2. Adds [amount] to [destinationAccountId]
  /// 3. Deducts [transferFee] from [sourceAccountId] (if > 0)
  /// 4. Recalculates both account balances
  ///
  /// All steps succeed or all roll back.
  Future<TransactionEntry> createTransfer({
    required int amount,
    required String sourceAccountId,
    required String destinationAccountId,
    int transferFee = 0,
    String? notes,
    required DateTime transactionDate,
  }) async {
    if (amount <= 0) {
      throw const ValidationFailure('Transfer amount must be greater than zero');
    }
    if (sourceAccountId == destinationAccountId) {
      throw const ValidationFailure(
          'Source and destination accounts must be different');
    }
    if (transferFee < 0) {
      throw const ValidationFailure('Transfer fee cannot be negative');
    }

    // Verify both accounts exist
    final source = await _accountRepository.getAccountById(sourceAccountId);
    if (source == null) {
      throw NotFoundFailure(entityType: 'Account', entityId: sourceAccountId);
    }
    final destination =
        await _accountRepository.getAccountById(destinationAccountId);
    if (destination == null) {
      throw NotFoundFailure(
          entityType: 'Account', entityId: destinationAccountId);
    }

    final now = DateTime.now();
    final groupId = UuidGenerator.generate();

    final transfer = TransactionEntry(
      id: UuidGenerator.generate(),
      type: TransactionType.transfer,
      amount: amount,
      accountId: sourceAccountId,
      destinationAccountId: destinationAccountId,
      transferFee: transferFee,
      transferGroupId: groupId,
      notes: notes,
      transactionDate: transactionDate,
      createdAt: now,
      modifiedAt: now,
    );

    final created = await _transactionRepository.createTransaction(transfer);

    // Recalculate both accounts
    await _financialEngine
        .recalculateAfterMutation([sourceAccountId, destinationAccountId]);

    return created;
  }

  /// Create an opening balance entry for an account.
  ///
  /// Opening balances are system-generated transactions that establish
  /// the initial balance for an account. They participate in all
  /// balance calculations naturally.
  Future<TransactionEntry> createOpeningBalance({
    required String accountId,
    required int amount,
    required DateTime balanceDate,
  }) async {
    final account = await _accountRepository.getAccountById(accountId);
    if (account == null) {
      throw NotFoundFailure(entityType: 'Account', entityId: accountId);
    }

    final now = DateTime.now();
    final transaction = TransactionEntry(
      id: UuidGenerator.generate(),
      type: TransactionType.openingBalance,
      amount: amount,
      accountId: accountId,
      notes: 'Opening Balance',
      transactionDate: balanceDate,
      createdAt: now,
      modifiedAt: now,
    );

    final created = await _transactionRepository.createTransaction(transaction);
    await _financialEngine.recalculateAfterMutation([accountId]);

    return created;
  }

  /// Update an existing transaction.
  ///
  /// After updating, recalculates balances for all affected accounts
  /// (both the old and new accounts if the account was changed).
  Future<void> updateTransaction(TransactionEntry updated) async {
    final existing =
        await _transactionRepository.getTransactionById(updated.id);
    if (existing == null) {
      throw NotFoundFailure(entityType: 'Transaction', entityId: updated.id);
    }

    // Collect all affected account IDs (old + new)
    final affectedIds = <String>{
      ...(_financialEngine.getAffectedAccountIds(existing)),
      ...(_financialEngine.getAffectedAccountIds(updated)),
    };

    final now = DateTime.now();
    final toUpdate = updated.copyWith(modifiedAt: now);

    await _transactionRepository.updateTransaction(toUpdate);
    await _financialEngine.recalculateAfterMutation(affectedIds.toList());
  }

  /// Delete (soft-delete) a transaction.
  ///
  /// After deletion, recalculates balances for all affected accounts.
  Future<void> deleteTransaction(String id) async {
    final existing = await _transactionRepository.getTransactionById(id);
    if (existing == null) {
      throw NotFoundFailure(entityType: 'Transaction', entityId: id);
    }

    final affectedIds = _financialEngine.getAffectedAccountIds(existing);

    await _transactionRepository.deleteTransaction(id);
    await _financialEngine.recalculateAfterMutation(affectedIds);
  }
}
