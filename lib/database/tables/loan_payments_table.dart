import 'package:drift/drift.dart';

/// Drift table definition for loan payment records.
///
/// Each row represents a single payment made toward a loan.
/// When a payment is recorded, the parent loan's [remainingAmount]
/// should be reduced by this payment's [amount].
///
/// Payments can optionally be linked to a regular transaction via
/// [linkedTransactionId] so the payment is reflected in account
/// balance calculations as well.
///
/// All monetary values ([amount]) are stored as integers
/// representing cents.
class LoanPayments extends Table {
  /// Unique identifier for the payment (UUID string).
  TextColumn get id => text()();

  /// The loan this payment is applied to.
  TextColumn get loanId => text()();

  /// Payment amount in cents (always positive).
  IntColumn get amount => integer()();

  /// Optional link to a transaction that represents this payment
  /// in the main ledger.
  ///
  /// When set, the payment is also reflected as an expense/income
  /// transaction in the linked account.
  TextColumn get linkedTransactionId => text().nullable()();

  /// Optional user-provided notes about the payment.
  TextColumn get notes => text().nullable()();

  /// The date the payment was made.
  DateTimeColumn get paymentDate => dateTime()();

  /// Timestamp when this payment record was first created.
  DateTimeColumn get createdAt => dateTime()();

  /// Timestamp when this payment record was last modified.
  DateTimeColumn get modifiedAt => dateTime()();

  /// Monotonically increasing version number for sync conflict resolution.
  IntColumn get syncVersion =>
      integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {id};
}
