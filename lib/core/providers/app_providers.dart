import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khatabook/database/app_database.dart';
import 'package:khatabook/features/accounts/domain/repositories/account_repository.dart';
import 'package:khatabook/features/accounts/infrastructure/repositories/account_repository_impl.dart';
import 'package:khatabook/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:khatabook/features/transactions/infrastructure/repositories/transaction_repository_impl.dart';
import 'package:khatabook/features/categories/domain/repositories/category_repository.dart';
import 'package:khatabook/features/categories/infrastructure/repositories/category_repository_impl.dart';
import 'package:khatabook/features/loans/domain/repositories/loan_repository.dart';
import 'package:khatabook/features/loans/infrastructure/repositories/loan_repository_impl.dart';
import 'package:khatabook/features/transactions/application/financial_engine.dart';
import 'package:khatabook/features/transactions/application/transaction_service.dart';
import 'package:khatabook/features/accounts/application/account_service.dart';
import 'package:khatabook/features/loans/application/loan_service.dart';
import 'package:khatabook/features/sync/application/data_export_service.dart';

// ─── Database ────────────────────────────────────────────────────────────────

/// Singleton database instance.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

// ─── Repositories ────────────────────────────────────────────────────────────

final accountRepositoryProvider = Provider<AccountRepository>((ref) {
  return AccountRepositoryImpl(ref.watch(databaseProvider));
});

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepositoryImpl(ref.watch(databaseProvider));
});

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepositoryImpl(ref.watch(databaseProvider));
});

final loanRepositoryProvider = Provider<LoanRepository>((ref) {
  return LoanRepositoryImpl(ref.watch(databaseProvider));
});

// ─── Financial Engine ────────────────────────────────────────────────────────

final financialEngineProvider = Provider<FinancialEngine>((ref) {
  return FinancialEngine(
    accountRepository: ref.watch(accountRepositoryProvider),
    transactionRepository: ref.watch(transactionRepositoryProvider),
    loanRepository: ref.watch(loanRepositoryProvider),
    categoryRepository: ref.watch(categoryRepositoryProvider),
  );
});

// ─── Services ────────────────────────────────────────────────────────────────

final ledgerUpdateProvider = StateProvider<int>((ref) => 0);

final transactionServiceProvider = Provider<TransactionService>((ref) {
  return TransactionService(
    transactionRepository: ref.watch(transactionRepositoryProvider),
    accountRepository: ref.watch(accountRepositoryProvider),
    financialEngine: ref.watch(financialEngineProvider),
    onLedgerUpdated: () {
      ref.read(ledgerUpdateProvider.notifier).state++;
    },
  );
});

final accountServiceProvider = Provider<AccountService>((ref) {
  return AccountService(
    accountRepository: ref.watch(accountRepositoryProvider),
    transactionService: ref.watch(transactionServiceProvider),
  );
});

final loanServiceProvider = Provider<LoanService>((ref) {
  return LoanService(
    loanRepository: ref.watch(loanRepositoryProvider),
    transactionService: ref.watch(transactionServiceProvider),
    accountRepository: ref.watch(accountRepositoryProvider),
  );
});

final dataExportServiceProvider = Provider<DataExportService>((ref) {
  return DataExportService(
    accountRepo: ref.watch(accountRepositoryProvider),
    transactionRepo: ref.watch(transactionRepositoryProvider),
    loanRepo: ref.watch(loanRepositoryProvider),
    categoryRepo: ref.watch(categoryRepositoryProvider),
  );
});

// ─── Navigation ──────────────────────────────────────────────────────────────

/// Current navigation index for the adaptive scaffold.
final navigationIndexProvider = StateProvider<int>((ref) => 0);
