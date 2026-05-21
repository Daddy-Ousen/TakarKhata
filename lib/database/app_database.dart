import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables/accounts_table.dart';
import 'tables/transactions_table.dart';
import 'tables/categories_table.dart';
import 'tables/loans_table.dart';
import 'tables/loan_payments_table.dart';
import 'daos/account_dao.dart';
import 'daos/transaction_dao.dart';
import 'daos/category_dao.dart';
import 'daos/loan_dao.dart';
import 'migrations/migration_strategy.dart';

part 'app_database.g.dart';

/// The main Drift database for the KhataBook application.
///
/// Registers all table definitions and DAOs, manages schema versioning,
/// and provides the database connection.
///
/// Usage:
/// ```dart
/// final db = AppDatabase();
/// final accounts = await db.accountDao.getAllAccounts();
/// ```
///
/// For testing, use the named constructor:
/// ```dart
/// final db = AppDatabase.forTesting(NativeDatabase.memory());
/// ```
@DriftDatabase(
  tables: [Accounts, Transactions, Categories, Loans, LoanPayments],
  daos: [AccountDao, TransactionDao, CategoryDao, LoanDao],
)
class AppDatabase extends _$AppDatabase {
  /// Creates the database with the default SQLite file connection.
  ///
  /// The database file is stored at:
  /// `<applicationDocumentsDirectory>/khatabook.db`
  AppDatabase() : super(_openConnection());

  /// Creates the database with a custom [QueryExecutor] for testing.
  ///
  /// Example with an in-memory database:
  /// ```dart
  /// final db = AppDatabase.forTesting(NativeDatabase.memory());
  /// ```
  AppDatabase.forTesting(super.e);

  /// Current schema version.
  ///
  /// Increment this when making schema changes and add a corresponding
  /// entry to [MigrationHelper.migrations].
  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        await MigrationHelper.runMigrations(m, from, to);
      },
    );
  }
}

/// Opens a lazy database connection to a SQLite file on disk.
///
/// The connection is created in a background isolate via
/// [NativeDatabase.createInBackground] to avoid blocking the UI thread
/// during heavy database operations.
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'khatabook.db'));
    return NativeDatabase.createInBackground(file);
  });
}
