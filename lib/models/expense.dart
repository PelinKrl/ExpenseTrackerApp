class Expense {
  String? id; // Firebase document ID
  String userId; // User ID associated with this expense
  String name;
  double amount;
  DateTime date;

  Expense({
    this.id,
    required this.userId,
    required this.name,
    required this.amount,
    required this.date,
  });

  // Convert Expense to a map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'userId': userId, // Include userId in the map
      'name': name,
      'amount': amount,
      'date': date.toIso8601String(),
    };
  }

  // Create Expense from a map (Firebase data)
  factory Expense.fromMap(Map<String, dynamic> map, String id) {
    return Expense(
      id: id,
      userId: map['userId'] as String, // Retrieve userId from the map
      name: map['name'] as String,
      amount: (map['amount'] as num).toDouble(),
      date: DateTime.parse(map['date']),
    );
  }
}
