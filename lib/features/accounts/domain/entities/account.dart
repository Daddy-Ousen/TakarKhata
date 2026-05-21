import 'package:khatabook/core/enums/account_type.dart';

/// Represents a financial account in the system.
///
/// Accounts track where money is held (bank, cash, wallet, etc.).
/// The [cachedBalance] field is derived from ledger entries and is
/// periodically recalculated for performance. It should not be used
/// as the source of truth for critical financial calculations.
class Account {
  /// Unique identifier for this account (UUID).
  final String id;

  /// User-visible display name of the account.
  final String name;

  /// The category of this account (cash, bank, wallet, etc.).
  final AccountType type;

  /// Optional icon name used for display purposes.
  final String? iconName;

  /// Optional color value (as an ARGB integer) for UI display.
  final int? colorValue;

  /// Whether this account has been archived (soft-deleted).
  final bool isArchived;

  /// Position used for ordering accounts in lists.
  final int sortOrder;

  /// Timestamp when this account was first created.
  final DateTime createdAt;

  /// Timestamp when this account was last modified.
  final DateTime modifiedAt;

  /// Monotonically increasing version number for sync conflict detection.
  final int syncVersion;

  /// Cached balance in cents. This is derived from ledger entries
  /// and should not be used as source of truth for critical calculations.
  final int cachedBalance;

  /// Creates a new [Account] instance.
  ///
  /// [id] and [name] are required. [type] determines the account category.
  /// Defaults: [isArchived] = false, [sortOrder] = 0, [syncVersion] = 1,
  /// [cachedBalance] = 0.
  const Account({
    required this.id,
    required this.name,
    required this.type,
    this.iconName,
    this.colorValue,
    this.isArchived = false,
    this.sortOrder = 0,
    required this.createdAt,
    required this.modifiedAt,
    this.syncVersion = 1,
    this.cachedBalance = 0,
  });

  /// Creates a copy of this account with the given fields replaced.
  Account copyWith({
    String? id,
    String? name,
    AccountType? type,
    String? iconName,
    int? colorValue,
    bool? isArchived,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? modifiedAt,
    int? syncVersion,
    int? cachedBalance,
  }) {
    return Account(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      iconName: iconName ?? this.iconName,
      colorValue: colorValue ?? this.colorValue,
      isArchived: isArchived ?? this.isArchived,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      syncVersion: syncVersion ?? this.syncVersion,
      cachedBalance: cachedBalance ?? this.cachedBalance,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Account && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Account(id: $id, name: $name, type: $type, balance: $cachedBalance)';
}
