import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khatabook/core/theme/app_theme.dart';
import 'package:khatabook/routing/app_router.dart';
import 'package:khatabook/core/providers/app_providers.dart';
import 'package:khatabook/core/constants/default_data.dart';
import 'package:khatabook/core/utils/uuid_generator.dart';
import 'package:khatabook/features/categories/domain/entities/category.dart'
    as domain;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: KhataBookApp()));
}

/// Root application widget.
class KhataBookApp extends ConsumerStatefulWidget {
  const KhataBookApp({super.key});

  @override
  ConsumerState<KhataBookApp> createState() => _KhataBookAppState();
}

class _KhataBookAppState extends ConsumerState<KhataBookApp> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Initialize default data on first launch
      await ref.read(accountServiceProvider).initializeDefaultAccounts();
      await _initializeDefaultCategories();

      // Validate ledger integrity on startup
      final issues =
          await ref.read(financialEngineProvider).validateLedgerIntegrity();
      if (issues.isNotEmpty) {
        debugPrint(
            'Ledger integrity issues found: ${issues.length}. Repairing...');
        await ref.read(financialEngineProvider).repairIntegrity();
      }
    } catch (e) {
      debugPrint('Error during initialization: $e');
    }

    if (mounted) {
      setState(() => _initialized = true);
    }
  }

  Future<void> _initializeDefaultCategories() async {
    final repo = ref.read(categoryRepositoryProvider);
    final existing = await repo.getAllCategories();
    if (existing.isNotEmpty) return;

    final defaults = DefaultData.defaultCategories();
    for (final data in defaults) {
      final now = DateTime.now();
      await repo.createCategory(domain.Category(
        id: UuidGenerator.generate(),
        name: data['name'] as String,
        iconName: data['iconName'] as String?,
        colorValue: data['colorValue'] as int?,
        sortOrder: data['sortOrder'] as int? ?? 0,
        createdAt: now,
        modifiedAt: now,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return MaterialApp(
        theme: AppTheme.darkTheme,
        home: const Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 24),
                Text(
                  'KhataBook',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Setting up your ledger...',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return MaterialApp.router(
      title: 'KhataBook',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: appRouter,
    );
  }
}
