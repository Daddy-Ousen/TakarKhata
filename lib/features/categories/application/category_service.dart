import 'package:khatabook/core/utils/uuid_generator.dart';
import 'package:khatabook/features/categories/domain/entities/category.dart';
import 'package:khatabook/features/categories/domain/repositories/category_repository.dart';

/// Service for category management operations.
class CategoryService {
  final CategoryRepository _categoryRepository;

  CategoryService({
    required CategoryRepository categoryRepository,
  }) : _categoryRepository = categoryRepository;

  /// Create a new category.
  Future<Category> createCategory({
    required String name,
    String? iconName,
    int? colorValue,
    int sortOrder = 0,
  }) async {
    final now = DateTime.now();
    final category = Category(
      id: UuidGenerator.generate(),
      name: name,
      iconName: iconName,
      colorValue: colorValue,
      sortOrder: sortOrder,
      createdAt: now,
      modifiedAt: now,
    );

    return _categoryRepository.createCategory(category);
  }

  /// Update a category's details.
  Future<void> updateCategory(Category category) async {
    await _categoryRepository.updateCategory(
      category.copyWith(modifiedAt: DateTime.now()),
    );
  }

  /// Archive (soft-delete) a category.
  Future<void> archiveCategory(String id) async {
    await _categoryRepository.archiveCategory(id);
  }
}
