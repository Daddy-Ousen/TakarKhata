import 'package:khatabook/features/categories/domain/entities/category.dart';

/// Repository contract for category operations.
///
/// Defines the interface that data layer implementations must fulfill
/// to provide category persistence. Categories are used to classify
/// transactions for budgeting and reporting.
abstract class CategoryRepository {
  /// Get all non-archived categories, ordered by [Category.sortOrder].
  ///
  /// Returns an empty list if no active categories exist.
  Future<List<Category>> getAllCategories();

  /// Get a single category by its unique [id].
  ///
  /// Returns `null` if no category with the given [id] exists.
  Future<Category?> getCategoryById(String id);

  /// Create a new category and persist it.
  ///
  /// Returns the created [Category] with any generated fields populated.
  /// Throws if a category with the same ID already exists.
  Future<Category> createCategory(Category category);

  /// Update an existing category with new field values.
  ///
  /// The [category]'s [Category.id] must match an existing record.
  /// Throws if the category does not exist.
  Future<void> updateCategory(Category category);

  /// Archive a category by its [id] (soft delete).
  ///
  /// Archived categories are excluded from [getAllCategories] but
  /// remain referenced by existing transactions.
  Future<void> archiveCategory(String id);

  /// Watch all non-archived categories as a stream for reactive UI updates.
  ///
  /// Emits a new list whenever the underlying data changes.
  /// The list is ordered by [Category.sortOrder].
  Stream<List<Category>> watchAllCategories();
}
