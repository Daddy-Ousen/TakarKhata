import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/loans_table.dart';
import '../tables/loan_payments_table.dart';

part 'loan_dao.g.dart';

/// Data Access Object for loan and loan-payment database operations.
///
/// Provides CRUD for loans and payments, status-based filtering,
/// aggregate totals for owed/receivable amounts, and reactive streams.
///
/// Loan types (from [LoanType]):
/// - 0 = iOwe (user borrowed money)
/// - 1 = owedToMe (someone owes the user)
///
/// Loan statuses (from [LoanStatus]):
/// - 0 = open
/// - 1 = partiallyPaid
/// - 2 = settled
@DriftAccessor(tables: [Loans, LoanPayments])
class LoanDao extends DatabaseAccessor<AppDatabase> with _$LoanDaoMixin {
  /// Creates a [LoanDao] attached to the given [db].
  LoanDao(AppDatabase db) : super(db);

  // ---------------------------------------------------------------------------
  // Loan CRUD
  // ---------------------------------------------------------------------------

  /// Returns all loans ordered by [loanDate] descending (most recent first).
  Future<List<Loan>> getAllLoans() {
    return (select(loans)
          ..orderBy([(l) => OrderingTerm.desc(l.loanDate)]))
        .get();
  }

  /// Returns the loan with the given [id], or `null` if not found.
  Future<Loan?> getLoanById(String id) {
    return (select(loans)..where((l) => l.id.equals(id)))
        .getSingleOrNull();
  }

  /// Returns all loans with the given [status].
  ///
  /// [status] corresponds to [LoanStatus] enum values:
  /// 0=open, 1=partiallyPaid, 2=settled.
  Future<List<Loan>> getLoansByStatus(int status) {
    return (select(loans)
          ..where((l) => l.status.equals(status))
          ..orderBy([(l) => OrderingTerm.desc(l.loanDate)]))
        .get();
  }

  /// Returns all loans of the given [type].
  ///
  /// [type] corresponds to [LoanType] enum values:
  /// 0=iOwe, 1=owedToMe.
  Future<List<Loan>> getLoansByType(int type) {
    return (select(loans)
          ..where((l) => l.type.equals(type))
          ..orderBy([(l) => OrderingTerm.desc(l.loanDate)]))
        .get();
  }

  /// Inserts a new loan into the database.
  ///
  /// The [loan] companion must include at minimum: [id], [personName],
  /// [type], [originalAmount], [remainingAmount], [loanDate],
  /// [createdAt], and [modifiedAt].
  Future<void> insertLoan(LoansCompanion loan) {
    return into(loans).insert(loan);
  }

  /// Updates an existing loan.
  ///
  /// The [loan] companion must include [id] to identify the row.
  Future<void> updateLoan(LoansCompanion loan) {
    return (update(loans)..where((l) => l.id.equals(loan.id.value)))
        .write(loan);
  }

  /// Deletes the loan with the given [id] and all its payments.
  ///
  /// This is a hard delete. Use with caution — typically only for
  /// data entered in error.
  Future<void> deleteLoan(String id) {
    return transaction(() async {
      // Delete all payments for this loan first.
      await (delete(loanPayments)
            ..where((p) => p.loanId.equals(id)))
          .go();
      // Delete the loan itself.
      await (delete(loans)..where((l) => l.id.equals(id))).go();
    });
  }

  // ---------------------------------------------------------------------------
  // Loan Payments
  // ---------------------------------------------------------------------------

  /// Inserts a new payment for a loan.
  ///
  /// The [payment] companion must include at minimum: [id], [loanId],
  /// [amount], [paymentDate], [createdAt], and [modifiedAt].
  ///
  /// After inserting, the caller should also update the parent loan's
  /// [remainingAmount] and [status] accordingly.
  Future<void> insertPayment(LoanPaymentsCompanion payment) {
    return into(loanPayments).insert(payment);
  }

  /// Updates an existing loan payment.
  Future<void> updatePayment(LoanPaymentsCompanion payment) {
    return (update(loanPayments)
          ..where((p) => p.id.equals(payment.id.value)))
        .write(payment);
  }

  /// Deletes the payment with the given [id].
  ///
  /// After deleting, the caller should recalculate the parent loan's
  /// [remainingAmount] and [status].
  Future<void> deletePayment(String id) {
    return (delete(loanPayments)..where((p) => p.id.equals(id))).go();
  }

  /// Returns all payments for the loan with [loanId], ordered by
  /// [paymentDate] ascending (earliest first).
  Future<List<LoanPayment>> getPaymentsForLoan(String loanId) {
    return (select(loanPayments)
          ..where((p) => p.loanId.equals(loanId))
          ..orderBy([(p) => OrderingTerm.asc(p.paymentDate)]))
        .get();
  }

  /// Returns the total of all payments made for the loan with [loanId].
  Future<int> getTotalPaidForLoan(String loanId) async {
    final result = await customSelect(
      'SELECT COALESCE(SUM(amount), 0) AS total '
      'FROM loan_payments WHERE loan_id = ?',
      variables: [Variable.withString(loanId)],
      readsFrom: {loanPayments},
    ).getSingle();

    return result.read<int>('total');
  }

  // ---------------------------------------------------------------------------
  // Aggregates
  // ---------------------------------------------------------------------------

  /// Returns the total remaining amount (in cents) for all loans
  /// where the user owes money (type=0, iOwe).
  ///
  /// Only non-settled loans (status != 2) are included.
  Future<int> getTotalOwed() async {
    final result = await customSelect(
      'SELECT COALESCE(SUM(remaining_amount), 0) AS total '
      'FROM loans WHERE type = 0 AND status != 2',
      readsFrom: {loans},
    ).getSingle();

    return result.read<int>('total');
  }

  /// Returns the total remaining amount (in cents) for all loans
  /// where someone owes the user money (type=1, owedToMe).
  ///
  /// Only non-settled loans (status != 2) are included.
  Future<int> getTotalReceivable() async {
    final result = await customSelect(
      'SELECT COALESCE(SUM(remaining_amount), 0) AS total '
      'FROM loans WHERE type = 1 AND status != 2',
      readsFrom: {loans},
    ).getSingle();

    return result.read<int>('total');
  }

  // ---------------------------------------------------------------------------
  // Streams
  // ---------------------------------------------------------------------------

  /// Emits all loans whenever the loans table changes.
  ///
  /// Results ordered by [loanDate] descending.
  Stream<List<Loan>> watchAllLoans() {
    return (select(loans)
          ..orderBy([(l) => OrderingTerm.desc(l.loanDate)]))
        .watch();
  }

  /// Emits all non-settled loans whenever the loans table changes.
  Stream<List<Loan>> watchActiveLoans() {
    return (select(loans)
          ..where((l) => l.status.isNotValue(2))
          ..orderBy([(l) => OrderingTerm.desc(l.loanDate)]))
        .watch();
  }

  /// Emits payments for the given [loanId] whenever they change.
  Stream<List<LoanPayment>> watchPaymentsForLoan(String loanId) {
    return (select(loanPayments)
          ..where((p) => p.loanId.equals(loanId))
          ..orderBy([(p) => OrderingTerm.asc(p.paymentDate)]))
        .watch();
  }
}
