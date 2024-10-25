import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:expensetracker/models/expense.dart';

class ExpenseDatabase {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get expenses for the current user from Firestore
  Stream<List<Expense>> getExpenses() {
    final user = FirebaseAuth.instance.currentUser;
    return _firestore
        .collection('users')
        .doc(user!.uid)
        .collection('expenses')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Expense.fromJson(doc.data(), doc.id))
            .toList());
  }

  // Create new expense in Firestore
  Future<void> createExpense(Expense expense) async {
    final user = FirebaseAuth.instance.currentUser;
    await _firestore
        .collection('users')
        .doc(user!.uid)
        .collection('expenses')
        .add(expense.toJson());
  }

  // Update existing expense in Firestore
  Future<void> updateExpense(Expense updatedExpense) async {
    final user = FirebaseAuth.instance.currentUser;
    await _firestore
        .collection('users')
        .doc(user!.uid)
        .collection('expenses')
        .doc(updatedExpense.id)
        .update(updatedExpense.toJson());
  }

  // Delete an expense from Firestore
  Future<void> deleteExpense(String expenseId) async {
    final user = FirebaseAuth.instance.currentUser;
    await _firestore
        .collection('users')
        .doc(user!.uid)
        .collection('expenses')
        .doc(expenseId)
        .delete();
  }
}
