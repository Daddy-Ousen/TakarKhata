import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khatabook/core/extensions/date_extensions.dart';
import 'package:khatabook/core/extensions/num_extensions.dart';
import 'package:khatabook/core/theme/color_schemes.dart';
import 'package:khatabook/core/providers/app_providers.dart';
import 'package:khatabook/features/accounts/application/providers/account_providers.dart';
import 'package:khatabook/features/transactions/application/providers/transaction_providers.dart';
import 'package:khatabook/features/transactions/application/financial_engine.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:khatabook/features/accounts/domain/entities/account.dart';

// --- State Providers ---
final selectedMonthProvider = StateProvider<DateTime>((ref) => DateTime.now());
final selectedYearProvider = StateProvider<int>((ref) => DateTime.now().year);

// --- Overview Data Providers ---
final dashboardDataProvider = FutureProvider<DashboardData>((ref) async {
  // Watch streams to trigger re-evaluation on DB changes
  ref.watch(ledgerUpdateProvider);
  ref.watch(accountsStreamProvider);
  ref.watch(recentTransactionsProvider);
  
  final engine = ref.watch(financialEngineProvider);
  final now = DateTime.now();
  return engine.calculateDashboard(now.startOfMonth, now.endOfMonth);
});

final yearlyTrendsProvider = FutureProvider<List<MonthlyTrend>>((ref) async {
  ref.watch(ledgerUpdateProvider);
  ref.watch(accountsStreamProvider);
  ref.watch(recentTransactionsProvider);
  
  final engine = ref.watch(financialEngineProvider);
  return engine.monthlyTrends(DateTime.now().year);
});

final netWorthProvider = FutureProvider<int>((ref) async {
  ref.watch(ledgerUpdateProvider);
  ref.watch(accountsStreamProvider);
  return ref.watch(financialEngineProvider).calculateNetWorth();
});

// --- Monthly Data Providers ---
final monthlyDashboardDataProvider = FutureProvider<DashboardData>((ref) async {
  ref.watch(ledgerUpdateProvider);
  final month = ref.watch(selectedMonthProvider);
  final engine = ref.watch(financialEngineProvider);
  return engine.calculateDashboard(month.startOfMonth, month.endOfMonth);
});

// --- Yearly Data Providers ---
final yearlyDashboardDataProvider = FutureProvider<DashboardData>((ref) async {
  ref.watch(ledgerUpdateProvider);
  final year = ref.watch(selectedYearProvider);
  final engine = ref.watch(financialEngineProvider);
  return engine.calculateDashboard(
    DateTime(year, 1, 1), 
    DateTime(year, 12, 31, 23, 59, 59, 999)
  );
});

final customYearlyTrendsProvider = FutureProvider<List<MonthlyTrend>>((ref) async {
  ref.watch(ledgerUpdateProvider);
  final year = ref.watch(selectedYearProvider);
  final engine = ref.watch(financialEngineProvider);
  return engine.monthlyTrends(year);
});

// --- Main Dashboard Page ---
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Dashboard'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'Monthly'),
              Tab(text: 'Yearly'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _OverviewTabView(),
            _MonthlyTabView(),
            _YearlyTabView(),
          ],
        ),
      ),
    );
  }
}

