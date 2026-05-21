import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khatabook/core/enums/account_type.dart';
import 'package:khatabook/core/extensions/num_extensions.dart';
import 'package:khatabook/core/theme/color_schemes.dart';
import 'package:khatabook/core/utils/currency_formatter.dart';
import 'package:khatabook/core/providers/app_providers.dart';
import 'package:khatabook/features/accounts/application/providers/account_providers.dart';
import 'package:khatabook/features/accounts/domain/entities/account.dart';

class AccountsPage extends ConsumerWidget {
  const AccountsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(accountsWithBalancesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accounts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAccountForm(context, ref),
          ),
        ],
      ),
      body: accountsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
        data: (accounts) {
          if (accounts.isEmpty) {
            return const Center(
              child: Text('No accounts. Tap + to create one.'),
            );
          }

          // Group by type
          final grouped = <AccountType, List<Account>>{};
          for (final account in accounts) {
            (grouped[account.type] ??= []).add(account);
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Total balance card
              _TotalBalanceCard(accounts: accounts),
              const SizedBox(height: 24),

              for (final type in AccountType.values)
                if (grouped.containsKey(type)) ...[
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 8),
                    child: Text(
                      type.label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  ...grouped[type]!.map(
                    (account) => _AccountCard(
                      account: account,
                      onTap: () =>
                          _showAccountForm(context, ref, account: account),
                      onArchive: () => _confirmArchive(context, ref, account),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
            ],
          );
        },
      ),
    );
  }

  void _showAccountForm(BuildContext context, WidgetRef ref,
      {Account? account}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _AccountFormSheet(account: account),
    ).then((_) => ref.invalidate(accountsWithBalancesProvider));
  }

  Future<void> _confirmArchive(
      BuildContext context, WidgetRef ref, Account account) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Archive Account'),
        content: Text('Archive "${account.name}"? It will be hidden from lists.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.expense),
            child: const Text('Archive'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(accountServiceProvider).archiveAccount(account.id);
      ref.invalidate(accountsWithBalancesProvider);
    }
  }
}

class _TotalBalanceCard extends StatelessWidget {
  final List<Account> accounts;
  const _TotalBalanceCard({required this.accounts});

  @override
  Widget build(BuildContext context) {
    int totalAssets = 0;
    int totalLiabilities = 0;
    for (final a in accounts) {
      if (a.type.isAsset) {
        totalAssets += a.cachedBalance;
      } else {
        totalLiabilities += a.cachedBalance.abs();
      }
    }

    return Card(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              AppColors.accentBlue.withValues(alpha: 0.12),
              AppColors.accentPurple.withValues(alpha: 0.08),
            ],
          ),
        ),
        child: Column(
          children: [
            Text('Total Assets',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 4),
            Text(
              totalAssets.toCurrencyString(),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.income,
              ),
            ),
            if (totalLiabilities > 0) ...[
              const SizedBox(height: 8),
              Text(
                'Liabilities: ${totalLiabilities.toCurrencyString()}',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.expense,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  final Account account;
  final VoidCallback onTap;
  final VoidCallback onArchive;

  const _AccountCard({
    required this.account,
    required this.onTap,
    required this.onArchive,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(account.colorValue ?? 0xFF78909C);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        onLongPress: onArchive,
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.account_balance_wallet, color: color, size: 22),
        ),
        title: Text(
          account.name,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          account.type.label,
          style: TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
        trailing: Text(
          account.cachedBalance.toCurrencyString(),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: account.cachedBalance >= 0
                ? AppColors.income
                : AppColors.expense,
          ),
        ),
      ),
    );
  }
}

// ── Account Form ──────────────────────────────────────────────────────────────

class _AccountFormSheet extends ConsumerStatefulWidget {
  final Account? account;
  const _AccountFormSheet({this.account});

  @override
  ConsumerState<_AccountFormSheet> createState() => _AccountFormSheetState();
}

class _AccountFormSheetState extends ConsumerState<_AccountFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _openingBalanceController = TextEditingController();
  AccountType _type = AccountType.debit;

  @override
  void initState() {
    super.initState();
    if (widget.account != null) {
      _nameController.text = widget.account!.name;
      _type = widget.account!.type;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _openingBalanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.account != null ? 'Edit Account' : 'New Account',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Account Name',
                prefixIcon: Icon(Icons.label),
              ),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Enter account name' : null,
              autofocus: true,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<AccountType>(
              initialValue: _type,
              decoration: const InputDecoration(
                labelText: 'Account Type',
                prefixIcon: Icon(Icons.category),
              ),
              items: AccountType.values
                  .map((t) => DropdownMenuItem(value: t, child: Text(t.label)))
                  .toList(),
              onChanged: (v) => setState(() => _type = v!),
            ),
            if (widget.account == null) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _openingBalanceController,
                decoration: const InputDecoration(
                  labelText: 'Opening Balance (optional)',
                  prefixText: '৳ ',
                  prefixIcon: Icon(Icons.account_balance),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submit,
              child: Text(widget.account != null ? 'Update' : 'Create'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final service = ref.read(accountServiceProvider);
      if (widget.account != null) {
        await service.updateAccount(
          widget.account!.copyWith(
            name: _nameController.text,
            type: _type,
          ),
        );
      } else {
        final openingBalance =
            CurrencyFormatter.parse(_openingBalanceController.text) ?? 0;
        await service.createAccount(
          name: _nameController.text,
          type: _type,
          openingBalance: openingBalance,
        );
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }
}
