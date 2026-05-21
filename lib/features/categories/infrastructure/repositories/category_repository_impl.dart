import 'package:khatabook/features/categories/domain/entities/category.dart'
    as domain;
import 'package:khatabook/features/categories/domain/repositories/category_repository.dart';
import 'package:khatabook/database/app_database.dart';
import 'package:drift/drift.dart';

/// Drift-backed implementation of [CategoryRepository].
class CategoryRepositoryImpl implements CategoryRepository {
  final AppDatabase _db;

  CategoryRepositoryImpl(this._db);

  domain.Category _toDomain(Category row) {
    return domain.Category(
      id: row.id,
      name: row.name,
      iconName: row.iconName,
      colorValue: row.colorValue,
      isArchived: row.isArchived,
      sortOrder: row.sortOrder,
      createdAt: row.createdAt,
      modifiedAt: row.modifiedAt,
      syncVersion: row.syncVersion,
    );
  }

  CategoriesCompanion _toCompanion(domain.Category entity) {
    return CategoriesCompanion(
      id: Value(entity.id),
      name: Value(entity.name),
      iconName: Value(entity.iconName),
      colorValue: Value(entity.colorValue),
      isArchived: Value(entity.isArchived),
      sortOrder: Value(entity.sortOrder),
      createdAt: Value(entity.createdAt),
      modifiedAt: Value(entity.modifiedAt),
      syncVersion: Value(entity.syncVersion),
    );
  }

  @override
  Future<List<domain.Category>> getAllCategories() async {
    final rows = await _db.categoryDao.getAllCategories();
    return rows.map(_toDomain).toList();
  }

  @override
  Future<domain.Category?> getCategoryById(String id) async {
    final row = await _db.categoryDao.getCategoryById(id);
    return row != null ? _toDomain(row) : null;
  }

  @override
  Future<domain.Category> createCategory(domain.Category category) async {
    await _db.categoryDao.insertCategory(_toCompanion(category));
    return category;
  }

  @override
  Future<void> updateCategory(domain.Category category) async {
    await _db.categoryDao.updateCategory(_toCompanion(category));
  }

  @override
  Future<void> archiveCategory(String id) async {
    await _db.categoryDao.archiveCategory(id);
  }

  @override
  Stream<List<domain.Category>> watchAllCategories() {
    return _db.categoryDao.watchAllCategories().map(
          (rows) => rows.map(_toDomain).toList(),
        );
  }
}
