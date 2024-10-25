import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HelperFunctions {
  static Future<void> addExpense(String name, double amount) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('expenses')
          .add({
        'name': name,
        'amount': amount,
        'date': DateTime.now().millisecondsSinceEpoch,
      });
    }
  }
}
