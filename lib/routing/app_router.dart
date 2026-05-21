import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:khatabook/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:khatabook/features/transactions/presentation/pages/ledger_page.dart';
import 'package:khatabook/features/transactions/presentation/pages/transaction_form_page.dart';
import 'package:khatabook/features/accounts/presentation/pages/accounts_page.dart';
import 'package:khatabook/features/loans/presentation/pages/loans_page.dart';
import 'package:khatabook/features/settings/presentation/pages/settings_page.dart';
import 'package:khatabook/core/widgets/adaptive_scaffold.dart';

/// Route names for type-safe navigation.
class AppRoutes {
  static const String dashboard = '/';
  static const String ledger = '/ledger';
  static const String accounts = '/accounts';
  static const String loans = '/loans';
  static const String settings = '/settings';
  static const String addTransaction = '/transaction/add';
  static const String editTransaction = '/transaction/edit/:id';
}

/// Application router configuration using GoRouter.
final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.dashboard,
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return AppShell(child: child);
      },
      routes: [
        GoRoute(
          path: AppRoutes.dashboard,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: DashboardPage(),
          ),
        ),
        GoRoute(
          path: AppRoutes.ledger,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: LedgerPage(),
          ),
        ),
        GoRoute(
          path: AppRoutes.accounts,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: AccountsPage(),
          ),
        ),
        GoRoute(
          path: AppRoutes.loans,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: LoansPage(),
          ),
        ),
        GoRoute(
          path: AppRoutes.settings,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: SettingsPage(),
          ),
        ),
      ],
    ),
    GoRoute(
      path: AppRoutes.addTransaction,
      builder: (context, state) => const TransactionFormPage(),
    ),
    GoRoute(
      path: '/transaction/edit/:id',
      builder: (context, state) => TransactionFormPage(
        transactionId: state.pathParameters['id'],
      ),
    ),
  ],
);

/// The main app shell that provides the adaptive navigation scaffold.
class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  static const _destinations = [
    AdaptiveDestination(
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard,
      label: 'Dashboard',
    ),
    AdaptiveDestination(
      icon: Icons.receipt_long_outlined,
      selectedIcon: Icons.receipt_long,
      label: 'Ledger',
    ),
    AdaptiveDestination(
      icon: Icons.account_balance_wallet_outlined,
      selectedIcon: Icons.account_balance_wallet,
      label: 'Accounts',
    ),
    AdaptiveDestination(
      icon: Icons.handshake_outlined,
      selectedIcon: Icons.handshake,
      label: 'Loans',
    ),
    AdaptiveDestination(
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
      label: 'Settings',
    ),
  ];

  static const _routes = [
    AppRoutes.dashboard,
    AppRoutes.ledger,
    AppRoutes.accounts,
    AppRoutes.loans,
    AppRoutes.settings,
  ];

  int _getSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    for (int i = 0; i < _routes.length; i++) {
      if (location == _routes[i]) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _getSelectedIndex(context);

    return AdaptiveScaffold(
      currentIndex: selectedIndex,
      onDestinationChanged: (index) {
        context.go(_routes[index]);
      },
      destinations: _destinations,
      body: child,
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.addTransaction),
        child: const Icon(Icons.add),
      ),
    );
  }
}
