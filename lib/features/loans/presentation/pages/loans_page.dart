import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khatabook/core/enums/loan_type.dart';
import 'package:khatabook/core/extensions/num_extensions.dart';
import 'package:khatabook/core/theme/color_schemes.dart';
import 'package:khatabook/core/utils/currency_formatter.dart';
import 'package:khatabook/core/utils/date_formatter.dart';
import 'package:khatabook/core/providers/app_providers.dart';
import 'package:khatabook/features/accounts/application/providers/account_providers.dart';
import 'package:khatabook/features/loans/domain/entities/loan.dart';

/// Provider for reactive loan list.
final loansStreamProvider = StreamProvider<List<Loan>>((ref) {
  return ref.watch(loanRepositoryProvider).watchAllLoans();
});

class LoansPage extends ConsumerWidget {
  const LoansPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loansAsync = ref.watch(loansStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Loans'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showLoanForm(context, ref),
          ),
        ],
      ),
      body: loansAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
        data: (loans) {
          if (loans.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.handshake_outlined,
                      size: 64, color: AppColors.textMuted),
                  const SizedBox(height: 16),
                  Text('No loans recorded',
                      style: TextStyle(
                          fontSize: 18, color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  Text('Tap + to track personal loans',
                      style:
                          TextStyle(fontSize: 14, color: AppColors.textMuted)),
                ],
              ),
            );
          }

          final active = loans.where((l) => l.status.isActive).toList();
          final settled = loans.where((l) => !l.status.isActive).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Summary cards
              _LoanSummaryCards(loans: active),
              const SizedBox(height: 20),

              if (active.isNotEmpty) ...[
                _SectionHeader(title: 'Active Loans', count: active.length),
                ...active.map((loan) => _LoanCard(
                      loan: loan,
                      onPayment: () => _showPaymentDialog(context, ref, loan),
                    )),
                const SizedBox(height: 16),
              ],

              if (settled.isNotEmpty) ...[
                _SectionHeader(
                    title: 'Settled', count: settled.length),
                ...settled.map((loan) => _LoanCard(loan: loan)),
              ],
            ],
          );
        },
      ),
    );
  }

  void _showLoanForm(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => const _LoanFormSheet(),
    );
  }

  void _showPaymentDialog(
      BuildContext context, WidgetRef ref, Loan loan) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Payment for ${loan.personName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Remaining: ${loan.remainingAmount.toCurrencyString()}'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Payment Amount',
                prefixText: '৳ ',
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final amount =
                  CurrencyFormatter.parse(controller.text) ?? 0;
              if (amount > 0) {
                await ref.read(loanServiceProvider).recordPayment(
                      loanId: loan.id,
                      amount: amount,
                      paymentDate: DateTime.now(),
                      accountId: loan.linkedAccountId,
                    );
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            child: const Text('Record Payment'),
          ),
        ],
      ),
    );
  }
}

class _LoanSummaryCards extends StatelessWidget {
  final List<Loan> loans;
  const _LoanSummaryCards({required this.loans});

  @override
  Widget build(BuildContext context) {
    int totalOwed = 0;
    int totalReceivable = 0;
    for (final loan in loans) {
      if (loan.type == LoanType.iOwe) {
        totalOwed += loan.remainingAmount;
      } else {
        totalReceivable += loan.remainingAmount;
      }
    }

    return Row(
      children: [
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.arrow_upward,
                          color: AppColors.expense, size: 18),
                      const SizedBox(width: 6),
                      Text('I Owe',
                          style: TextStyle(
                              color: AppColors.textSecondary, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    totalOwed.toCurrencyString(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.expense,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.arrow_downward,
                          color: AppColors.income, size: 18),
                      const SizedBox(width: 6),
                      Text('Owed To Me',
                          style: TextStyle(
                              color: AppColors.textSecondary, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    totalReceivable.toCurrencyString(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.income,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  const _SectionHeader({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(title,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHighDark,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text('$count',
                style: TextStyle(
                    fontSize: 12, color: AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }
}

class _LoanCard extends StatelessWidget {
  final Loan loan;
  final VoidCallback? onPayment;

  const _LoanCard({required this.loan, this.onPayment});

  @override
  Widget build(BuildContext context) {
    final isOwed = loan.type == LoanType.iOwe;
    final color = isOwed ? AppColors.expense : AppColors.income;
    final progress = 1.0 -
        (loan.remainingAmount / loan.originalAmount).clamp(0.0, 1.0);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: color.withValues(alpha: 0.15),
                  radius: 20,
                  child: Text(
                    loan.personName[0].toUpperCase(),
                    style: TextStyle(
                        color: color, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(loan.personName,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 15)),
                      Text(
                        '${loan.type.label} · ${DateFormatter.formatDate(loan.loanDate)}',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      loan.remainingAmount.toCurrencyString(),
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'of ${loan.originalAmount.toCurrencyString()}',
                      style: TextStyle(
                          fontSize: 11, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.surfaceContainerHighDark,
                color: color,
                minHeight: 6,
              ),
            ),
            if (onPayment != null && loan.status.isActive) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: onPayment,
                  icon: const Icon(Icons.payment, size: 18),
                  label: const Text('Record Payment'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Loan Form Sheet ───────────────────────────────────────────────────────────

class _LoanFormSheet extends ConsumerStatefulWidget {
  const _LoanFormSheet();

  @override
  ConsumerState<_LoanFormSheet> createState() => _LoanFormSheetState();
}

class _LoanFormSheetState extends ConsumerState<_LoanFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  LoanType _type = LoanType.owedToMe;
  String? _accountId;
  final DateTime _date = DateTime.now();

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(accountsStreamProvider);

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('New Loan',
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              SegmentedButton<LoanType>(
                segments: LoanType.values
                    .map((t) => ButtonSegment(
                        value: t, label: Text(t.label)))
                    .toList(),
                selected: {_type},
                onSelectionChanged: (s) =>
                    setState(() => _type = s.first),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Person Name',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Enter a name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  prefixText: '৳ ',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                    decimal: true),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Enter amount';
                  final cents = CurrencyFormatter.parse(v);
                  if (cents == null || cents <= 0) return 'Invalid amount';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              accountsAsync.when(
                data: (accounts) => DropdownButtonFormField<String>(
                  initialValue: _accountId,
                  decoration: const InputDecoration(
                    labelText: 'Linked Account (optional)',
                    prefixIcon: Icon(Icons.account_balance_wallet),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('None')),
                    ...accounts.map((a) => DropdownMenuItem(
                        value: a.id, child: Text(a.name))),
                  ],
                  onChanged: (v) => setState(() => _accountId = v),
                ),
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  prefixIcon: Icon(Icons.note),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Create Loan'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await ref.read(loanServiceProvider).createLoan(
            personName: _nameController.text,
            type: _type,
            amount: CurrencyFormatter.parseOrThrow(_amountController.text),
            loanDate: _date,
            notes: _notesController.text.isEmpty
                ? null
                : _notesController.text,
            linkedAccountId: _accountId,
          );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }
}
