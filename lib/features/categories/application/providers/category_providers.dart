import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khatabook/core/providers/app_providers.dart';
import 'package:khatabook/features/categories/application/category_service.dart';
import 'package:khatabook/features/categories/domain/entities/category.dart';

/// Provider for the CategoryService.
final categoryServiceProvider = Provider<CategoryService>((ref) {
  return CategoryService(
    categoryRepository: ref.watch(categoryRepositoryProvider),
  );
});

/// Stream provider for all active categories.
final categoriesProvider = StreamProvider<List<Category>>((ref) {
  return ref.watch(categoryRepositoryProvider).watchAllCategories();
});

/// Provider for fetching a single category by ID.
final categoryByIdProvider = FutureProvider.family<Category?, String>((ref, id) async {
  return ref.watch(categoryRepositoryProvider).getCategoryById(id);
});
