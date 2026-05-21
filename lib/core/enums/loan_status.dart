/// Status of a personal loan in the KhataBook system.
enum LoanStatus {
  open('Open', 0),
  partiallyPaid('Partially Paid', 1),
  settled('Settled', 2);

  const LoanStatus(this.label, this.value);

  /// Human-readable label for UI display.
  final String label;

  /// Integer value for database storage.
  final int value;

  /// Reconstruct enum from stored integer value.
  static LoanStatus fromValue(int value) {
    return LoanStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => throw ArgumentError('Invalid LoanStatus value: $value'),
    );
  }

  /// Whether the loan is still active (has outstanding balance).
  bool get isActive =>
      this == LoanStatus.open || this == LoanStatus.partiallyPaid;
}
