import 'package:drift/drift.dart';

/// Drift table definition for personal loans.
///
/// Tracks informal loans between the user and other people.
/// The [type] column maps to [LoanType] enum values:
/// - 0 = iOwe (user borrowed money from someone)
/// - 1 = owedToMe (someone borrowed money from the user)
///
/// The [status] column maps to [LoanStatus] enum values:
/// - 0 = open (full balance outstanding)
/// - 1 = partiallyPaid (some payments made)
/// - 2 = settled (fully repaid)
///
/// All monetary values ([originalAmount], [remainingAmount]) are stored
/// as integers representing cents.
class Loans extends Table {
  /// Unique identifier for the loan (UUID string).
  TextColumn get id => text()();

  /// Name of the person involved in the loan.
  TextColumn get personName => text().withLength(min: 1, max: 100)();

  /// Loan type stored as the integer value of [LoanType] enum.
  IntColumn get type => integer()();

  /// The original principal amount of the loan, in cents.
  IntColumn get originalAmount => integer()();

  /// The current outstanding balance of the loan, in cents.
  ///
  /// Decreases as payments are recorded against this loan.
  /// When this reaches 0, the loan [status] should be set to settled.
  IntColumn get remainingAmount => integer()();

  /// Loan status stored as the integer value of [LoanStatus] enum.
  ///
  /// Defaults to 0 (open) when a new loan is created.
  IntColumn get status => integer().withDefault(const Constant(0))();

  /// Optional account linked to this loan for automatic balance tracking.
  TextColumn get linkedAccountId => text().nullable()();

  /// Optional user-provided notes about the loan.
  TextColumn get notes => text().nullable()();

  /// The date the loan was created or agreed upon.
  DateTimeColumn get loanDate => dateTime()();

  /// Timestamp when this loan record was first created.
  DateTimeColumn get createdAt => dateTime()();

  /// Timestamp when this loan record was last modified.
  DateTimeColumn get modifiedAt => dateTime()();

  /// Monotonically increasing version number for sync conflict resolution.
  IntColumn get syncVersion =>
      integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {id};
}
