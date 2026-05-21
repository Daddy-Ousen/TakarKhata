import 'package:khatabook/core/enums/account_type.dart';
import 'package:khatabook/features/accounts/domain/entities/account.dart'
    as domain;
import 'package:khatabook/features/accounts/domain/repositories/account_repository.dart';
import 'package:khatabook/database/app_database.dart';
import 'package:drift/drift.dart';

/// Drift-backed implementation of [AccountRepository].
///
/// Converts between domain entities and Drift data classes,
/// delegates persistence to [AccountDao].
class AccountRepositoryImpl implements AccountRepository {
  final AppDatabase _db;

  AccountRepositoryImpl(this._db);

  // ── Helpers ──────────────────────────────────────────────────────────────

  domain.Account _toDomain(Account row) {
    return domain.Account(
      id: row.id,
      name: row.name,
      type: AccountType.fromValue(row.type),
      iconName: row.iconName,
      colorValue: row.colorValue,
      isArchived: row.isArchived,
      sortOrder: row.sortOrder,
      createdAt: row.createdAt,
      modifiedAt: row.modifiedAt,
      syncVersion: row.syncVersion,
    );
  }

  AccountsCompanion _toCompanion(domain.Account entity) {
    return AccountsCompanion(
      id: Value(entity.id),
      name: Value(entity.name),
      type: Value(entity.type.value),
      iconName: Value(entity.iconName),
      colorValue: Value(entity.colorValue),
      isArchived: Value(entity.isArchived),
      sortOrder: Value(entity.sortOrder),
      createdAt: Value(entity.createdAt),
      modifiedAt: Value(entity.modifiedAt),
      syncVersion: Value(entity.syncVersion),
    );
  }

  // ── Queries ─────────────────────────────────────────────────────────────

  @override
  Future<List<domain.Account>> getAllAccounts() async {
    final rows = await _db.accountDao.getAllAccounts();
    return rows.map(_toDomain).toList();
  }

  @override
  Future<List<domain.Account>> getAllAccountsIncludingArchived() async {
    final rows = await _db.accountDao.getAllAccountsIncludingArchived();
    return rows.map(_toDomain).toList();
  }

  @override
  Future<domain.Account?> getAccountById(String id) async {
    final row = await _db.accountDao.getAccountById(id);
    return row != null ? _toDomain(row) : null;
  }

  @override
  Future<domain.Account> createAccount(domain.Account account) async {
    await _db.accountDao.insertAccount(_toCompanion(account));
    return account;
  }

  @override
  Future<void> updateAccount(domain.Account account) async {
    await _db.accountDao.updateAccount(_toCompanion(account));
  }

  @override
  Future<void> archiveAccount(String id) async {
    await _db.accountDao.archiveAccount(id);
  }

  @override
  Future<int> getCalculatedBalance(String accountId) async {
    return _db.accountDao.calculateBalance(accountId);
  }

  @override
  Future<int> recalculateBalance(String accountId) async {
    final balance = await _db.accountDao.calculateBalance(accountId);
    // We don't store cached balance in the accounts table directly,
    // but the domain entity carries it for display purposes.
    return balance;
  }

  @override
  Stream<List<domain.Account>> watchAllAccounts() {
    return _db.accountDao.watchAllAccounts().map(
          (rows) => rows.map(_toDomain).toList(),
        );
  }
}
