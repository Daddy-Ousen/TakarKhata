import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:khatabook/core/enums/transaction_type.dart';
import 'package:khatabook/core/extensions/num_extensions.dart';
import 'package:khatabook/core/theme/color_schemes.dart';
import 'package:khatabook/core/utils/date_formatter.dart';
import 'package:khatabook/core/providers/app_providers.dart';
import 'package:khatabook/features/transactions/application/providers/transaction_providers.dart';
import 'package:khatabook/features/transactions/domain/entities/transaction_entry.dart';

class LedgerPage extends ConsumerStatefulWidget {
  final String? categoryId;

  const LedgerPage({super.key, this.categoryId});

  @override
  ConsumerState<LedgerPage> createState() => _LedgerPageState();
}

class _LedgerPageState extends ConsumerState<LedgerPage> {
  final _searchController = TextEditingController();
  bool _showSearch = false;
  final Set<String> _selectedIds = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var filter = ref.watch(transactionFilterProvider);
    if (widget.categoryId != null) {
      filter = filter.copyWith(categoryId: widget.categoryId);
    }
    
    final transactionsAsync = filter == const TransactionFilter()
        ? ref.watch(recentTransactionsProvider)
        : ref.watch(filteredTransactionsProvider(filter));

    return Scaffold(
      appBar: _selectedIds.isNotEmpty
          ? AppBar(
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: _clearSelection,
              ),
              title: Text('${_selectedIds.length} selected'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: _confirmBatchDelete,
                ),
              ],
            )
          : AppBar(
              title: _showSearch
                  ? TextField(
                      controller: _searchController,
                      autofocus: true,
                      decoration: const InputDecoration(
                        hintText: 'Search transactions...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: (query) {
                        ref.read(transactionFilterProvider.notifier).state =
                            TransactionFilter(searchQuery: query);
                      },
                    )
                  : const Text('Ledger'),
              actions: [
                IconButton(
                  icon: Icon(_showSearch ? Icons.close : Icons.search),
                  onPressed: () {
                    setState(() {
                      _showSearch = !_showSearch;
                      if (!_showSearch) {
                        _searchController.clear();
                        ref.read(transactionFilterProvider.notifier).state =
                            const TransactionFilter();
                      }
                    });
                  },
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.filter_list),
                  onSelected: (value) => _handleFilter(value),
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'all', child: Text('All')),
                    const PopupMenuItem(value: 'income', child: Text('Income')),
                    const PopupMenuItem(value: 'expense', child: Text('Expenses')),
                    const PopupMenuItem(value: 'transfer', child: Text('Transfers')),
                  ],
                ),
              ],
            ),
      body: transactionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.expense),
              const SizedBox(height: 16),
              Text('Error loading transactions: $e'),
            ],
          ),
        ),
        data: (transactions) {
          if (transactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_outlined,
                      size: 64, color: AppColors.textMuted),
                  const SizedBox(height: 16),
                  Text(
                    'No transactions yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to add your first transaction',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            );
          }

          // Group transactions by date
          final grouped = _groupByDate(transactions);

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: grouped.length,
            itemBuilder: (context, index) {
              final group = grouped[index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Row(
                      children: [
                        Text(
                          DateFormatter.formatRelative(group.date),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          group.dayTotal.toCurrencyString(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: group.dayTotal >= 0
                                ? AppColors.income
                                : AppColors.expense,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Transaction tiles
                  ...group.transactions.map(
                    (txn) => _TransactionTile(
                      transaction: txn,
                      isSelected: _selectedIds.contains(txn.id),
                      isSelectionMode: _selectedIds.isNotEmpty,
                      onTap: () {
                        if (_selectedIds.isNotEmpty) {
                          _toggleSelection(txn.id);
                        } else {
                          context.push('/transaction/edit/${txn.id}');
                        }
                      },
                      onLongPress: () => _toggleSelection(txn.id),
                      onDelete: () => _confirmDelete(txn),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  void _handleFilter(String value) {
    TransactionType? type;
    switch (value) {
      case 'income':
        type = TransactionType.income;
        break;
      case 'expense':
        type = TransactionType.expense;
        break;
      case 'transfer':
        type = TransactionType.transfer;
        break;
    }
    ref.read(transactionFilterProvider.notifier).state =
        TransactionFilter(type: type);
  }

  Future<void> _confirmDelete(TransactionEntry txn) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: const Text(
          'Are you sure you want to delete this transaction? '
          'Account balances will be recalculated.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.expense),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await ref.read(transactionServiceProvider).deleteTransaction(txn.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Transaction deleted')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedIds.clear();
    });
  }

  Future<void> _confirmBatchDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transactions'),
        content: Text(
          'Are you sure you want to delete ${_selectedIds.length} transactions? '
          'Account balances will be recalculated.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.expense),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await ref.read(transactionServiceProvider).batchDeleteTransactions(_selectedIds.toList());
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${_selectedIds.length} transactions deleted')),
          );
          _clearSelection();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  List<_DateGroup> _groupByDate(List<TransactionEntry> transactions) {
    final map = <String, List<TransactionEntry>>{};
    for (final txn in transactions) {
      final key = DateFormatter.formatIso(txn.transactionDate);
      (map[key] ??= []).add(txn);
    }

    return map.entries.map((e) {
      final txns = e.value;
      int dayTotal = 0;
      for (final t in txns) {
        if (t.type == TransactionType.income ||
            t.type == TransactionType.openingBalance) {
          dayTotal += t.amount;
        } else if (t.type == TransactionType.expense) {
          dayTotal -= t.amount;
        }
      }
      return _DateGroup(
        date: txns.first.transactionDate,
        transactions: txns,
        dayTotal: dayTotal,
      );
    }).toList();
  }
}

class _DateGroup {
  final DateTime date;
  final List<TransactionEntry> transactions;
  final int dayTotal;

  const _DateGroup({
    required this.date,
    required this.transactions,
    required this.dayTotal,
  });
}

// ── Transaction Tile ──────────────────────────────────────────────────────────

class _TransactionTile extends StatelessWidget {
  final TransactionEntry transaction;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onDelete;
  final bool isSelected;
  final bool isSelectionMode;

  const _TransactionTile({
    required this.transaction,
    required this.onTap,
    required this.onLongPress,
    required this.onDelete,
    this.isSelected = false,
    this.isSelectionMode = false,
  });

  Color get _typeColor {
    switch (transaction.type) {
      case TransactionType.income:
      case TransactionType.openingBalance:
        return AppColors.income;
      case TransactionType.expense:
        return AppColors.expense;
      case TransactionType.transfer:
        return AppColors.transfer;
    }
  }

  IconData get _typeIcon {
    switch (transaction.type) {
      case TransactionType.income:
        return Icons.arrow_downward;
      case TransactionType.expense:
        return Icons.arrow_upward;
      case TransactionType.transfer:
        return Icons.swap_horiz;
      case TransactionType.openingBalance:
        return Icons.account_balance;
    }
  }

  String get _amountPrefix {
    switch (transaction.type) {
      case TransactionType.income:
      case TransactionType.openingBalance:
        return '+';
      case TransactionType.expense:
        return '-';
      case TransactionType.transfer:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(transaction.id),
      direction: isSelectionMode ? DismissDirection.none : DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppColors.expense.withValues(alpha: 0.3),
        child: const Icon(Icons.delete, color: AppColors.expense),
      ),
      confirmDismiss: (_) async {
        if (!isSelectionMode) {
          onDelete();
        }
        return false;
      },
      child: Container(
        color: isSelected ? AppColors.seedColor.withValues(alpha: 0.1) : null,
        child: ListTile(
          onTap: onTap,
          onLongPress: onLongPress,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          leading: isSelectionMode
              ? Checkbox(
                  value: isSelected,
                  onChanged: (_) => onLongPress(),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                )
              : Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _typeColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_typeIcon, color: _typeColor, size: 20),
                ),
        title: Text(
          transaction.notes ?? transaction.type.label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          DateFormatter.formatTime(transaction.transactionDate),
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textMuted,
          ),
        ),
        trailing: Text(
          '$_amountPrefix${transaction.amount.toCurrencyString()}',
          style: TextStyle(
            color: _typeColor,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
      ),
    );
  }
}
