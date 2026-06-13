import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/expense_model.dart';

class ExpenseProvider extends ChangeNotifier {
  String? _uid;
  Box? _box;
  List<ExpenseModel> _expenses = [];

  List<ExpenseModel> get expenses => _expenses;

  double get totalExpenses =>
      _expenses.fold(0, (sum, e) => sum + e.amount);

  Map<String, double> get categoryTotals {
    Map<String, double> totals = {};
    for (var e in _expenses) {
      totals[e.category] = (totals[e.category] ?? 0) + e.amount;
    }
    return totals;
  }

  // Set UID and initialize box
  Future<void> setUid(String? uid) async {
    if (_uid == uid) return;
    _uid = uid;
    
    if (uid == null) {
      _expenses = [];
      _box = null;
    } else {
      _box = await Hive.openBox('expenses_$uid');
      loadExpenses();
    }
    notifyListeners();
  }

  DatabaseReference? get _db => _uid != null 
      ? FirebaseDatabase.instance.ref('users/$_uid/expenses') 
      : null;

  // Load from Hive
  void loadExpenses() {
    if (_box == null) return;
    _expenses = _box!.values
        .map((e) => ExpenseModel.fromMap(Map<String, dynamic>.from(e)))
        .toList();
    _expenses.sort((a, b) => b.date.compareTo(a.date)); // Sort by newest
    notifyListeners();
  }

  // Add expense
  Future<void> addExpense(ExpenseModel expense) async {
    if (_box == null) return;
    await _box!.put(expense.id, expense.toMap());
    _expenses.insert(0, expense);
    notifyListeners();

    try {
      await _db?.child(expense.id).set(expense.toMap());
    } catch (e) {
      debugPrint('Firebase error: $e');
    }
  }

  // Update expense
  Future<void> updateExpense(ExpenseModel expense) async {
    if (_box == null) return;
    await _box!.put(expense.id, expense.toMap());
    int index = _expenses.indexWhere((e) => e.id == expense.id);
    if (index != -1) {
      _expenses[index] = expense;
      notifyListeners();
    }

    try {
      await _db?.child(expense.id).update(expense.toMap());
    } catch (e) {
      debugPrint('Firebase error: $e');
    }
  }

  // Delete expense
  Future<void> deleteExpense(String id) async {
    if (_box == null) return;
    await _box!.delete(id);
    _expenses.removeWhere((e) => e.id == id);
    notifyListeners();

    try {
      await _db?.child(id).remove();
    } catch (e) {
      debugPrint('Firebase error: $e');
    }
  }

  // Search
  List<ExpenseModel> searchExpenses(String query) {
    return _expenses
        .where((e) =>
    e.title.toLowerCase().contains(query.toLowerCase()) ||
        e.category.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}