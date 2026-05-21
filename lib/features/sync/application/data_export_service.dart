import 'dart:convert';
import 'dart:io';

import 'package:khatabook/core/enums/account_type.dart';
import 'package:khatabook/core/enums/loan_status.dart';
import 'package:khatabook/core/enums/loan_type.dart';
import 'package:khatabook/core/enums/transaction_type.dart';
import 'package:khatabook/features/accounts/domain/entities/account.dart';
import 'package:khatabook/features/accounts/domain/repositories/account_repository.dart';
import 'package:khatabook/features/categories/domain/entities/category.dart'
    as domain;
import 'package:khatabook/features/categories/domain/repositories/category_repository.dart';
import 'package:khatabook/features/loans/domain/entities/loan.dart';
import 'package:khatabook/features/loans/domain/repositories/loan_repository.dart';
import 'package:khatabook/features/transactions/domain/entities/transaction_entry.dart';
import 'package:khatabook/features/transactions/domain/repositories/transaction_repository.dart';

/// Service responsible for exporting and importing all app data as JSON.
///
/// This is the primary offline sync mechanism — users can export
/// their entire ledger as a portable JSON file and import it on
/// another device or after a fresh install.
class DataExportService {
  final AccountRepository _accountRepo;
  final TransactionRepository _transactionRepo;
  final LoanRepository _loanRepo;
  final CategoryRepository _categoryRepo;

  DataExportService({
    required AccountRepository accountRepo,
    required TransactionRepository transactionRepo,
    required LoanRepository loanRepo,
    required CategoryRepository categoryRepo,
  })  : _accountRepo = accountRepo,
        _transactionRepo = transactionRepo,
        _loanRepo = loanRepo,
        _categoryRepo = categoryRepo;

  // ── Export ─────────────────────────────────────────────────────────────────

  /// Export all data to a JSON string.
  Future<String> exportToJson() async {
    final accounts = await _accountRepo.getAllAccounts();
    final transactions = await _transactionRepo.getAllTransactions();
    final loans = await _loanRepo.getAllLoans();
    final categories = await _categoryRepo.getAllCategories();

    final data = {
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'appName': 'KhataBook',
      'accounts': accounts.map(_accountToJson).toList(),
      'transactions': transactions.map(_transactionToJson).toList(),
      'loans': loans.map(_loanToJson).toList(),
      'categories': categories.map(_categoryToJson).toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(data);
  }

  /// Export all data to a file at the given path.
  Future<File> exportToFile(String path) async {
    final json = await exportToJson();
    final file = File(path);
    await file.writeAsString(json, flush: true);
    return file;
  }

  // ── Import ─────────────────────────────────────────────────────────────────

  /// Import data from a JSON string.
  ///
  /// Returns a summary of what was imported.
  Future<ImportResult> importFromJson(String jsonString) async {
    final Map<String, dynamic> data;
    try {
      data = json.decode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      throw FormatException('Invalid JSON format: $e');
    }

    final version = data['version'] as int? ?? 1;
    if (version > 1) {
      throw UnsupportedError('Unsupported export version: $version');
    }

    int accountsImported = 0;
    int transactionsImported = 0;
    int loansImported = 0;
    int categoriesImported = 0;
    int skipped = 0;

    // Import categories first (transactions reference them)
    final categoriesList = data['categories'] as List<dynamic>? ?? [];
    for (final catJson in categoriesList) {
      try {
        final category = _categoryFromJson(catJson as Map<String, dynamic>);
        final existing = await _categoryRepo.getCategoryById(category.id);
        if (existing == null) {
          await _categoryRepo.createCategory(category);
          categoriesImported++;
        } else {
          skipped++;
        }
      } catch (_) {
        skipped++;
      }
    }

    // Import accounts
    final accountsList = data['accounts'] as List<dynamic>? ?? [];
    for (final accJson in accountsList) {
      try {
        final account = _accountFromJson(accJson as Map<String, dynamic>);
        final existing = await _accountRepo.getAccountById(account.id);
        if (existing == null) {
          await _accountRepo.createAccount(account);
          accountsImported++;
        } else {
          skipped++;
        }
      } catch (_) {
        skipped++;
      }
    }

    // Import transactions
    final transactionsList = data['transactions'] as List<dynamic>? ?? [];
    for (final txnJson in transactionsList) {
      try {
        final txn = _transactionFromJson(txnJson as Map<String, dynamic>);
        final existing =
            await _transactionRepo.getTransactionById(txn.id);
        if (existing == null) {
          await _transactionRepo.createTransaction(txn);
          transactionsImported++;
        } else {
          skipped++;
        }
      } catch (_) {
        skipped++;
      }
    }

    // Import loans
    final loansList = data['loans'] as List<dynamic>? ?? [];
    for (final loanJson in loansList) {
      try {
        final loan = _loanFromJson(loanJson as Map<String, dynamic>);
        final existing = await _loanRepo.getLoanById(loan.id);
        if (existing == null) {
          await _loanRepo.createLoan(loan);
          loansImported++;
        } else {
          skipped++;
        }
      } catch (_) {
        skipped++;
      }
    }

    return ImportResult(
      accountsImported: accountsImported,
      transactionsImported: transactionsImported,
      loansImported: loansImported,
      categoriesImported: categoriesImported,
      skipped: skipped,
    );
  }

  /// Import data from a file at the given path.
  Future<ImportResult> importFromFile(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      throw FileSystemException('File not found', path);
    }
    final contents = await file.readAsString();
    return importFromJson(contents);
  }

  // ── JSON serialization helpers ─────────────────────────────────────────────

