import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:expensetracker/models/expense.dart';
import 'package:expensetracker/database/expense_database.dart';
import 'package:flutter/foundation.dart';

class ExpenseService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Expense> _expenses = [];

  List<Expense> get expenses => _expenses;

  // Fetch expenses from Firebase Firestore
  Future<void> fetchExpenses() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('expenses')
          .get();

      _expenses = snapshot.docs
          .map((doc) => Expense.fromJson(doc.data(), doc.id))
          .toList();

      // Notify listeners to update the UI
      notifyListeners();
    }
  }

  // Add new expense
  Future<void> addExpense(Expense expense) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('expenses')
          .add(expense.toJson());

      // Fetch and update the list of expenses after adding a new one
      await fetchExpenses();
    }
  }
}