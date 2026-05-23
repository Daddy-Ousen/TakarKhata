import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:khatabook/core/theme/color_schemes.dart';
import 'package:khatabook/core/providers/app_providers.dart';
import 'package:khatabook/core/utils/currency_formatter.dart';
import 'package:khatabook/core/enums/transaction_type.dart' as khatabook;
import 'package:khatabook/features/transactions/domain/entities/transaction_entry.dart' as khatabook;
import 'package:khatabook/features/transactions/application/providers/transaction_providers.dart';
import 'package:khatabook/features/accounts/application/providers/account_providers.dart';
import 'package:khatabook/features/dashboard/presentation/pages/dashboard_page.dart';
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Data Management ──
          _SectionTitle('Data Management'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.upload_file),
                  title: const Text('Export Data'),
                  subtitle: const Text('Export all data as JSON'),
                  onTap: () => _exportData(context, ref),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.download),
                  title: const Text('Import Data'),
                  subtitle: const Text('Import from JSON backup'),
                  onTap: () => _importData(context, ref),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.delete_forever, color: AppColors.expense),
                  title: const Text('Wipe All Data', style: TextStyle(color: AppColors.expense)),
                  subtitle: const Text('Permanently delete all accounts, transactions, and loans'),
                  onTap: () => _confirmWipeData(context, ref),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Initial Balances ──
          _SectionTitle('Initial Balances'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.account_balance_wallet),
                  title: const Text('Set Initial Balances'),
                  subtitle: const Text('Set starting balance for each account'),
                  onTap: () => _manageInitialBalances(context, ref),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Ledger Integrity ──
          _SectionTitle('Ledger Integrity'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.verified),
                  title: const Text('Validate Integrity'),
                  subtitle: const Text('Check all account balances'),
                  onTap: () => _validateIntegrity(context, ref),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.build),
                  title: const Text('Repair Balances'),
                  subtitle: const Text('Recalculate all balances from ledger'),
                  onTap: () => _repairBalances(context, ref),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── App Info ──
          _SectionTitle('About'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('KhataBook'),
                  subtitle: const Text('Version 1.05'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: const Text('Privacy'),
                  subtitle: const Text(
                      'All data stored locally on your device'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Future<void> _exportData(BuildContext context, WidgetRef ref) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final service = ref.read(dataExportServiceProvider);
      final dir = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now()
          .toIso8601String()
          .replaceAll(':', '-')
          .split('.')
          .first;
      final filePath = '${dir.path}/khatabook_backup_$timestamp.json';

      final file = await service.exportToFile(filePath);
      if (context.mounted) Navigator.of(context, rootNavigator: true).pop();

      if (context.mounted) {
        final result = await showDialog<String>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.income),
                SizedBox(width: 10),
                Text('Export Successful'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Your data has been exported successfully.'),
                const SizedBox(height: 12),
                Text(
                  'File: ${file.path.split('/').last}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, 'close'),
                child: const Text('Close'),
              ),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(ctx, 'share'),
                icon: const Icon(Icons.share, size: 18),
                label: const Text('Share'),
              ),
            ],
          ),
        );

        if (result == 'share' && context.mounted) {
          await Share.shareXFiles(
            [XFile(file.path)],
            subject: 'KhataBook Backup',
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Export error: $e')));
      }
    }
  }

  Future<void> _importData(BuildContext context, WidgetRef ref) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.isEmpty) return;
      final filePath = result.files.single.path;
      if (filePath == null) return;

      // Confirm import
      if (!context.mounted) return;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Import Data'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'This will import data from the selected file. '
                'Existing records will not be duplicated.',
              ),
              const SizedBox(height: 12),
              Text(
                'File: ${result.files.single.name}',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Import'),
            ),
          ],
        ),
      );

      if (confirmed != true || !context.mounted) return;

      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      final service = ref.read(dataExportServiceProvider);
      final importResult = await service.importFromFile(filePath);

      // Recalculate balances after import
      await ref.read(financialEngineProvider).repairIntegrity();

      if (context.mounted) Navigator.of(context, rootNavigator: true).pop();

      if (context.mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.income),
                SizedBox(width: 10),
                Text('Import Complete'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ImportStat(
                    label: 'Accounts', count: importResult.accountsImported),
                _ImportStat(
                    label: 'Transactions',
                    count: importResult.transactionsImported),
                _ImportStat(
                    label: 'Loans', count: importResult.loansImported),
                _ImportStat(
                    label: 'Categories',
                    count: importResult.categoriesImported),
                if (importResult.skipped > 0) ...[
                  const Divider(),
                  Text(
                    '${importResult.skipped} records skipped (already exist)',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Import error: $e')));
      }
    }
  }

  Future<void> _confirmWipeData(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Wipe All Data'),
        content: const Text(
          'Are you absolutely sure you want to permanently delete all accounts, transactions, and loans? '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.expense),
            child: const Text('Wipe Data'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final doubleCheck = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Final Warning', style: TextStyle(color: AppColors.expense)),
          content: const Text('This is your last chance. Wipe all data completely?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.expense, foregroundColor: Colors.white),
              child: const Text('WIPE DATA'),
            ),
          ],
        ),
      );

      if (doubleCheck == true) {
        try {
          await ref.read(databaseProvider).clearAllData();
          ref.invalidate(dashboardDataProvider);
          ref.invalidate(accountsWithBalancesProvider);
          ref.invalidate(netWorthProvider);
          ref.invalidate(yearlyTrendsProvider);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('All data has been wiped successfully.')),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error wiping data: $e')),
            );
          }
        }
      }
    }
  }

  Future<void> _validateIntegrity(BuildContext context, WidgetRef ref) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final issues =
          await ref.read(financialEngineProvider).validateLedgerIntegrity();
      if (context.mounted) Navigator.of(context, rootNavigator: true).pop();

      if (context.mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Row(
              children: [
                Icon(
                  issues.isEmpty ? Icons.check_circle : Icons.warning,
                  color:
                      issues.isEmpty ? AppColors.income : AppColors.warning,
                ),
                const SizedBox(width: 10),
                Text(issues.isEmpty
                    ? 'All Good!'
                    : '${issues.length} Issues Found'),
              ],
            ),
            content: issues.isEmpty
                ? const Text('All account balances are correct.')
                : SizedBox(
                    width: double.maxFinite,
                    child: ListView(
                      shrinkWrap: true,
                      children: issues
                          .map((i) => ListTile(
                                dense: true,
                                title: Text(i.accountName),
                                subtitle: Text(i.message),
                              ))
                          .toList(),
                    ),
                  ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
                child: const Text('OK'),
              ),
              if (issues.isNotEmpty)
                ElevatedButton(
                  onPressed: () async {
                    Navigator.of(context, rootNavigator: true).pop();
                    await _repairBalances(context, ref);
                  },
                  child: const Text('Repair'),
                ),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _repairBalances(BuildContext context, WidgetRef ref) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final repaired =
          await ref.read(financialEngineProvider).repairIntegrity();
      if (context.mounted) Navigator.of(context, rootNavigator: true).pop();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(repaired > 0
                ? '$repaired account(s) repaired'
                : 'All balances are correct'),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _manageInitialBalances(BuildContext context, WidgetRef ref) async {
    showDialog(
      context: context,
      builder: (_) => const _InitialBalancesDialog(),
    );
  }
}

