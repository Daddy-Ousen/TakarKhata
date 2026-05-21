import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khatabook/core/providers/app_providers.dart';
import 'package:khatabook/features/accounts/domain/entities/account.dart';

/// Stream provider for reactive account list updates.
final accountsStreamProvider = StreamProvider<List<Account>>((ref) {
  return ref.watch(accountRepositoryProvider).watchAllAccounts();
});

/// Future provider for accounts with calculated balances.
final accountsWithBalancesProvider =
    FutureProvider<List<Account>>((ref) async {
  ref.watch(accountsStreamProvider);
  return ref.watch(accountServiceProvider).getAccountsWithBalances();
});

/// Provider for a single account by ID.
final accountByIdProvider =
    FutureProvider.family<Account?, String>((ref, id) async {
  ref.watch(accountsStreamProvider);
  return ref.watch(accountRepositoryProvider).getAccountById(id);
});

/// Provider for calculated balance of a specific account.
final accountBalanceProvider =
    FutureProvider.family<int, String>((ref, accountId) async {
  ref.watch(accountsStreamProvider);
  return ref.watch(accountRepositoryProvider).getCalculatedBalance(accountId);
});
