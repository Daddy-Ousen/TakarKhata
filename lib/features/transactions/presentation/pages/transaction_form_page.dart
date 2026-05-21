import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:khatabook/core/enums/transaction_type.dart';
import 'package:khatabook/core/theme/color_schemes.dart';
import 'package:khatabook/core/utils/currency_formatter.dart';
import 'package:khatabook/core/providers/app_providers.dart';
import 'package:khatabook/features/accounts/application/providers/account_providers.dart';
import 'package:khatabook/features/categories/domain/entities/category.dart'
    as domain;
import 'package:khatabook/features/transactions/application/providers/transaction_providers.dart';

class TransactionFormPage extends ConsumerStatefulWidget {
  final String? transactionId;
  const TransactionFormPage({super.key, this.transactionId});

  @override
  ConsumerState<TransactionFormPage> createState() =>
      _TransactionFormPageState();
}

class _TransactionFormPageState extends ConsumerState<TransactionFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  final _feeController = TextEditingController();

  TransactionType _type = TransactionType.expense;
  String? _accountId;
  String? _destinationAccountId;
  String? _categoryId;
  DateTime _transactionDate = DateTime.now();
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.transactionId != null) {
      _isEditing = true;
      _loadTransaction();
    }
  }

  Future<void> _loadTransaction() async {
    final txn = await ref
        .read(transactionRepositoryProvider)
        .getTransactionById(widget.transactionId!);
    if (txn != null && mounted) {
      setState(() {
        _type = txn.type;
        _amountController.text =
            CurrencyFormatter.formatPlain(txn.amount);
        _notesController.text = txn.notes ?? '';
        _accountId = txn.accountId;
        _destinationAccountId = txn.destinationAccountId;
        _categoryId = txn.categoryId;
        _transactionDate = txn.transactionDate;
        if (txn.transferFee > 0) {
          _feeController.text =
              CurrencyFormatter.formatPlain(txn.transferFee);
        }
      });
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    _feeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(accountsStreamProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Transaction' : 'New Transaction'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              onPressed: _deleteTransaction,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // ── Transaction Type Selector ──
            _TypeSelector(
              selected: _type,
              onChanged: (type) => setState(() => _type = type),
            ),
            const SizedBox(height: 24),

            // ── Amount Input ──
            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: 'Amount',
                prefixText: '৳ ',
                prefixStyle: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) return 'Enter an amount';
                final cents = CurrencyFormatter.parse(value);
                if (cents == null || cents <= 0) return 'Enter a valid amount';
                return null;
              },
              autofocus: !_isEditing,
            ),
            const SizedBox(height: 20),

            // ── Account Selector ──
            accountsAsync.when(
              data: (accounts) => DropdownButtonFormField<String>(
                initialValue: _accountId,
                decoration: InputDecoration(
                  labelText: _type == TransactionType.transfer
                      ? 'From Account'
                      : 'Account',
                  prefixIcon: const Icon(Icons.account_balance_wallet),
                ),
                items: accounts
                    .map((a) => DropdownMenuItem(
                          value: a.id,
                          child: Text(a.name),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _accountId = v),
                validator: (v) => v == null ? 'Select an account' : null,
              ),
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const Text('Error loading accounts'),
            ),
            const SizedBox(height: 20),

            // ── Destination Account (transfers only) ──
            if (_type == TransactionType.transfer) ...[
              accountsAsync.when(
                data: (accounts) => DropdownButtonFormField<String>(
                  initialValue: _destinationAccountId,
                  decoration: const InputDecoration(
                    labelText: 'To Account',
                    prefixIcon: Icon(Icons.account_balance),
                  ),
                  items: accounts
                      .where((a) => a.id != _accountId)
                      .map((a) => DropdownMenuItem(
                            value: a.id,
                            child: Text(a.name),
                          ))
                      .toList(),
                  onChanged: (v) =>
                      setState(() => _destinationAccountId = v),
                  validator: (v) =>
                      v == null ? 'Select destination account' : null,
                ),
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const Text('Error'),
              ),
              const SizedBox(height: 20),

              // Transfer fee
              TextFormField(
                controller: _feeController,
                decoration: const InputDecoration(
                  labelText: 'Transfer Fee (optional)',
                  prefixText: '৳ ',
                  prefixIcon: Icon(Icons.money_off),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
                ],
              ),
              const SizedBox(height: 20),
            ],

            // ── Category (income/expense only) ──
            if (_type != TransactionType.transfer)
              categoriesAsync.when(
                data: (categories) => DropdownButtonFormField<String>(
                  initialValue: _categoryId,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: categories
                      .map((c) => DropdownMenuItem(
                            value: c.id,
                            child: Text(c.name),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _categoryId = v),
                ),
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const Text('Error loading categories'),
              ),
            const SizedBox(height: 20),

            // ── Date Picker ──
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today),
              title: Text(
                '${_transactionDate.day}/${_transactionDate.month}/${_transactionDate.year}',
                style: const TextStyle(fontSize: 16),
              ),
              subtitle: Text(
                '${_transactionDate.hour.toString().padLeft(2, '0')}:${_transactionDate.minute.toString().padLeft(2, '0')}',
              ),
              onTap: _pickDateTime,
            ),
            const SizedBox(height: 20),

            // ── Notes ──
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes',
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 32),

            // ── Submit Button ──
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        _isEditing ? 'Update Transaction' : 'Add Transaction',
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _transactionDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_transactionDate),
      );
      if (mounted) {
        setState(() {
          _transactionDate = DateTime(
            date.year,
            date.month,
            date.day,
            time?.hour ?? _transactionDate.hour,
            time?.minute ?? _transactionDate.minute,
          );
        });
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final amount = CurrencyFormatter.parseOrThrow(_amountController.text);
      final service = ref.read(transactionServiceProvider);
      final notes =
          _notesController.text.isEmpty ? null : _notesController.text;

      if (_type == TransactionType.transfer) {
        final fee = _feeController.text.isNotEmpty
            ? CurrencyFormatter.parse(_feeController.text) ?? 0
            : 0;
        await service.createTransfer(
          amount: amount,
          sourceAccountId: _accountId!,
          destinationAccountId: _destinationAccountId!,
          transferFee: fee,
          notes: notes,
          transactionDate: _transactionDate,
        );
      } else {
        await service.createTransaction(
          type: _type,
          amount: amount,
          accountId: _accountId!,
          categoryId: _categoryId,
          notes: notes,
          transactionDate: _transactionDate,
        );
      }

      ref.invalidate(recentTransactionsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing
                ? 'Transaction updated'
                : 'Transaction added'),
          ),
        );
        context.pop();
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

  Future<void> _deleteTransaction() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: const Text('Are you sure you want to delete this transaction?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(transactionServiceProvider).deleteTransaction(widget.transactionId!);
      ref.invalidate(recentTransactionsProvider);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaction deleted')),
        );
        context.pop();
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
}

