import 'package:khatabook/features/accounts/domain/entities/account.dart';

/// Repository contract for account operations.
///
/// Defines the interface that data layer implementations must fulfill
/// to provide account persistence. This abstraction allows the domain
/// and presentation layers to remain independent of the data source.
abstract class AccountRepository {
  /// Get all non-archived accounts, ordered by [Account.sortOrder].
  ///
  /// Returns an empty list if no active accounts exist.
  Future<List<Account>> getAllAccounts();

  /// Get all accounts including archived ones.
  ///
  /// Useful for administrative views and data export.
  /// Returns an empty list if no accounts exist.
  Future<List<Account>> getAllAccountsIncludingArchived();

  /// Get a single account by its unique [id].
  ///
  /// Returns `null` if no account with the given [id] exists.
  Future<Account?> getAccountById(String id);

  /// Create a new account and persist it.
  ///
  /// Returns the created [Account] with any server-generated fields populated.
  /// Throws if an account with the same ID already exists.
  Future<Account> createAccount(Account account);

  /// Update an existing account with new field values.
  ///
  /// The [account]'s [Account.id] must match an existing record.
  /// Throws if the account does not exist.
  Future<void> updateAccount(Account account);

  /// Archive an account by its [id] (soft delete).
  ///
  /// Archived accounts are excluded from [getAllAccounts] but remain
  /// accessible via [getAllAccountsIncludingArchived].
  Future<void> archiveAccount(String id);

  /// Get the calculated balance for an account from ledger entries.
  ///
  /// This queries the transaction ledger to compute the true balance
  /// for the account identified by [accountId], in cents.
  Future<int> getCalculatedBalance(String accountId);

  /// Recalculate and update the cached balance for an account.
  ///
  /// Queries the transaction ledger, computes the true balance, updates
  /// the [Account.cachedBalance] field, and returns the new balance in cents.
  Future<int> recalculateBalance(String accountId);

  /// Watch all non-archived accounts as a stream for reactive UI updates.
  ///
  /// Emits a new list whenever the underlying data changes.
  /// The list is ordered by [Account.sortOrder].
  Stream<List<Account>> watchAllAccounts();
}
