import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:expensetracker/models/expense.dart';

class ExpenseDatabase extends ChangeNotifier {
  // Firestore reference for the current user's expenses
  CollectionReference? _expenseCollection;
  String? userId; // Add userId property

  // List to hold all expenses fetched from Firestore
  List<Expense> _allExpenses = [];

  // Getter for all expenses
  List<Expense> get allExpenses => _allExpenses;

  // Initialize function to set up the user's collection reference and load expenses
 Future<void> initialize(String userId) async {
  this.userId = userId; // Store userId for later use
  try {
    // Update the Firestore reference to include the user ID
    _expenseCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('expenses');

    _expenseCollection!.snapshots().listen((snapshot) {
      _allExpenses = snapshot.docs
          .map((doc) => Expense.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
      notifyListeners(); // Notify listeners to update UI
    });
  } catch (e) {
    print('Failed to initialize: $e');
  }
}

  // Add a new expense to Firestore
  Future<void> addExpense(Expense expense) async {
    try {
      await _expenseCollection?.add(expense.toMap());
      await readExpenses();
    } catch (e) {
      print("Failed to add expense: $e");
    }
  }

  // Read - fetch expenses from Firestore
  Future<void> readExpenses() async {
  try {
    QuerySnapshot snapshot = await _expenseCollection!.get();
    
    // Check if the snapshot is empty
    if (snapshot.docs.isEmpty) {
      _allExpenses.clear(); // Clear the list if no documents are found
    } else {
      List<Expense> fetchedExpenses = snapshot.docs.map((doc) {
        return Expense.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();

      _allExpenses.clear();
      _allExpenses.addAll(fetchedExpenses);
    }
    
    notifyListeners();
  } catch (e) {
    print("Failed to fetch expenses: $e");
  }
}


  // Update an existing expense in Firestore
  Future<void> updateExpense(Expense expense) async {
    try {
      if (expense.id != null) {
        await _expenseCollection?.doc(expense.id).update(expense.toMap());
        await readExpenses();
      }
    } catch (e) {
      print("Failed to update expense: $e");
    }
  }

  // Delete an expense from Firestore
  Future<void> deleteExpense(String expenseId) async {
    try {
      await _expenseCollection?.doc(expenseId).delete();
      await readExpenses();
    } catch (e) {
      print("Failed to delete expense: $e");
    }
  }

  // Helper functions

  Future<Map<String, double>> calculateMonthlyTotals() async {
    await readExpenses();

    Map<String, double> monthlyTotals = {};

    for (var expense in _allExpenses) {
      String yearMonth = '${expense.date.year}-${expense.date.month}';

      if (!monthlyTotals.containsKey(yearMonth)) {
        monthlyTotals[yearMonth] = 0;
      }

      monthlyTotals[yearMonth] = monthlyTotals[yearMonth]! + expense.amount;
    }
    return monthlyTotals;
  }

  Future<double> calculateCurrentMonthTotal() async {
    int currentMonth = DateTime.now().month;
    int currentYear = DateTime.now().year;

    List<Expense> currentMonthExpenses = _allExpenses.where((expense) {
      return expense.date.month == currentMonth && expense.date.year == currentYear;
    }).toList();

    double total = currentMonthExpenses.fold(0, (sum, expense) => sum + expense.amount);
    return total;
  }

  int getStartMonth() {
    if (_allExpenses.isEmpty) {
      return DateTime.now().month;
    }

    _allExpenses.sort((a, b) => a.date.compareTo(b.date));
    return _allExpenses.first.date.month;
  }

  int getStartYear() {
    if (_allExpenses.isEmpty) {
      return DateTime.now().year;
    }

    _allExpenses.sort((a, b) => a.date.compareTo(b.date));
    return _allExpenses.first.date.year;
  }
}
