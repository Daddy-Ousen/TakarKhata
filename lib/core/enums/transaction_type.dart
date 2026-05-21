/// Types of financial transactions in the KhataBook ledger.
///
/// Every financial movement is classified as one of these types:
/// - [income]: Money coming into an account
/// - [expense]: Money leaving an account
/// - [transfer]: Money moving between two accounts
/// - [openingBalance]: System-generated entry for initial account balance
enum TransactionType {
  income('Income', 0),
  expense('Expense', 1),
  transfer('Transfer', 2),
  openingBalance('Opening Balance', 3);

  const TransactionType(this.label, this.value);

  /// Human-readable label for UI display.
  final String label;

  /// Integer value for database storage.
  final int value;

  /// Reconstruct enum from stored integer value.
  static TransactionType fromValue(int value) {
    return TransactionType.values.firstWhere(
      (e) => e.value == value,
      orElse: () =>
          throw ArgumentError('Invalid TransactionType value: $value'),
    );
  }

  /// Whether this type adds money to the primary account.
  bool get isCredit =>
      this == TransactionType.income ||
      this == TransactionType.openingBalance;

  /// Whether this type removes money from the primary account.
  bool get isDebit =>
      this == TransactionType.expense || this == TransactionType.transfer;

  /// Whether this is a system-generated transaction type.
  bool get isSystemGenerated => this == TransactionType.openingBalance;

  /// Whether this transaction involves two accounts.
  bool get isDualAccount => this == TransactionType.transfer;
}
