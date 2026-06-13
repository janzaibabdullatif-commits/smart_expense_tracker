import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/budget_model.dart';
import '../services/notification_service.dart';

class BudgetProvider extends ChangeNotifier {
  String? _uid;
  Box? _box;
  List<BudgetModel> _budgets = [];
  
  // Track triggered thresholds to avoid spam: category_percentage
  final Set<String> _triggeredAlerts = {};

  List<BudgetModel> get budgets => _budgets;

  double get totalBudget =>
      _budgets.fold(0.0, (sum, b) => sum + b.limit);

  double get totalSpent =>
      _budgets.fold(0.0, (sum, b) => sum + b.spent);

  // Set UID and initialize box
  Future<void> setUid(String? uid) async {
    if (_uid == uid) return;
    _uid = uid;

    if (uid == null) {
      _budgets = [];
      _box = null;
      _triggeredAlerts.clear();
    } else {
      _box = await Hive.openBox('budgets_$uid');
      loadBudgets();
    }
    notifyListeners();
  }

  DatabaseReference? get _db => _uid != null
      ? FirebaseDatabase.instance.ref('users/$_uid/budgets')
      : null;

  // Load from Hive
  void loadBudgets() {
    if (_box == null) return;
    _budgets = _box!.values
        .map((e) => BudgetModel.fromMap(Map<String, dynamic>.from(e)))
        .toList();
    notifyListeners();
  }

  // Add budget
  Future<void> addBudget(BudgetModel budget) async {
    if (_box == null) return;
    await _box!.put(budget.id, budget.toMap());
    _budgets.add(budget);
    notifyListeners();

    try {
      await _db?.child(budget.id).set(budget.toMap());
    } catch (e) {
      debugPrint('Firebase error: $e');
    }
  }

  // Update spent - This is important to call when an expense is added
  Future<void> updateSpent(String category, double amount) async {
    if (_box == null) return;
    int index = _budgets.indexWhere((b) => b.category == category);
    if (index != -1) {
      _budgets[index].spent += amount;
      await _box!.put(_budgets[index].id, _budgets[index].toMap());
      
      _checkThresholds(_budgets[index]);
      
      notifyListeners();

      try {
        await _db?.child(_budgets[index].id).update({'spent': _budgets[index].spent});
      } catch (e) {
        debugPrint('Firebase error: $e');
      }
    }
  }

  // Recalculate all spent amounts from expenses (Professional fix)
  void updateSpentFromExpenses(Map<String, double> categoryTotals) {
    if (_box == null) return;
    bool changed = false;
    for (var i = 0; i < _budgets.length; i++) {
      double newSpent = categoryTotals[_budgets[i].category] ?? 0.0;
      if (_budgets[i].spent != newSpent) {
        _budgets[i].spent = newSpent;
        _box!.put(_budgets[i].id, _budgets[i].toMap());
        
        _checkThresholds(_budgets[i]);
        
        changed = true;
      }
    }
    if (changed) notifyListeners();
  }

  void _checkThresholds(BudgetModel budget) {
    if (budget.limit <= 0) return;
    
    double percentage = budget.spent / budget.limit;
    String cat = budget.category;

    if (percentage >= 1.0) {
      if (!_triggeredAlerts.contains('${cat}_100')) {
        NotificationService().showBudgetAlert(cat, 1.0);
        _triggeredAlerts.add('${cat}_100');
        _triggeredAlerts.add('${cat}_80'); // If exceeded, don't show 80 later
      }
    } else if (percentage >= 0.8) {
      if (!_triggeredAlerts.contains('${cat}_80')) {
        NotificationService().showBudgetAlert(cat, 0.8);
        _triggeredAlerts.add('${cat}_80');
      }
    } else {
      // If spent goes below thresholds (e.g. expense deleted), reset alerts
      _triggeredAlerts.remove('${cat}_80');
      _triggeredAlerts.remove('${cat}_100');
    }
  }

  // Delete budget
  Future<void> deleteBudget(String id) async {
    if (_box == null) return;
    await _box!.delete(id);
    final budget = _budgets.firstWhere((b) => b.id == id);
    _triggeredAlerts.remove('${budget.category}_80');
    _triggeredAlerts.remove('${budget.category}_100');

    _budgets.removeWhere((b) => b.id == id);
    notifyListeners();

    try {
      await _db?.child(id).remove();
    } catch (e) {
      debugPrint('Firebase error: $e');
    }
  }
}