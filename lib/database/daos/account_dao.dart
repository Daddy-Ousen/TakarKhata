import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/accounts_table.dart';

part 'account_dao.g.dart';

/// Data Access Object for account-related database operations.
///
/// Provides CRUD operations, archiving, filtering, and balance
/// calculation for financial accounts. Balance is computed from
/// the transactions ledger rather than stored on the account row.
@DriftAccessor(tables: [Accounts])
class AccountDao extends DatabaseAccessor<AppDatabase>
    with _$AccountDaoMixin {
  /// Creates an [AccountDao] attached to the given [db].
  AccountDao(AppDatabase db) : super(db);

  /// Returns all non-archived accounts ordered by [sortOrder].
  ///
  /// Use [getAllAccountsIncludingArchived] when you need to display
  /// archived accounts as well (e.g., in a settings/manage screen).
  Future<List<Account>> getAllAccounts() {
    return (select(accounts)
          ..where((a) => a.isArchived.equals(false))
          ..orderBy([(a) => OrderingTerm.asc(a.sortOrder)]))
        .get();
  }

  /// Returns all accounts including archived ones, ordered by [sortOrder].
  Future<List<Account>> getAllAccountsIncludingArchived() {
    return (select(accounts)
          ..orderBy([(a) => OrderingTerm.asc(a.sortOrder)]))
        .get();
  }

  /// Returns the account with the given [id], or `null` if not found.
  Future<Account?> getAccountById(String id) {
    return (select(accounts)..where((a) => a.id.equals(id)))
        .getSingleOrNull();
  }

  /// Inserts a new account into the database.
  ///
  /// The [account] companion must include at minimum: [id], [name],
  /// [type], [createdAt], and [modifiedAt].
  Future<void> insertAccount(AccountsCompanion account) {
    return into(accounts).insert(account);
  }

  /// Updates an existing account.
  ///
  /// The [account] companion must include [id] to identify the row.
  /// Only the fields present in the companion will be updated.
  Future<void> updateAccount(AccountsCompanion account) {
    return (update(accounts)
          ..where((a) => a.id.equals(account.id.value)))
        .write(account);
  }

  /// Archives the account with the given [id].
  ///
  /// Archived accounts are hidden from the main list but their
  /// transactions and balance history remain accessible.
  Future<void> archiveAccount(String id) {
    return (update(accounts)..where((a) => a.id.equals(id))).write(
      AccountsCompanion(
        isArchived: const Value(true),
        modifiedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Un-archives the account with the given [id].
  ///
  /// Restores the account to the active list.
  Future<void> unarchiveAccount(String id) {
    return (update(accounts)..where((a) => a.id.equals(id))).write(
      AccountsCompanion(
        isArchived: const Value(false),
        modifiedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Emits a new list whenever the non-archived accounts change.
  ///
  /// Useful for building reactive UIs that auto-update when accounts
  /// are added, edited, archived, or re-ordered.
  Stream<List<Account>> watchAllAccounts() {
    return (select(accounts)
          ..where((a) => a.isArchived.equals(false))
          ..orderBy([(a) => OrderingTerm.asc(a.sortOrder)]))
        .watch();
  }

  /// Emits a new list whenever any account changes (including archived).
  Stream<List<Account>> watchAllAccountsIncludingArchived() {
    return (select(accounts)
          ..orderBy([(a) => OrderingTerm.asc(a.sortOrder)]))
        .watch();
  }

  /// Calculates the current balance for the account with [accountId].
  ///
  /// Balance is computed from the transactions ledger:
  ///
  /// **Credits** (money flowing in):
  /// - Income transactions (type=0) on this account
  /// - Opening balance transactions (type=3) on this account
  /// - Incoming transfers (type=2) where this account is the destination
  ///
  /// **Debits** (money flowing out):
  /// - Expense transactions (type=1) on this account
  /// - Outgoing transfers (type=2) from this account
  /// - Transfer fees on outgoing transfers from this account
  ///
  /// Returns the net balance in cents (credits − debits).
  Future<int> calculateBalance(String accountId) async {
    // Sum credits: income (0) and opening balance (3) on this account,
    // plus incoming transfers (2) where this account is the destination.
    final creditQuery = customSelect(
      'SELECT COALESCE(SUM(amount), 0) AS total FROM transactions '
      'WHERE is_deleted = 0 AND ('
      '  (account_id = ? AND type IN (0, 3)) OR '
      '  (destination_account_id = ? AND type = 2)'
      ')',
      variables: [
        Variable.withString(accountId),
        Variable.withString(accountId),
      ],
      readsFrom: {db.transactions},
    );

    // Sum debits: expenses (1) and outgoing transfers (2) from this account,
    // including transfer fees.
    final debitQuery = customSelect(
      'SELECT COALESCE(SUM(amount), 0) AS expense_total, '
      'COALESCE(SUM(transfer_fee), 0) AS fee_total '
      'FROM transactions '
      'WHERE is_deleted = 0 AND account_id = ? AND type IN (1, 2)',
      variables: [Variable.withString(accountId)],
      readsFrom: {db.transactions},
    );

    final credits = await creditQuery.getSingle();
    final debits = await debitQuery.getSingle();

    final totalCredits = credits.read<int>('total');
    final totalExpenses = debits.read<int>('expense_total');
    final totalFees = debits.read<int>('fee_total');

    return totalCredits - totalExpenses - totalFees;
  }

  /// Returns the total number of non-archived accounts.
  Future<int> getAccountCount() async {
    final result = customSelect(
      'SELECT COUNT(*) AS cnt FROM accounts WHERE is_archived = 0',
      readsFrom: {accounts},
    );

    final row = await result.getSingle();
    return row.read<int>('cnt');
  }
}
