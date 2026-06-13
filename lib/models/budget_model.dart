class BudgetModel {
  String id;
  String category;
  double limit;
  double spent;
  String month;

  BudgetModel({
    required this.id,
    required this.category,
    required this.limit,
    required this.spent,
    required this.month,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'limit': limit,
      'spent': spent,
      'month': month,
    };
  }

  factory BudgetModel.fromMap(Map<String, dynamic> map) {
    return BudgetModel(
      id: map['id'],
      category: map['category'],
      limit: map['limit'].toDouble(),
      spent: map['spent'].toDouble(),
      month: map['month'],
    );
  }
}