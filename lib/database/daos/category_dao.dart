import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/categories_table.dart';

part 'category_dao.g.dart';

/// Data Access Object for category-related database operations.
///
/// Provides CRUD operations, archiving, and reactive streams for
/// transaction categories (e.g., "Food", "Rent", "Salary").
@DriftAccessor(tables: [Categories])
class CategoryDao extends DatabaseAccessor<AppDatabase>
    with _$CategoryDaoMixin {
  /// Creates a [CategoryDao] attached to the given [db].
  CategoryDao(AppDatabase db) : super(db);

  /// Returns all non-archived categories ordered by [sortOrder].
  Future<List<Category>> getAllCategories() {
    return (select(categories)
          ..where((c) => c.isArchived.equals(false))
          ..orderBy([(c) => OrderingTerm.asc(c.sortOrder)]))
        .get();
  }

  /// Returns all categories including archived ones, ordered by [sortOrder].
  Future<List<Category>> getAllCategoriesIncludingArchived() {
    return (select(categories)
          ..orderBy([(c) => OrderingTerm.asc(c.sortOrder)]))
        .get();
  }

  /// Returns the category with the given [id], or `null` if not found.
  Future<Category?> getCategoryById(String id) {
    return (select(categories)..where((c) => c.id.equals(id)))
        .getSingleOrNull();
  }

  /// Inserts a new category into the database.
  ///
  /// The [category] companion must include at minimum: [id], [name],
  /// [createdAt], and [modifiedAt].
  Future<void> insertCategory(CategoriesCompanion category) {
    return into(categories).insert(category);
  }

  /// Updates an existing category.
  ///
  /// The [category] companion must include [id] to identify the row.
  Future<void> updateCategory(CategoriesCompanion category) {
    return (update(categories)
          ..where((c) => c.id.equals(category.id.value)))
        .write(category);
  }

  /// Archives the category with the given [id].
  ///
  /// Archived categories remain linked to existing transactions but
  /// are hidden from the category selection UI.
  Future<void> archiveCategory(String id) {
    return (update(categories)..where((c) => c.id.equals(id))).write(
      CategoriesCompanion(
        isArchived: const Value(true),
        modifiedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Un-archives the category with the given [id].
  Future<void> unarchiveCategory(String id) {
    return (update(categories)..where((c) => c.id.equals(id))).write(
      CategoriesCompanion(
        isArchived: const Value(false),
        modifiedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Emits a new list whenever the non-archived categories change.
  ///
  /// Useful for building reactive category selection UIs.
  Stream<List<Category>> watchAllCategories() {
    return (select(categories)
          ..where((c) => c.isArchived.equals(false))
          ..orderBy([(c) => OrderingTerm.asc(c.sortOrder)]))
        .watch();
  }

  /// Emits a new list whenever any category changes (including archived).
  Stream<List<Category>> watchAllCategoriesIncludingArchived() {
    return (select(categories)
          ..orderBy([(c) => OrderingTerm.asc(c.sortOrder)]))
        .watch();
  }

  /// Returns the total number of non-archived categories.
  Future<int> getCategoryCount() async {
    final result = await customSelect(
      'SELECT COUNT(*) AS cnt FROM categories WHERE is_archived = 0',
      readsFrom: {categories},
    ).getSingle();

    return result.read<int>('cnt');
  }
}
