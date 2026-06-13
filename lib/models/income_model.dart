import 'package:hive/hive.dart';

class IncomeModel {
  String id;
  String title;
  double amount;
  String source;
  DateTime date;

  IncomeModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.source,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'source': source,
      'date': date.toIso8601String(),
    };
  }

  factory IncomeModel.fromMap(Map<String, dynamic> map) {
    return IncomeModel(
      id: map['id'],
      title: map['title'],
      amount: (map['amount'] as num).toDouble(),
      source: map['source'],
      date: DateTime.parse(map['date']),
    );
  }
}
