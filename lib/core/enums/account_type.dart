/// Account types supported by the KhataBook application.
///
/// Each account type has different balance calculation semantics:
/// - [debit], [cash], [savings]: Standard balance (credits - debits)
/// - [credit]: Inverted balance (debits represent amount owed)
enum AccountType {
  debit('Debit', 0),
  credit('Credit', 1),
  cash('Cash', 2),
  savings('Savings', 3);

  const AccountType(this.label, this.value);

  /// Human-readable label for UI display.
  final String label;

  /// Integer value for database storage.
  final int value;

  /// Reconstruct enum from stored integer value.
  static AccountType fromValue(int value) {
    return AccountType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => throw ArgumentError('Invalid AccountType value: $value'),
    );
  }

  /// Whether this account type has inverted balance semantics.
  /// Credit accounts show spending as positive (amount owed).
  bool get isInverted => this == AccountType.credit;

  /// Whether this is a liability account.
  bool get isLiability => this == AccountType.credit;

  /// Whether this is an asset account.
  bool get isAsset => this != AccountType.credit;
}
