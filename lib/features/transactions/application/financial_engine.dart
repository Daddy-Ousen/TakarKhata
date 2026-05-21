import 'package:khatabook/features/accounts/domain/repositories/account_repository.dart';
import 'package:khatabook/features/categories/domain/repositories/category_repository.dart';
import 'package:khatabook/features/transactions/domain/entities/transaction_entry.dart';
import 'package:khatabook/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:khatabook/features/loans/domain/repositories/loan_repository.dart';

/// Data class representing dashboard analytics for a given period.
class DashboardData {
  final int totalIncome;
  final int totalExpenses;
  final int netSavings;
  final int savingsAccountBalance;
  final int currentBalance; // Sum of Debit + Cash accounts
  final int totalLiabilities;
  final int totalReceivables;
  final int creditCardDebt;
  final Map<String, int> expensesByCategory;
  final Map<String, String> categoryNames;

  const DashboardData({
    required this.totalIncome,
    required this.totalExpenses,
    required this.netSavings,
    required this.savingsAccountBalance,
    required this.currentBalance,
    required this.totalLiabilities,
    required this.totalReceivables,
    required this.creditCardDebt,
    required this.expensesByCategory,
    required this.categoryNames,
  });
}

/// Monthly trend data point.
class MonthlyTrend {
  final int month;
  final int year;
  final int income;
  final int expenses;
  final int netSavings;

  const MonthlyTrend({
    required this.month,
    required this.year,
    required this.income,
    required this.expenses,
    required this.netSavings,
  });
}

/// Represents a discrepancy found during ledger integrity validation.
class IntegrityIssue {
  final String accountId;
  final String accountName;
  final int cachedBalance;
  final int calculatedBalance;
  final String message;

  const IntegrityIssue({
    required this.accountId,
    required this.accountName,
    required this.cachedBalance,
    required this.calculatedBalance,
    required this.message,
  });
}

/// The core financial calculation engine.
///
/// This class is the central authority for all balance calculations,
/// dashboard aggregations, and ledger integrity operations.
///
/// **Key principles:**
/// 1. All balances are derived from ledger entries (never cached alone)
/// 2. Opening balances participate as regular ledger entries in all calculations
/// 3. Transfers are always atomic (both sides succeed or both fail)
/// 4. Credit accounts have inverted balance semantics
class FinancialEngine {
  final AccountRepository _accountRepository;
  final TransactionRepository _transactionRepository;
  final LoanRepository _loanRepository;
  final CategoryRepository _categoryRepository;

  FinancialEngine({
    required AccountRepository accountRepository,
    required TransactionRepository transactionRepository,
    required LoanRepository loanRepository,
    required CategoryRepository categoryRepository,
  })  : _accountRepository = accountRepository,
        _transactionRepository = transactionRepository,
        _loanRepository = loanRepository,
        _categoryRepository = categoryRepository;

  /// Calculate the current balance for an account from ALL ledger entries.
  ///
  /// This is the **source-of-truth** calculation. It queries every
  /// non-deleted transaction touching this account and computes:
  ///
  /// For debit/cash/savings accounts:
  ///   `SUM(income + opening_balance + incoming_transfers) - SUM(expenses + outgoing_transfers + fees)`
  ///
  /// For credit accounts:
  ///   `SUM(expenses + outgoing_transfers) - SUM(payments_received)`
  ///   (represents amount owed)
  Future<int> calculateAccountBalance(String accountId) async {
    return _accountRepository.getCalculatedBalance(accountId);
  }

  /// Recalculates balances for all affected accounts.
  ///
  /// This MUST be called within a database transaction after any
  /// transaction mutation (create, update, delete).
  Future<void> recalculateAfterMutation(List<String> affectedAccountIds) async {
    for (final accountId in affectedAccountIds) {
      await _accountRepository.recalculateBalance(accountId);
    }
  }

  /// Validates the entire ledger integrity.
  ///
  /// Compares cached balances against freshly-calculated balances
  /// for every account. Returns a list of discrepancies.
  ///
  /// This should be called:
  /// - On app startup
  /// - After sync import
  /// - Periodically as a safety check
  Future<List<IntegrityIssue>> validateLedgerIntegrity() async {
    final accounts = await _accountRepository.getAllAccountsIncludingArchived();
    final issues = <IntegrityIssue>[];

    for (final account in accounts) {
      final calculated = await calculateAccountBalance(account.id);
      if (calculated != account.cachedBalance) {
        issues.add(IntegrityIssue(
          accountId: account.id,
          accountName: account.name,
          cachedBalance: account.cachedBalance,
          calculatedBalance: calculated,
          message:
              'Balance mismatch: cached=${account.cachedBalance}, calculated=$calculated',
        ));
      }
    }

    return issues;
  }

