import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/expense_provider.dart';
import '../providers/budget_provider.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final expenseProvider = context.watch<ExpenseProvider>();
    final budgetProvider = context.watch<BudgetProvider>();
    final categoryTotals = expenseProvider.categoryTotals;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Row
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Total Expenses',
                    value: 'Rs ${expenseProvider.totalExpenses.toStringAsFixed(0)}',
                    icon: Icons.trending_down,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'Total Budget',
                    value: 'Rs ${budgetProvider.totalBudget.toStringAsFixed(0)}',
                    icon: Icons.savings,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Savings',
                    value: 'Rs ${(budgetProvider.totalBudget - expenseProvider.totalExpenses).toStringAsFixed(0)}',
                    icon: Icons.account_balance_wallet,
                    color: isDark ? const Color(0xFF4CAF50) : Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'Transactions',
                    value: '${expenseProvider.expenses.length}',
                    icon: Icons.receipt_long,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Pie Chart
            if (categoryTotals.isNotEmpty) ...[
              const Text(
                'Spending by Category',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    SizedBox(
                      height: 220,
                      child: PieChart(
                        PieChartData(
                          sections: _buildPieSections(categoryTotals, isDark),
                          centerSpaceRadius: 50,
                          sectionsSpace: 2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Legend
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: categoryTotals.entries.map((entry) {
                        final index = categoryTotals.keys.toList().indexOf(entry.key);
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: _getColor(index, isDark),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${entry.key}: Rs ${entry.value.toStringAsFixed(0)}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Category Breakdown
            const Text(
              'Category Breakdown',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            categoryTotals.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text(
                        'No expenses yet!',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: categoryTotals.length,
                    itemBuilder: (context, index) {
                      final entry = categoryTotals.entries.toList()[index];
                      final percentage = expenseProvider.totalExpenses > 0
                          ? (entry.value / expenseProvider.totalExpenses * 100).toStringAsFixed(1)
                          : '0';
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: _getColor(index, isDark).withOpacity(0.2),
                              child: Icon(
                                _getCategoryIcon(entry.key),
                                color: _getColor(index, isDark),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    entry.key,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: expenseProvider.totalExpenses > 0
                                          ? entry.value / expenseProvider.totalExpenses
                                          : 0,
                                      backgroundColor: isDark ? Colors.grey[800] : Colors.grey.shade200,
                                      valueColor: AlwaysStoppedAnimation<Color>(_getColor(index, isDark)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Rs ${entry.value.toStringAsFixed(0)}',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '$percentage%',
                                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieSections(Map<String, double> categoryTotals, bool isDark) {
    final total = categoryTotals.values.fold(0.0, (sum, val) => sum + val);
    return categoryTotals.entries.toList().asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      return PieChartSectionData(
        color: _getColor(index, isDark),
        value: data.value,
        title: '${(data.value / total * 100).toStringAsFixed(1)}%',
        radius: 60,
        titleStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.black : Colors.white,
        ),
      );
    }).toList();
  }

  Color _getColor(int index, bool isDark) {
    if (isDark) {
      const darkColors = [
        Color(0xFF4CAF50),
        Color(0xFF81C784),
        Color(0xFFA5D6A7),
        Color(0xFFC8E6C9),
        Color(0xFF2E7D32),
        Color(0xFF1B5E20),
      ];
      return darkColors[index % darkColors.length];
    }
    const colors = [
      Color(0xFF1565C0),
      Color(0xFF42A5F5),
      Color(0xFF26A69A),
      Color(0xFFFF7043),
      Color(0xFFAB47BC),
      Color(0xFFFFCA28),
    ];
    return colors[index % colors.length];
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Food':
        return Icons.restaurant;
      case 'Transport':
        return Icons.directions_car;
      case 'Shopping':
        return Icons.shopping_bag;
      case 'Health':
        return Icons.health_and_safety;
      case 'Education':
        return Icons.school;
      default:
        return Icons.attach_money;
    }
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}