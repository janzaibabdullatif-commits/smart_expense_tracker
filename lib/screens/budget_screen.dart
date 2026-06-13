import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/budget_provider.dart';
import '../providers/expense_provider.dart';
import '../models/budget_model.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final budgetProvider = context.watch<BudgetProvider>();
    final expenseProvider = context.watch<ExpenseProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddBudgetDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [Colors.black, const Color(0xFF1B5E20)]
                    : [const Color(0xFF1565C0), const Color(0xFF42A5F5)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text('Total Budget',
                        style: TextStyle(color: Colors.white70)),
                    Text(
                      'Rs ${budgetProvider.totalBudget.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(width: 1, height: 40, color: Colors.white30),
                Column(
                  children: [
                    const Text('Total Spent',
                        style: TextStyle(color: Colors.white70)),
                    Text(
                      'Rs ${expenseProvider.totalExpenses.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Budget List
          Expanded(
            child: budgetProvider.budgets.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.savings, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No budget set!',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                        Text(
                          '+ button for add budget',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: budgetProvider.budgets.length,
                    itemBuilder: (context, index) {
                      final budget = budgetProvider.budgets[index];
                      final progress = budget.limit > 0
                          ? (budget.spent / budget.limit).clamp(0.0, 1.0)
                          : 0.0;
                      final isExceeded = budget.spent >= budget.limit;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    budget.category,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      if (isExceeded)
                                        const Icon(Icons.warning,
                                            color: Colors.red, size: 18),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline,
                                            color: Colors.red),
                                        onPressed: () => _confirmDelete(context, budgetProvider, budget),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Spent: Rs ${budget.spent.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      color: isExceeded
                                          ? Colors.red
                                          : Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    'Limit: Rs ${budget.limit.toStringAsFixed(0)}',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: LinearProgressIndicator(
                                  value: progress,
                                  minHeight: 10,
                                  backgroundColor: isDark ? Colors.grey[800] : Colors.grey.shade200,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    isExceeded ? Colors.red : Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isExceeded
                                    ? '⚠️ Budget exceeded!'
                                    : '${(progress * 100).toStringAsFixed(0)}% used',
                                style: TextStyle(
                                  color: isExceeded ? Colors.red : Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddBudgetDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _confirmDelete(BuildContext context, BudgetProvider provider, BudgetModel budget) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Budget'),
        content: Text('Are you sure you want to delete the budget for ${budget.category}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              provider.deleteBudget(budget.id);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAddBudgetDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const _BudgetForm(),
    );
  }
}

class _BudgetForm extends StatefulWidget {
  const _BudgetForm();

  @override
  State<_BudgetForm> createState() => _BudgetFormState();
}

class _BudgetFormState extends State<_BudgetForm> {
  final _limitController = TextEditingController();
  String _category = 'Food';
  final String _month = '${DateTime.now().month}/${DateTime.now().year}';

  final List<String> _categories = [
    'Food',
    'Transport',
    'Shopping',
    'Health',
    'Education',
    'Other'
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Set Budget',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _category,
            decoration: const InputDecoration(labelText: 'Category'),
            items: _categories
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (val) => setState(() => _category = val!),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _limitController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Budget Limit (Rs)',
              prefixIcon: Icon(Icons.attach_money),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              if (_limitController.text.isEmpty) return;
              
              final expenseProvider = context.read<ExpenseProvider>();
              final initialSpent = expenseProvider.categoryTotals[_category] ?? 0.0;

              final budget = BudgetModel(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                category: _category,
                limit: double.parse(_limitController.text),
                spent: initialSpent,
                month: _month,
              );
              context.read<BudgetProvider>().addBudget(budget);
              Navigator.pop(context);
            },
            child: const Text('Set Budget'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}