  /// Repairs any integrity issues by recalculating all account balances.
  Future<int> repairIntegrity() async {
    final accounts = await _accountRepository.getAllAccountsIncludingArchived();
    int repaired = 0;

    for (final account in accounts) {
      final calculated = await _accountRepository.recalculateBalance(account.id);
      if (calculated != account.cachedBalance) {
        repaired++;
      }
    }

    return repaired;
  }

  /// Calculate comprehensive dashboard data for a given period.
  Future<DashboardData> calculateDashboard(
    DateTime from,
    DateTime to,
  ) async {
    final totalIncome =
        await _transactionRepository.getIncomeTotal(from, to);
    final totalExpenses =
        await _transactionRepository.getExpenseTotal(from, to);
    final expensesByCategory =
        await _transactionRepository.getExpensesByCategory(from, to);

    // Get all accounts for balance info
    final accounts = await _accountRepository.getAllAccounts();

    int savingsBalance = 0;
    int currentBalance = 0;
    int creditDebt = 0;

    for (final account in accounts) {
      final balance = await calculateAccountBalance(account.id);
      
      if (account.type.name == 'savings') {
        savingsBalance += balance;
      }
      
      if (account.type.name == 'debit' || account.type.name == 'cash') {
        currentBalance += balance;
      }

      if (account.type.isInverted) {
        // Balance for credit accounts is returned as (payments - expenses).
        // Since expenses > payments usually, balance is negative.
        // Debt should be a positive number.
        if (balance < 0) {
          creditDebt += -balance;
        } else {
          // If balance is positive, it means they overpaid the credit card,
          // so they have no debt.
        }
      }
    }

    final totalLiabilities = await _loanRepository.getTotalOwed();
    final totalReceivables = await _loanRepository.getTotalReceivable();

    final categoryNames = <String, String>{};
    for (final categoryId in expensesByCategory.keys) {
      if (categoryId.isEmpty) continue;
      final category = await _categoryRepository.getCategoryById(categoryId);
      if (category != null) {
        categoryNames[categoryId] = category.name;
      } else {
        categoryNames[categoryId] = 'Unknown ($categoryId)';
      }
    }

    return DashboardData(
      totalIncome: totalIncome,
      totalExpenses: totalExpenses,
      // Net Savings is now explicitly the sum of savings accounts
      netSavings: savingsBalance,
      savingsAccountBalance: savingsBalance,
      currentBalance: currentBalance,
      totalLiabilities: totalLiabilities,
      totalReceivables: totalReceivables,
      creditCardDebt: creditDebt,
      expensesByCategory: expensesByCategory,
      categoryNames: categoryNames,
    );
  }

  /// Calculate monthly trends for a given year.
  Future<List<MonthlyTrend>> monthlyTrends(int year) async {
    final trends = <MonthlyTrend>[];

    for (int month = 1; month <= 12; month++) {
      final from = DateTime(year, month, 1);
      final to = DateTime(year, month + 1, 0, 23, 59, 59, 999);

      // Don't calculate for future months
      if (from.isAfter(DateTime.now())) break;

      final income = await _transactionRepository.getIncomeTotal(from, to);
      final expenses = await _transactionRepository.getExpenseTotal(from, to);

      trends.add(MonthlyTrend(
        month: month,
        year: year,
        income: income,
        expenses: expenses,
        netSavings: income - expenses, // Cashflow
      ));
    }

    return trends;
  }

  /// Get the total net worth (all asset accounts + overpaid credit - credit debt).
  Future<int> calculateNetWorth() async {
    final accounts = await _accountRepository.getAllAccounts();
    int netWorth = 0;

    for (final account in accounts) {
      final balance = await calculateAccountBalance(account.id);
      if (account.type.isAsset) {
        netWorth += balance;
      } else {
        // Credit account: balance is (payments - expenses).
        // It is normally negative (owed money).
        // Net worth should ADD the negative balance, which effectively subtracts the debt!
        // E.g. balance is -100 (owe 100). netWorth += -100.
        // If they overpaid (balance is +50), netWorth += 50.
        netWorth += balance;
      }
    }

    return netWorth;
  }

  /// Get affected account IDs for a transaction.
  ///
  /// Used to determine which accounts need balance recalculation
  /// after a transaction is created, modified, or deleted.
  List<String> getAffectedAccountIds(TransactionEntry transaction) {
    final ids = <String>[transaction.accountId];
    if (transaction.destinationAccountId != null) {
      ids.add(transaction.destinationAccountId!);
    }
    return ids;
  }
}
