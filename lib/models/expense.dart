//import 'package:cloud_firestore/cloud_firestore.dart';

class Expense {
  final String id;
  final String name;
  final double amount;
  final DateTime date;

  Expense({
    required this.id,
    required this.name,
    required this.amount,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'amount': amount,
      'date': date.millisecondsSinceEpoch,
    };
  }

  static Expense fromJson(Map<String, dynamic> json, String id) {
    return Expense(
      id: id,
      name: json['name'],
      amount: json['amount'],
      date: DateTime.fromMillisecondsSinceEpoch(json['date']),
    );
  }
}
