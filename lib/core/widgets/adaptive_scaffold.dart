import 'package:flutter/material.dart';

import '../theme/color_schemes.dart';

/// A responsive scaffold that adapts its navigation pattern based on the
/// available screen width.
///
/// Layout breakpoints:
/// - **Compact** (< 600dp): [NavigationBar] at the bottom
/// - **Medium** (600–1199dp): [NavigationRail] on the left (icons only)
/// - **Expanded** (≥ 1200dp): [NavigationRail] on the left with labels
///
/// ## Usage
/// ```dart
/// AdaptiveScaffold(
///   currentIndex: _selectedIndex,
///   onDestinationChanged: (i) => setState(() => _selectedIndex = i),
///   destinations: const [
///     AdaptiveDestination(icon: Icons.home_outlined, selectedIcon: Icons.home, label: 'Home'),
///     AdaptiveDestination(icon: Icons.receipt_long_outlined, selectedIcon: Icons.receipt_long, label: 'Transactions'),
///   ],
///   body: _pages[_selectedIndex],
///   floatingActionButton: FloatingActionButton(
///     onPressed: _addTransaction,
///     child: const Icon(Icons.add),
///   ),
/// )
/// ```
class AdaptiveScaffold extends StatelessWidget {
  /// Creates an [AdaptiveScaffold].
  const AdaptiveScaffold({
    required this.currentIndex,
    required this.onDestinationChanged,
    required this.destinations,
    required this.body,
    this.floatingActionButton,
    super.key,
  });

  /// The index of the currently selected destination.
  final int currentIndex;

  /// Called when the user selects a navigation destination.
  final ValueChanged<int> onDestinationChanged;

  /// Navigation destinations. Must contain at least 2 items.
  final List<AdaptiveDestination> destinations;

  /// The primary content area.
  final Widget body;

  /// Optional FAB shown on all layouts.
  final Widget? floatingActionButton;

  /// Compact breakpoint (mobile).
  static const double _compactBreakpoint = 600;

  /// Expanded breakpoint (wide desktop).
  static const double _expandedBreakpoint = 1200;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    if (width < _compactBreakpoint) {
      return _CompactLayout(
        currentIndex: currentIndex,
        onDestinationChanged: onDestinationChanged,
        destinations: destinations,
        body: body,
        floatingActionButton: floatingActionButton,
      );
    }

    return _RailLayout(
      currentIndex: currentIndex,
      onDestinationChanged: onDestinationChanged,
      destinations: destinations,
      body: body,
      floatingActionButton: floatingActionButton,
      showLabels: width >= _expandedBreakpoint,
    );
  }
}

// =============================================================================
// Compact (mobile) layout
// =============================================================================

class _CompactLayout extends StatelessWidget {
  const _CompactLayout({
    required this.currentIndex,
    required this.onDestinationChanged,
    required this.destinations,
    required this.body,
    this.floatingActionButton,
  });

  final int currentIndex;
  final ValueChanged<int> onDestinationChanged;
  final List<AdaptiveDestination> destinations;
  final Widget body;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: body,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: onDestinationChanged,
        destinations: destinations
            .map(
              (d) => NavigationDestination(
                icon: Icon(d.icon),
                selectedIcon: Icon(d.selectedIcon),
                label: d.label,
              ),
            )
            .toList(),
      ),
    );
  }
}

// =============================================================================
// Rail (tablet / desktop) layout
// =============================================================================

class _RailLayout extends StatelessWidget {
  const _RailLayout({
    required this.currentIndex,
    required this.onDestinationChanged,
    required this.destinations,
    required this.body,
    required this.showLabels,
    this.floatingActionButton,
  });

  final int currentIndex;
  final ValueChanged<int> onDestinationChanged;
  final List<AdaptiveDestination> destinations;
  final Widget body;
  final bool showLabels;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: currentIndex,
            onDestinationSelected: onDestinationChanged,
            labelType: showLabels
                ? NavigationRailLabelType.all
                : NavigationRailLabelType.none,
            leading: floatingActionButton != null
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: floatingActionButton,
                  )
                : null,
            destinations: destinations
                .map(
                  (d) => NavigationRailDestination(
                    icon: Icon(d.icon),
                    selectedIcon: Icon(d.selectedIcon),
                    label: Text(d.label),
                  ),
                )
                .toList(),
          ),
          VerticalDivider(
            thickness: 1,
            width: 1,
            color: AppColors.textMuted.withValues(alpha: 0.2),
          ),
          Expanded(child: body),
        ],
      ),
    );
  }
}

// =============================================================================
// Destination data class
// =============================================================================

/// Lightweight data class describing a navigation destination for
/// [AdaptiveScaffold].
///
/// This is independent of both [NavigationDestination] and
/// [NavigationRailDestination] so the scaffold can build whichever widget
/// is appropriate for the current breakpoint.
class AdaptiveDestination {
  /// Creates an [AdaptiveDestination].
  const AdaptiveDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  /// Icon shown when this destination is **not** selected.
  final IconData icon;

  /// Icon shown when this destination **is** selected.
  final IconData selectedIcon;

  /// Text label for the destination.
  final String label;
}
