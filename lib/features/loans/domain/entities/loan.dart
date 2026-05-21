import 'package:khatabook/core/enums/loan_type.dart';
import 'package:khatabook/core/enums/loan_status.dart';

/// Represents a loan tracked in the system.
///
/// Loans can be money the user owes to someone ([LoanType.iOwe]) or
/// money someone owes to the user ([LoanType.owedToMe]).
///
/// All monetary values ([originalAmount], [remainingAmount]) are stored
/// as [int] representing cents to avoid floating-point precision issues.
class Loan {
  /// Unique identifier for this loan (UUID).
  final String id;

  /// The name of the person involved in this loan.
  final String personName;

  /// The direction of the loan from the user's perspective.
  final LoanType type;

  /// The original principal amount in cents when the loan was created.
  final int originalAmount;

  /// The remaining unpaid amount in cents.
  /// Decreases as [LoanPayment] entries are recorded.
  final int remainingAmount;

  /// Current lifecycle status of this loan.
  final LoanStatus status;

  /// Optional ID of the account linked to this loan for tracking purposes.
  final String? linkedAccountId;

  /// Optional user-provided notes or description for this loan.
  final String? notes;

  /// The date when this loan was originally issued or received.
  final DateTime loanDate;

  /// Timestamp when this loan was first created in the system.
  final DateTime createdAt;

  /// Timestamp when this loan was last modified.
  final DateTime modifiedAt;

  /// Monotonically increasing version number for sync conflict detection.
  final int syncVersion;

  /// Creates a new [Loan] instance.
  ///
  /// [id], [personName], [type], [originalAmount], [remainingAmount],
  /// [status], [loanDate], [createdAt], and [modifiedAt] are required.
  /// Defaults: [syncVersion] = 1.
  const Loan({
    required this.id,
    required this.personName,
    required this.type,
    required this.originalAmount,
    required this.remainingAmount,
    required this.status,
    this.linkedAccountId,
    this.notes,
    required this.loanDate,
    required this.createdAt,
    required this.modifiedAt,
    this.syncVersion = 1,
  });

  /// Creates a copy of this loan with the given fields replaced.
  Loan copyWith({
    String? id,
    String? personName,
    LoanType? type,
    int? originalAmount,
    int? remainingAmount,
    LoanStatus? status,
    String? linkedAccountId,
    String? notes,
    DateTime? loanDate,
    DateTime? createdAt,
    DateTime? modifiedAt,
    int? syncVersion,
  }) {
    return Loan(
      id: id ?? this.id,
      personName: personName ?? this.personName,
      type: type ?? this.type,
      originalAmount: originalAmount ?? this.originalAmount,
      remainingAmount: remainingAmount ?? this.remainingAmount,
      status: status ?? this.status,
      linkedAccountId: linkedAccountId ?? this.linkedAccountId,
      notes: notes ?? this.notes,
      loanDate: loanDate ?? this.loanDate,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      syncVersion: syncVersion ?? this.syncVersion,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Loan && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Loan(id: $id, personName: $personName, type: $type, '
      'remaining: $remainingAmount, status: $status)';
}
