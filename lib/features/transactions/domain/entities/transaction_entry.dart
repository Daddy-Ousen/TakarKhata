import 'package:khatabook/core/enums/transaction_type.dart';

/// Represents a single financial transaction entry.
///
/// All monetary values ([amount], [transferFee]) are stored as [int]
/// representing cents to avoid floating-point precision issues.
///
/// For [TransactionType.transfer] transactions, [destinationAccountId]
/// identifies the receiving account, and [transferGroupId] links the
/// corresponding debit and credit entries together.
class TransactionEntry {
  /// Unique identifier for this transaction (UUID).
  final String id;

  /// The type of this transaction (income, expense, or transfer).
  final TransactionType type;

  /// Transaction amount in cents. Always stored as a positive value;
  /// the [type] determines whether it is a debit or credit.
  final int amount;

  /// The primary account associated with this transaction.
  /// For income: the receiving account.
  /// For expense: the paying account.
  /// For transfer: the source account.
  final String accountId;

  /// The destination account for transfer transactions.
  /// Null for income and expense transactions.
  final String? destinationAccountId;

  /// The category assigned to this transaction.
  /// Typically null for transfer transactions.
  final String? categoryId;

  /// Any fee charged for a transfer, in cents.
  /// Only meaningful for [TransactionType.transfer] transactions.
  final int transferFee;

  /// Groups related transfer entries (debit and credit) together.
  /// Null for non-transfer transactions.
  final String? transferGroupId;

  /// Optional user-provided notes or memo for this transaction.
  final String? notes;

  /// The date when this transaction occurred.
  final DateTime transactionDate;

  /// Timestamp when this transaction was first created in the system.
  final DateTime createdAt;

  /// Timestamp when this transaction was last modified.
  final DateTime modifiedAt;

  /// Monotonically increasing version number for sync conflict detection.
  final int syncVersion;

  /// Whether this transaction has been soft-deleted.
  final bool isDeleted;

  /// Creates a new [TransactionEntry] instance.
  ///
  /// [id], [type], [amount], [accountId], [transactionDate], [createdAt],
  /// and [modifiedAt] are required. Defaults: [transferFee] = 0,
  /// [syncVersion] = 1, [isDeleted] = false.
  const TransactionEntry({
    required this.id,
    required this.type,
    required this.amount,
    required this.accountId,
    this.destinationAccountId,
    this.categoryId,
    this.transferFee = 0,
    this.transferGroupId,
    this.notes,
    required this.transactionDate,
    required this.createdAt,
    required this.modifiedAt,
    this.syncVersion = 1,
    this.isDeleted = false,
  });

  /// Creates a copy of this transaction with the given fields replaced.
  TransactionEntry copyWith({
    String? id,
    TransactionType? type,
    int? amount,
    String? accountId,
    String? destinationAccountId,
    String? categoryId,
    int? transferFee,
    String? transferGroupId,
    String? notes,
    DateTime? transactionDate,
    DateTime? createdAt,
    DateTime? modifiedAt,
    int? syncVersion,
    bool? isDeleted,
  }) {
    return TransactionEntry(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      accountId: accountId ?? this.accountId,
      destinationAccountId: destinationAccountId ?? this.destinationAccountId,
      categoryId: categoryId ?? this.categoryId,
      transferFee: transferFee ?? this.transferFee,
      transferGroupId: transferGroupId ?? this.transferGroupId,
      notes: notes ?? this.notes,
      transactionDate: transactionDate ?? this.transactionDate,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      syncVersion: syncVersion ?? this.syncVersion,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionEntry &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'TransactionEntry(id: $id, type: $type, amount: $amount, '
      'accountId: $accountId, date: $transactionDate)';
}
