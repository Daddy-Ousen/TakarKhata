/// Represents a spending or income category for organizing transactions.
///
/// Categories allow users to classify transactions (e.g., "Food",
/// "Transport", "Salary") for budgeting and reporting purposes.
class Category {
  /// Unique identifier for this category (UUID).
  final String id;

  /// User-visible display name of the category.
  final String name;

  /// Optional icon name used for display purposes.
  final String? iconName;

  /// Optional color value (as an ARGB integer) for UI display.
  final int? colorValue;

  /// Whether this category has been archived (soft-deleted).
  final bool isArchived;

  /// Position used for ordering categories in lists.
  final int sortOrder;

  /// Timestamp when this category was first created.
  final DateTime createdAt;

  /// Timestamp when this category was last modified.
  final DateTime modifiedAt;

  /// Monotonically increasing version number for sync conflict detection.
  final int syncVersion;

  /// Creates a new [Category] instance.
  ///
  /// [id], [name], [createdAt], and [modifiedAt] are required.
  /// Defaults: [isArchived] = false, [sortOrder] = 0, [syncVersion] = 1.
  const Category({
    required this.id,
    required this.name,
    this.iconName,
    this.colorValue,
    this.isArchived = false,
    this.sortOrder = 0,
    required this.createdAt,
    required this.modifiedAt,
    this.syncVersion = 1,
  });

  /// Creates a copy of this category with the given fields replaced.
  Category copyWith({
    String? id,
    String? name,
    String? iconName,
    int? colorValue,
    bool? isArchived,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? modifiedAt,
    int? syncVersion,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      iconName: iconName ?? this.iconName,
      colorValue: colorValue ?? this.colorValue,
      isArchived: isArchived ?? this.isArchived,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      syncVersion: syncVersion ?? this.syncVersion,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Category && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Category(id: $id, name: $name)';
}
