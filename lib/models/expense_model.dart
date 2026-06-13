import 'package:hive/hive.dart';

class ExpenseModel {
  String id;
  String title;
  double amount;
  String category;
  String paymentMethod;
  String description;
  DateTime date;

  ExpenseModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.paymentMethod,
    required this.description,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category': category,
      'paymentMethod': paymentMethod,
      'description': description,
      'date': date.toIso8601String(),
    };
  }

  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      category: map['category'],
      paymentMethod: map['paymentMethod'],
      description: map['description'],
      date: DateTime.parse(map['date']),
    );
  }
}