import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/income_model.dart';

class IncomeProvider extends ChangeNotifier {
  String? _uid;
  Box? _box;
  List<IncomeModel> _incomeList = [];

  List<IncomeModel> get incomeList => _incomeList;

  double get totalIncome =>
      _incomeList.fold(0.0, (sum, item) => sum + item.amount);

  // Set UID and initialize box
  Future<void> setUid(String? uid) async {
    if (_uid == uid) return;
    _uid = uid;

    if (uid == null) {
      _incomeList = [];
      _box = null;
    } else {
      _box = await Hive.openBox('income_$uid');
      loadIncome();
    }
    notifyListeners();
  }

  DatabaseReference? get _db => _uid != null
      ? FirebaseDatabase.instance.ref('users/$_uid/income')
      : null;

  // Load from Hive
  void loadIncome() {
    if (_box == null) return;
    _incomeList = _box!.values
        .map((e) => IncomeModel.fromMap(Map<String, dynamic>.from(e)))
        .toList();
    _incomeList.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

  // Add income
  Future<void> addIncome(IncomeModel income) async {
    if (_box == null) return;
    await _box!.put(income.id, income.toMap());
    _incomeList.insert(0, income);
    notifyListeners();

    try {
      await _db?.child(income.id).set(income.toMap());
    } catch (e) {
      debugPrint('Firebase error: $e');
    }
  }

  // Update income
  Future<void> updateIncome(IncomeModel income) async {
    if (_box == null) return;
    await _box!.put(income.id, income.toMap());
    int index = _incomeList.indexWhere((e) => e.id == income.id);
    if (index != -1) {
      _incomeList[index] = income;
      notifyListeners();
    }

    try {
      await _db?.child(income.id).update(income.toMap());
    } catch (e) {
      debugPrint('Firebase error: $e');
    }
  }

  // Delete income
  Future<void> deleteIncome(String id) async {
    if (_box == null) return;
    await _box!.delete(id);
    _incomeList.removeWhere((e) => e.id == id);
    notifyListeners();

    try {
      await _db?.child(id).remove();
    } catch (e) {
      debugPrint('Firebase error: $e');
    }
  }
}
