import 'package:khatabook/core/enums/loan_status.dart';
import 'package:khatabook/features/loans/domain/entities/loan.dart';
import 'package:khatabook/features/loans/domain/entities/loan_payment.dart';

/// Repository contract for loan and loan payment operations.
///
/// Defines the interface that data layer implementations must fulfill
/// to provide loan persistence. Supports querying loans by status,
/// recording payments, and computing aggregate amounts.
abstract class LoanRepository {
  /// Get all loans regardless of status.
  ///
  /// Returns an empty list if no loans exist.
  Future<List<Loan>> getAllLoans();

  /// Get a single loan by its unique [id].
  ///
  /// Returns `null` if no loan with the given [id] exists.
  Future<Loan?> getLoanById(String id);

  /// Get all loans with a specific [status].
  ///
  /// For example, retrieve only [LoanStatus.active] loans.
  Future<List<Loan>> getLoansByStatus(LoanStatus status);

  /// Create a new loan and persist it.
  ///
  /// Returns the created [Loan] with any generated fields populated.
  /// Throws if a loan with the same ID already exists.
  Future<Loan> createLoan(Loan loan);

  /// Update an existing loan with new field values.
  ///
  /// The [loan]'s [Loan.id] must match an existing record.
  /// Throws if the loan does not exist.
  Future<void> updateLoan(Loan loan);

  /// Record a payment against a loan.
  ///
  /// Persists the [payment] and updates the parent loan's
  /// [Loan.remainingAmount] accordingly.
  Future<void> addPayment(LoanPayment payment);

  /// Get all payments recorded against a specific loan.
  ///
  /// Returns payments ordered by [LoanPayment.paymentDate] ascending.
  Future<List<LoanPayment>> getPaymentsForLoan(String loanId);

  /// Get the total amount the user owes across all active loans.
  ///
  /// Sums [Loan.remainingAmount] for all active loans where
  /// [Loan.type] is [LoanType.iOwe]. Returns the total in cents.
  Future<int> getTotalOwed();

  /// Get the total amount owed to the user across all active loans.
  ///
  /// Sums [Loan.remainingAmount] for all active loans where
  /// [Loan.type] is [LoanType.owedToMe]. Returns the total in cents.
  Future<int> getTotalReceivable();

  /// Watch all loans as a stream for reactive UI updates.
  ///
  /// Emits a new list whenever the underlying loan data changes.
  Stream<List<Loan>> watchAllLoans();
}