  Map<String, dynamic> _accountToJson(Account a) => {
        'id': a.id,
        'name': a.name,
        'type': a.type.name,
        'iconName': a.iconName,
        'colorValue': a.colorValue,
        'isArchived': a.isArchived,
        'sortOrder': a.sortOrder,
        'createdAt': a.createdAt.toIso8601String(),
        'modifiedAt': a.modifiedAt.toIso8601String(),
        'syncVersion': a.syncVersion,
        'cachedBalance': a.cachedBalance,
      };

  Map<String, dynamic> _transactionToJson(TransactionEntry t) => {
        'id': t.id,
        'type': t.type.name,
        'amount': t.amount,
        'accountId': t.accountId,
        'destinationAccountId': t.destinationAccountId,
        'categoryId': t.categoryId,
        'transferFee': t.transferFee,
        'transferGroupId': t.transferGroupId,
        'notes': t.notes,
        'transactionDate': t.transactionDate.toIso8601String(),
        'createdAt': t.createdAt.toIso8601String(),
        'modifiedAt': t.modifiedAt.toIso8601String(),
        'syncVersion': t.syncVersion,
        'isDeleted': t.isDeleted,
      };

  Map<String, dynamic> _loanToJson(Loan l) => {
        'id': l.id,
        'personName': l.personName,
        'type': l.type.name,
        'originalAmount': l.originalAmount,
        'remainingAmount': l.remainingAmount,
        'status': l.status.name,
        'linkedAccountId': l.linkedAccountId,
        'notes': l.notes,
        'loanDate': l.loanDate.toIso8601String(),
        'createdAt': l.createdAt.toIso8601String(),
        'modifiedAt': l.modifiedAt.toIso8601String(),
        'syncVersion': l.syncVersion,
      };

  Map<String, dynamic> _categoryToJson(domain.Category c) => {
        'id': c.id,
        'name': c.name,
        'iconName': c.iconName,
        'colorValue': c.colorValue,
        'sortOrder': c.sortOrder,
        'createdAt': c.createdAt.toIso8601String(),
        'modifiedAt': c.modifiedAt.toIso8601String(),
      };

  // ── JSON deserialization helpers ────────────────────────────────────────────

  Account _accountFromJson(Map<String, dynamic> j) => Account(
        id: j['id'] as String,
        name: j['name'] as String,
        type: AccountType.values.byName(j['type'] as String),
        iconName: j['iconName'] as String?,
        colorValue: j['colorValue'] as int?,
        isArchived: j['isArchived'] as bool? ?? false,
        sortOrder: j['sortOrder'] as int? ?? 0,
        createdAt: DateTime.parse(j['createdAt'] as String),
        modifiedAt: DateTime.parse(j['modifiedAt'] as String),
        syncVersion: j['syncVersion'] as int? ?? 1,
        cachedBalance: j['cachedBalance'] as int? ?? 0,
      );

  TransactionEntry _transactionFromJson(Map<String, dynamic> j) =>
      TransactionEntry(
        id: j['id'] as String,
        type: TransactionType.values.byName(j['type'] as String),
        amount: j['amount'] as int,
        accountId: j['accountId'] as String,
        destinationAccountId: j['destinationAccountId'] as String?,
        categoryId: j['categoryId'] as String?,
        transferFee: j['transferFee'] as int? ?? 0,
        transferGroupId: j['transferGroupId'] as String?,
        notes: j['notes'] as String?,
        transactionDate: DateTime.parse(j['transactionDate'] as String),
        createdAt: DateTime.parse(j['createdAt'] as String),
        modifiedAt: DateTime.parse(j['modifiedAt'] as String),
        syncVersion: j['syncVersion'] as int? ?? 1,
        isDeleted: j['isDeleted'] as bool? ?? false,
      );

  Loan _loanFromJson(Map<String, dynamic> j) => Loan(
        id: j['id'] as String,
        personName: j['personName'] as String,
        type: LoanType.values.byName(j['type'] as String),
        originalAmount: j['originalAmount'] as int,
        remainingAmount: j['remainingAmount'] as int,
        status: LoanStatus.values.byName(j['status'] as String),
        linkedAccountId: j['linkedAccountId'] as String?,
        notes: j['notes'] as String?,
        loanDate: DateTime.parse(j['loanDate'] as String),
        createdAt: DateTime.parse(j['createdAt'] as String),
        modifiedAt: DateTime.parse(j['modifiedAt'] as String),
        syncVersion: j['syncVersion'] as int? ?? 1,
      );

  domain.Category _categoryFromJson(Map<String, dynamic> j) => domain.Category(
        id: j['id'] as String,
        name: j['name'] as String,
        iconName: j['iconName'] as String?,
        colorValue: j['colorValue'] as int?,
        sortOrder: j['sortOrder'] as int? ?? 0,
        createdAt: DateTime.parse(j['createdAt'] as String),
        modifiedAt: DateTime.parse(j['modifiedAt'] as String),
      );
}

/// Result of a data import operation.
class ImportResult {
  final int accountsImported;
  final int transactionsImported;
  final int loansImported;
  final int categoriesImported;
  final int skipped;

  const ImportResult({
    required this.accountsImported,
    required this.transactionsImported,
    required this.loansImported,
    required this.categoriesImported,
    required this.skipped,
  });

  int get totalImported =>
      accountsImported +
      transactionsImported +
      loansImported +
      categoriesImported;

  @override
  String toString() =>
      'Imported: $accountsImported accounts, $transactionsImported transactions, '
      '$loansImported loans, $categoriesImported categories. Skipped: $skipped.';
}
