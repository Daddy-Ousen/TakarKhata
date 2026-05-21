import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khatabook/core/enums/transaction_type.dart';
import 'package:khatabook/core/providers/app_providers.dart';
import 'package:khatabook/features/transactions/domain/entities/transaction_entry.dart';

/// Stream provider for recent transactions (reactive, auto-updates).
final recentTransactionsProvider =
    StreamProvider<List<TransactionEntry>>((ref) {
  ref.watch(ledgerUpdateProvider);
  return ref
      .watch(transactionRepositoryProvider)
      .watchRecentTransactions(limit: 50);
});

/// Future provider for filtered transactions.
final filteredTransactionsProvider = FutureProvider.family<
    List<TransactionEntry>, TransactionFilter>((ref, filter) async {
  // Watch recent transactions stream so that ANY new transaction triggers a refetch
  ref.watch(ledgerUpdateProvider);
  ref.watch(recentTransactionsProvider);

  final repo = ref.watch(transactionRepositoryProvider);

  if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
    return repo.searchTransactions(filter.searchQuery!);
  }

  if (filter.accountId != null) {
    return repo.getTransactionsByAccount(
      filter.accountId!,
      from: filter.dateFrom,
      to: filter.dateTo,
    );
  }

  if (filter.categoryId != null) {
    return repo.getTransactionsByCategory(
      filter.categoryId!,
      from: filter.dateFrom,
      to: filter.dateTo,
    );
  }

  if (filter.type != null) {
    return repo.getTransactionsByType(
      filter.type!,
      from: filter.dateFrom,
      to: filter.dateTo,
    );
  }

  if (filter.dateFrom != null && filter.dateTo != null) {
    return repo.getTransactionsByDateRange(filter.dateFrom!, filter.dateTo!);
  }

  return repo.getAllTransactions(limit: filter.limit ?? 50);
});

/// Filter configuration for transactions.
class TransactionFilter {
  final String? accountId;
  final String? categoryId;
  final TransactionType? type;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final String? searchQuery;
  final int? limit;

  const TransactionFilter({
    this.accountId,
    this.categoryId,
    this.type,
    this.dateFrom,
    this.dateTo,
    this.searchQuery,
    this.limit,
  });

  TransactionFilter copyWith({
    String? accountId,
    String? categoryId,
    TransactionType? type,
    DateTime? dateFrom,
    DateTime? dateTo,
    String? searchQuery,
    int? limit,
  }) {
    return TransactionFilter(
      accountId: accountId ?? this.accountId,
      categoryId: categoryId ?? this.categoryId,
      type: type ?? this.type,
      dateFrom: dateFrom ?? this.dateFrom,
      dateTo: dateTo ?? this.dateTo,
      searchQuery: searchQuery ?? this.searchQuery,
      limit: limit ?? this.limit,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionFilter &&
          accountId == other.accountId &&
          categoryId == other.categoryId &&
          type == other.type &&
          dateFrom == other.dateFrom &&
          dateTo == other.dateTo &&
          searchQuery == other.searchQuery &&
          limit == other.limit;

  @override
  int get hashCode => Object.hash(
      accountId, categoryId, type, dateFrom, dateTo, searchQuery, limit);
}

/// Provider to hold the current active filter.
final transactionFilterProvider =
    StateProvider<TransactionFilter>((ref) => const TransactionFilter());