class _InitialBalancesDialog extends ConsumerStatefulWidget {
  const _InitialBalancesDialog();

  @override
  ConsumerState<_InitialBalancesDialog> createState() => _InitialBalancesDialogState();
}

class _InitialBalancesDialogState extends ConsumerState<_InitialBalancesDialog> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  bool _isLoading = false;

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    try {
      final engine = ref.read(financialEngineProvider);
      final transactionService = ref.read(transactionServiceProvider);
      final accounts = await ref.read(accountRepositoryProvider).getAllAccounts();
      final openingTxs = await ref.read(transactionRepositoryProvider)
          .getTransactionsByType(khatabook.TransactionType.openingBalance);

      for (final account in accounts) {
        final controller = _controllers[account.id];
        if (controller == null || controller.text.isEmpty) continue;

        int newAmount = CurrencyFormatter.parseOrThrow(controller.text);
        if (account.type.name == 'credit') {
          newAmount = -newAmount;
        }

        final existingTx = openingTxs.where((tx) => tx.accountId == account.id).firstOrNull;

        if (existingTx != null) {
          if (existingTx.amount != newAmount) {
            await transactionService.deleteTransaction(existingTx.id);
            if (newAmount != 0) {
              await transactionService.createOpeningBalance(
                accountId: account.id,
                amount: newAmount,
                balanceDate: existingTx.transactionDate,
              );
            }
          }
        } else if (newAmount != 0) {
          await transactionService.createOpeningBalance(
            accountId: account.id,
            amount: newAmount,
            balanceDate: DateTime.now(),
          );
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Initial balances saved')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(accountsStreamProvider);

    return AlertDialog(
      title: const Text('Set Initial Balances'),
      content: SizedBox(
        width: double.maxFinite,
        child: accountsAsync.when(
          data: (accounts) {
            if (accounts.isEmpty) {
              return const Text('No accounts found. Create an account first.');
            }

            return Form(
              key: _formKey,
              child: FutureBuilder<List<khatabook.TransactionEntry>>(
                future: ref.read(transactionRepositoryProvider)
                    .getTransactionsByType(khatabook.TransactionType.openingBalance),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const SizedBox(
                      height: 100,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final openingTxs = snapshot.data!;
                  return ListView(
                    shrinkWrap: true,
                    children: accounts.map((account) {
                      if (!_controllers.containsKey(account.id)) {
                        final tx = openingTxs.where((t) => t.accountId == account.id).firstOrNull;
                        _controllers[account.id] = TextEditingController(
                          text: tx != null && tx.amount != 0 
                              ? CurrencyFormatter.formatPlain(tx.amount.abs()) 
                              : '',
                        );
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: TextFormField(
                          controller: _controllers[account.id],
                          decoration: InputDecoration(
                            labelText: account.name,
                            prefixIcon: const Icon(Icons.account_balance),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            );
          },
          loading: () => const SizedBox(
            height: 100,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Text('Error: $e'),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _save,
          child: _isLoading 
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Save'),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _ImportStat extends StatelessWidget {
  final String label;
  final int count;
  const _ImportStat({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            count > 0 ? Icons.check_circle : Icons.remove_circle_outline,
            size: 16,
            color: count > 0 ? AppColors.income : AppColors.textMuted,
          ),
          const SizedBox(width: 8),
          Text(label),
          const Spacer(),
          Text(
            '$count',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: count > 0 ? AppColors.textPrimary : AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