// ── Category stream provider ─────────────────────────────────────────────────

final categoriesProvider =
    StreamProvider<List<domain.Category>>((ref) {
  return ref.watch(categoryRepositoryProvider).watchAllCategories();
});

// ── Type Selector Widget ──────────────────────────────────────────────────────

class _TypeSelector extends StatelessWidget {
  final TransactionType selected;
  final ValueChanged<TransactionType> onChanged;

  const _TypeSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<TransactionType>(
      segments: [
        ButtonSegment(
          value: TransactionType.income,
          icon: const Icon(Icons.arrow_downward, size: 18),
          label: const Text('Income'),
        ),
        ButtonSegment(
          value: TransactionType.expense,
          icon: const Icon(Icons.arrow_upward, size: 18),
          label: const Text('Expense'),
        ),
        ButtonSegment(
          value: TransactionType.transfer,
          icon: const Icon(Icons.swap_horiz, size: 18),
          label: const Text('Transfer'),
        ),
      ],
      selected: {selected},
      onSelectionChanged: (set) => onChanged(set.first),
      style: SegmentedButton.styleFrom(
        selectedBackgroundColor: _getColor(selected).withValues(alpha: 0.2),
        selectedForegroundColor: _getColor(selected),
      ),
    );
  }

  Color _getColor(TransactionType type) {
    switch (type) {
      case TransactionType.income:
        return AppColors.income;
      case TransactionType.expense:
        return AppColors.expense;
      case TransactionType.transfer:
        return AppColors.transfer;
      default:
        return AppColors.textPrimary;
    }
  }
}