// --- Overview Tab ---
class _OverviewTabView extends ConsumerWidget {
  const _OverviewTabView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardDataProvider);
    final trendsAsync = ref.watch(yearlyTrendsProvider);
    final netWorthAsync = ref.watch(netWorthProvider);
    final accountsAsync = ref.watch(accountsWithBalancesProvider);

    return dashboardAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
      data: (dashboard) => RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dashboardDataProvider);
          ref.invalidate(yearlyTrendsProvider);
          ref.invalidate(netWorthProvider);
          ref.invalidate(accountsWithBalancesProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            netWorthAsync.when(
              data: (netWorth) => _NetWorthCard(
                netWorth: netWorth,
                currentBalance: dashboard.currentBalance,
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 16),
            _SummaryCardsRow(dashboard: dashboard),
            const SizedBox(height: 16),
            if (dashboard.expensesByCategory.isNotEmpty)
              _ExpensePieChart(
                expenses: dashboard.expensesByCategory,
                categoryNames: dashboard.categoryNames,
              ),
            const SizedBox(height: 16),
            trendsAsync.when(
              data: (trends) => trends.isNotEmpty
                  ? _TrendChart(trends: trends)
                  : const SizedBox.shrink(),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 16),
            accountsAsync.when(
              data: (accounts) => _AccountOverview(accounts: accounts),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 16),
            _LiabilitiesCard(
              totalOwed: dashboard.totalLiabilities,
              totalReceivable: dashboard.totalReceivables,
              creditDebt: dashboard.creditCardDebt,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// --- Monthly Tab ---
class _MonthlyTabView extends ConsumerWidget {
  const _MonthlyTabView();

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMonth = ref.watch(selectedMonthProvider);
    final dashboardAsync = ref.watch(monthlyDashboardDataProvider);

    return Column(
      children: [
        // Month Selector
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {
                  ref.read(selectedMonthProvider.notifier).state =
                      DateTime(selectedMonth.year, selectedMonth.month - 1);
                },
              ),
              Text(
                '${_months[selectedMonth.month - 1]} ${selectedMonth.year}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  ref.read(selectedMonthProvider.notifier).state =
                      DateTime(selectedMonth.year, selectedMonth.month + 1);
                },
              ),
            ],
          ),
        ),
        // Content
        Expanded(
          child: dashboardAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Center(child: Text('Error: $e')),
            data: (dashboard) => RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(monthlyDashboardDataProvider);
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _SummaryCardsRow(dashboard: dashboard),
                  const SizedBox(height: 16),
                  if (dashboard.expensesByCategory.isNotEmpty)
                    _ExpensePieChart(
                      expenses: dashboard.expensesByCategory,
                      categoryNames: dashboard.categoryNames,
                    )
                  else
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Center(
                          child: Text('No expenses recorded for this month.'),
                        ),
                      ),
                    ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// --- Yearly Tab ---
class _YearlyTabView extends ConsumerWidget {
  const _YearlyTabView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedYear = ref.watch(selectedYearProvider);
    final dashboardAsync = ref.watch(yearlyDashboardDataProvider);
    final trendsAsync = ref.watch(customYearlyTrendsProvider);

    return Column(
      children: [
        // Year Selector
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {
                  ref.read(selectedYearProvider.notifier).state = selectedYear - 1;
                },
              ),
              Text(
                '$selectedYear',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  ref.read(selectedYearProvider.notifier).state = selectedYear + 1;
                },
              ),
            ],
          ),
        ),
        // Content
        Expanded(
          child: dashboardAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Center(child: Text('Error: $e')),
            data: (dashboard) => RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(yearlyDashboardDataProvider);
                ref.invalidate(customYearlyTrendsProvider);
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _SummaryCardsRow(dashboard: dashboard),
                  const SizedBox(height: 16),
                  if (dashboard.expensesByCategory.isNotEmpty)
                    _ExpensePieChart(
                      expenses: dashboard.expensesByCategory,
                      categoryNames: dashboard.categoryNames,
                    )
                  else
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Center(
                          child: Text('No expenses recorded for this year.'),
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  trendsAsync.when(
                    data: (trends) => trends.isNotEmpty
                        ? _TrendChart(trends: trends)
                        : const SizedBox.shrink(),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Net Worth Card ────────────────────────────────────────────────────────────

class _NetWorthCard extends StatelessWidget {
  final int netWorth;
  final int currentBalance;
  
  const _NetWorthCard({required this.netWorth, required this.currentBalance});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              AppColors.income.withValues(alpha: 0.15),
              AppColors.accentBlue.withValues(alpha: 0.08),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Balance',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currentBalance.toCurrencyString(),
                    style: TextStyle(
                      color: currentBalance >= 0 ? AppColors.textPrimary : AppColors.expense,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Net Worth',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    netWorth.toCurrencyString(),
                    style: TextStyle(
                      color: netWorth >= 0 ? AppColors.income : AppColors.expense,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Summary Cards ─────────────────────────────────────────────────────────────

class _SummaryCardsRow extends StatelessWidget {
  final DashboardData dashboard;
  const _SummaryCardsRow({required this.dashboard});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;
        final cards = [
          _SummaryCard(
            title: 'Income',
            amount: dashboard.totalIncome,
            icon: Icons.trending_up,
            color: AppColors.income,
          ),
          _SummaryCard(
            title: 'Expenses',
            amount: dashboard.totalExpenses,
            icon: Icons.trending_down,
            color: AppColors.expense,
          ),
          _SummaryCard(
            title: 'Net Savings',
            amount: dashboard.netSavings,
            icon: Icons.savings,
            color: dashboard.netSavings >= 0
                ? AppColors.savings
                : AppColors.warning,
          ),
        ];

        if (isWide) {
          return Row(
            children: cards
                .map((c) => Expanded(child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: c,
                    )))
                .toList(),
          );
        }

        return Column(
          children: cards
              .map((c) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: c,
                  ))
              .toList(),
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final int amount;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              amount.toCurrencyString(),
              style: TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Expense Pie Chart ─────────────────────────────────────────────────────────

class _ExpensePieChart extends StatelessWidget {
  final Map<String, int> expenses;
  final Map<String, String> categoryNames;
  
  const _ExpensePieChart({
    required this.expenses,
    required this.categoryNames,
  });

  @override
  Widget build(BuildContext context) {
    final total = expenses.values.fold(0, (sum, v) => sum + v);
    if (total == 0) return const SizedBox.shrink();

    final sortedEntries = expenses.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Expense Breakdown',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: sortedEntries
                      .asMap()
                      .entries
                      .map((entry) {
                    final idx = entry.key;
                    final e = entry.value;
                    final pct = (e.value / total * 100);
                    return PieChartSectionData(
                      color: AppColors.chartPalette[
                          idx % AppColors.chartPalette.length],
                      value: e.value.toDouble(),
                      title: pct >= 5 ? '${pct.toStringAsFixed(0)}%' : '',
                      radius: 50,
                      titleStyle: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Legend
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: sortedEntries
                  .asMap()
                  .entries
                  .map((entry) {
                final idx = entry.key;
                final e = entry.value;
                final categoryName = categoryNames[e.key] ?? 'Unknown';
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.chartPalette[
                            idx % AppColors.chartPalette.length],
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      categoryName,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Trend Chart ───────────────────────────────────────────────────────────────

class _TrendChart extends StatelessWidget {
  final List<MonthlyTrend> trends;
  const _TrendChart({required this.trends});

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Monthly Trends',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: _getInterval(),
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: AppColors.textMuted.withValues(alpha: 0.2),
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 60,
                        getTitlesWidget: (value, meta) => Text(
                          _formatAxis(value.toInt()),
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= trends.length) {
                            return const SizedBox.shrink();
                          }
                          return Text(
                            _months[trends[idx].month - 1],
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.textMuted,
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    // Income line
                    LineChartBarData(
                      spots: trends
                          .asMap()
                          .entries
                          .map((e) => FlSpot(
                              e.key.toDouble(), e.value.income.toDouble()))
                          .toList(),
                      color: AppColors.income,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.income.withValues(alpha: 0.1),
                      ),
                    ),
                    // Expense line
                    LineChartBarData(
                      spots: trends
                          .asMap()
                          .entries
                          .map((e) => FlSpot(
                              e.key.toDouble(), e.value.expenses.toDouble()))
                          .toList(),
                      color: AppColors.expense,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.expense.withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _LegendDot(color: AppColors.income, label: 'Income'),
                const SizedBox(width: 24),
                _LegendDot(color: AppColors.expense, label: 'Expenses'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  double _getInterval() {
    final maxVal = trends
        .map((t) => t.income > t.expenses ? t.income : t.expenses)
        .fold(0, (max, v) => v > max ? v : max);
    if (maxVal == 0) return 100;
    return (maxVal / 4).roundToDouble();
  }

  String _formatAxis(int cents) {
    if (cents >= 100000) return '${(cents / 100000).toStringAsFixed(0)}K';
    if (cents >= 1000) return '${(cents / 100).toStringAsFixed(0)}';
    return cents.toString();
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 4,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(label,
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }
}

// ── Account Overview ──────────────────────────────────────────────────────────

class _AccountOverview extends StatelessWidget {
  final List<Account> accounts;
  const _AccountOverview({required this.accounts});

  @override
  Widget build(BuildContext context) {
    if (accounts.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Account Balances',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            ...accounts.map((account) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Color(account.colorValue ?? 0xFF78909C)
                              .withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.account_balance_wallet,
                          size: 18,
                          color: Color(account.colorValue ?? 0xFF78909C),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              account.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              account.type.label,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        account.cachedBalance.toCurrencyString(),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: account.cachedBalance >= 0
                              ? AppColors.income
                              : AppColors.expense,
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

// ── Liabilities Card ──────────────────────────────────────────────────────────

class _LiabilitiesCard extends StatelessWidget {
  final int totalOwed;
  final int totalReceivable;
  final int creditDebt;

  const _LiabilitiesCard({
    required this.totalOwed,
    required this.totalReceivable,
    required this.creditDebt,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Liabilities & Receivables',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            _LiabilityRow(
              label: 'Money I Owe',
              amount: totalOwed,
              color: AppColors.expense,
              icon: Icons.arrow_upward,
            ),
            const SizedBox(height: 12),
            _LiabilityRow(
              label: 'Money Owed To Me',
              amount: totalReceivable,
              color: AppColors.income,
              icon: Icons.arrow_downward,
            ),
            if (creditDebt > 0) ...[
              const SizedBox(height: 12),
              _LiabilityRow(
                label: 'Credit Card Debt',
                amount: creditDebt,
                color: AppColors.credit,
                icon: Icons.credit_card,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LiabilityRow extends StatelessWidget {
  final String label;
  final int amount;
  final Color color;
  final IconData icon;

  const _LiabilityRow({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
        ),
        Text(
          amount.toCurrencyString(),
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
