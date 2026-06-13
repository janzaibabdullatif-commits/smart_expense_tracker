import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../providers/budget_provider.dart';
import '../models/expense_model.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final expenseProvider = context.watch<ExpenseProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final expenses = _searchQuery.isEmpty
        ? expenseProvider.expenses
        : expenseProvider.searchExpenses(_searchQuery);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddExpenseDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Search expenses...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Total Summary Card
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [Colors.black, const Color(0xFF1B5E20)]
                    : [const Color(0xFF1565C0), const Color(0xFF42A5F5)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Expenses',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
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
          ),
          const SizedBox(height: 16),

          // Expense List
          Expanded(
            child: expenses.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No expenses found!',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: expenses.length,
                    itemBuilder: (context, index) {
                      final expense = expenses[index];
                      return _ExpenseCard(
                        expense: expense,
                        onEdit: () => _showEditExpenseDialog(context, expense),
                        onDelete: () {
                          expenseProvider.deleteExpense(expense.id).then((_) {
                            // Update budget spent after deletion
                            context.read<BudgetProvider>().updateSpentFromExpenses(expenseProvider.categoryTotals);
                          });
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddExpenseDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddExpenseDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const _ExpenseForm(),
    );
  }

  void _showEditExpenseDialog(BuildContext context, ExpenseModel expense) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _ExpenseForm(expense: expense),
    );
  }
}

class _ExpenseCard extends StatelessWidget {
  final ExpenseModel expense;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ExpenseCard({
    required this.expense,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          child: Icon(_getCategoryIcon(expense.category)),
        ),
        title: Text(
          expense.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(expense.category, style: const TextStyle(color: Colors.grey)),
            Text(
              'Paid via: ${expense.paymentMethod}',
              style: const TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.w500, fontSize: 13),
            ),
            Text(
              '${expense.date.day}/${expense.date.month}/${expense.date.year}',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Rs ${expense.amount.toStringAsFixed(0)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red,
                fontSize: 16,
              ),
            ),
            PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                const PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
              onSelected: (val) {
                if (val == 'edit') onEdit();
                if (val == 'delete') onDelete();
              },
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Food': return Icons.restaurant;
      case 'Transport': return Icons.directions_car;
      case 'Shopping': return Icons.shopping_bag;
      case 'Health': return Icons.health_and_safety;
      case 'Education': return Icons.school;
      default: return Icons.attach_money;
    }
  }
}

class _ExpenseForm extends StatefulWidget {
  final ExpenseModel? expense;

  const _ExpenseForm({this.expense});

  @override
  State<_ExpenseForm> createState() => _ExpenseFormState();
}

class _ExpenseFormState extends State<_ExpenseForm> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _descController = TextEditingController();
  String _category = 'Food';
  String _paymentMethod = 'Cash';
  DateTime _date = DateTime.now();

  final List<String> _categories = ['Food', 'Transport', 'Shopping', 'Health', 'Education', 'Other'];
  final List<String> _paymentMethods = ['Cash', 'Card', 'JazzCash', 'Easypaisa'];

  @override
  void initState() {
    super.initState();
    if (widget.expense != null) {
      _titleController.text = widget.expense!.title;
      _amountController.text = widget.expense!.amount.toString();
      _descController.text = widget.expense!.description;
      _category = widget.expense!.category;
      _paymentMethod = widget.expense!.paymentMethod;
      _date = widget.expense!.date;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24, right: 24, top: 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.expense == null ? 'Add Expense' : 'Edit Expense',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount (Rs)',
                prefixIcon: Icon(Icons.attach_money),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(labelText: 'Category'),
              items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (val) => setState(() => _category = val!),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _paymentMethod,
              decoration: const InputDecoration(labelText: 'Payment Method'),
              items: _paymentMethods.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
              onChanged: (val) => setState(() => _paymentMethod = val!),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Date: ${_date.day}/${_date.month}/${_date.year}'),
              trailing: Icon(Icons.calendar_today, color: Theme.of(context).colorScheme.primary),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (picked != null) setState(() => _date = picked);
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _save,
              child: Text(widget.expense == null ? 'Add Expense' : 'Update Expense'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _save() {
    if (_titleController.text.isEmpty || _amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields!')));
      return;
    }

    final expense = ExpenseModel(
      id: widget.expense?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text,
      amount: double.parse(_amountController.text),
      category: _category,
      paymentMethod: _paymentMethod,
      description: _descController.text,
      date: _date,
    );

    final expenseProvider = context.read<ExpenseProvider>();
    final budgetProvider = context.read<BudgetProvider>();

    if (widget.expense == null) {
      expenseProvider.addExpense(expense).then((_) {
        budgetProvider.updateSpentFromExpenses(expenseProvider.categoryTotals);
      });
    } else {
      expenseProvider.updateExpense(expense).then((_) {
        budgetProvider.updateSpentFromExpenses(expenseProvider.categoryTotals);
      });
    }
    Navigator.pop(context);
  }
}