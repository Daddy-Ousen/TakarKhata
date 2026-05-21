import 'package:khatabook/core/enums/account_type.dart';
import 'package:khatabook/core/constants/default_data.dart';
import 'package:khatabook/core/utils/uuid_generator.dart';
import 'package:khatabook/features/accounts/domain/entities/account.dart';
import 'package:khatabook/features/accounts/domain/repositories/account_repository.dart';
import 'package:khatabook/features/transactions/application/transaction_service.dart';

/// Service for account management operations.
class AccountService {
  final AccountRepository _accountRepository;
  final TransactionService _transactionService;

  AccountService({
    required AccountRepository accountRepository,
    required TransactionService transactionService,
  })  : _accountRepository = accountRepository,
        _transactionService = transactionService;

  /// Create a new account with an optional opening balance.
  Future<Account> createAccount({
    required String name,
    required AccountType type,
    String? iconName,
    int? colorValue,
    int openingBalance = 0,
    DateTime? openingBalanceDate,
  }) async {
    final now = DateTime.now();
    final account = Account(
      id: UuidGenerator.generate(),
      name: name,
      type: type,
      iconName: iconName,
      colorValue: colorValue,
      createdAt: now,
      modifiedAt: now,
    );

    final created = await _accountRepository.createAccount(account);

    // Create opening balance as a ledger entry
    if (openingBalance > 0) {
      await _transactionService.createOpeningBalance(
        accountId: created.id,
        amount: type == AccountType.credit ? -openingBalance : openingBalance,
        balanceDate: openingBalanceDate ?? now,
      );
    }

    return created;
  }

  /// Initialize default accounts on first launch.
  Future<void> initializeDefaultAccounts() async {
    final existing = await _accountRepository.getAllAccounts();
    if (existing.isNotEmpty) return;

    final defaults = DefaultData.defaultAccounts();
    for (final data in defaults) {
      await createAccount(
        name: data['name'] as String,
        type: data['type'] as AccountType,
        iconName: data['iconName'] as String?,
        colorValue: data['colorValue'] as int?,
      );
    }
  }

  /// Get all active accounts with their calculated balances.
  Future<List<Account>> getAccountsWithBalances() async {
    final accounts = await _accountRepository.getAllAccounts();
    final result = <Account>[];

    for (final account in accounts) {
      final balance =
          await _accountRepository.getCalculatedBalance(account.id);
      result.add(account.copyWith(cachedBalance: balance));
    }

    return result;
  }

  /// Update an account's details.
  Future<void> updateAccount(Account account) async {
    await _accountRepository.updateAccount(
      account.copyWith(modifiedAt: DateTime.now()),
    );
  }

  /// Archive (soft-delete) an account.
  Future<void> archiveAccount(String id) async {
    await _accountRepository.archiveAccount(id);
  }
}
