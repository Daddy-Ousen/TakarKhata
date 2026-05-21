/// Whether money is owed by or to the user.
enum LoanType {
  iOwe('Money I Owe', 0),
  owedToMe('Money Owed To Me', 1);

  const LoanType(this.label, this.value);

  /// Human-readable label for UI display.
  final String label;

  /// Integer value for database storage.
  final int value;

  /// Reconstruct enum from stored integer value.
  static LoanType fromValue(int value) {
    return LoanType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => throw ArgumentError('Invalid LoanType value: $value'),
    );
  }

  /// Whether this loan type represents a liability for the user.
  bool get isLiability => this == LoanType.iOwe;

  /// Whether this loan type represents a receivable for the user.
  bool get isReceivable => this == LoanType.owedToMe;
}
