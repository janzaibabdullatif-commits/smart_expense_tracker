import 'package:flutter/material.dart';
import '../models/budget_model.dart';

class BudgetProgress extends StatelessWidget {
  final BudgetModel budget;
  final VoidCallback onDelete;

  const BudgetProgress({
    super.key,
    required this.budget,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final progress = budget.limit > 0
        ? (budget.spent / budget.limit).clamp(0.0, 1.0)
        : 0.0;
    final isExceeded = budget.spent >= budget.limit;
    final remaining = budget.limit - budget.spent;
    final progressColor = isExceeded
        ? Colors.red
        : progress > 0.8
        ? Colors.orange
        : const Color(0xFF1565C0);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: progressColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _getCategoryIcon(budget.category),
                        color: progressColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      budget.category,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    if (isExceeded)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          '⚠️ Exceeded!',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    IconButton(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline,
                          color: Colors.red, size: 20),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                backgroundColor: Colors.grey.shade100,
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              ),
            ),
            const SizedBox(height: 10),

            // Stats Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _StatChip(
                  label: 'Spent',
                  value: 'Rs ${budget.spent.toStringAsFixed(0)}',
                  color: Colors.red,
                ),
                _StatChip(
                  label: 'Remaining',
                  value: remaining >= 0
                      ? 'Rs ${remaining.toStringAsFixed(0)}'
                      : '-Rs ${remaining.abs().toStringAsFixed(0)}',
                  color: remaining >= 0 ? Colors.green : Colors.red,
                ),
                _StatChip(
                  label: 'Limit',
                  value: 'Rs ${budget.limit.toStringAsFixed(0)}',
                  color: const Color(0xFF1565C0),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Percentage
            Text(
              '${(progress * 100).toStringAsFixed(1)}% of budget used',
              style: TextStyle(
                color: progressColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
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

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 11),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}