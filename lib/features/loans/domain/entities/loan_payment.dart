/// Represents a single payment made towards a [Loan].
///
/// Each payment reduces the remaining balance of its parent loan.
/// The [amount] is stored as [int] representing cents to avoid
/// floating-point precision issues.
class LoanPayment {
  /// Unique identifier for this payment (UUID).
  final String id;

  /// The ID of the loan this payment is applied to.
  final String loanId;

  /// Payment amount in cents.
  final int amount;

  /// Optional ID of a linked transaction entry that recorded
  /// the actual money movement for this payment.
  final String? linkedTransactionId;

  /// Optional user-provided notes about this payment.
  final String? notes;

  /// The date when this payment was made.
  final DateTime paymentDate;

  /// Timestamp when this payment was first created in the system.
  final DateTime createdAt;

  /// Timestamp when this payment was last modified.
  final DateTime modifiedAt;

  /// Monotonically increasing version number for sync conflict detection.
  final int syncVersion;

  /// Creates a new [LoanPayment] instance.
  ///
  /// [id], [loanId], [amount], [paymentDate], [createdAt], and
  /// [modifiedAt] are required. Defaults: [syncVersion] = 1.
  const LoanPayment({
    required this.id,
    required this.loanId,
    required this.amount,
    this.linkedTransactionId,
    this.notes,
    required this.paymentDate,
    required this.createdAt,
    required this.modifiedAt,
    this.syncVersion = 1,
  });

  /// Creates a copy of this payment with the given fields replaced.
  LoanPayment copyWith({
    String? id,
    String? loanId,
    int? amount,
    String? linkedTransactionId,
    String? notes,
    DateTime? paymentDate,
    DateTime? createdAt,
    DateTime? modifiedAt,
    int? syncVersion,
  }) {
    return LoanPayment(
      id: id ?? this.id,
      loanId: loanId ?? this.loanId,
      amount: amount ?? this.amount,
      linkedTransactionId: linkedTransactionId ?? this.linkedTransactionId,
      notes: notes ?? this.notes,
      paymentDate: paymentDate ?? this.paymentDate,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      syncVersion: syncVersion ?? this.syncVersion,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoanPayment &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'LoanPayment(id: $id, loanId: $loanId, amount: $amount, '
      'date: $paymentDate)';
}
