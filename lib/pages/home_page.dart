import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expensetracker/database/expense_database.dart';
import 'package:expensetracker/models/expense.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Controllers for input fields
  TextEditingController nameController = TextEditingController();
  TextEditingController amountController = TextEditingController();

  // Firebase user
  final user = FirebaseAuth.instance.currentUser;

  // Method to show expense input dialog
  void openNewExpenseBox() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("New Expense"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(hintText: "Name"),
            ),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(hintText: "Amount"),
            ),
          ],
        ),
        actions: [
          _cancelButton(),
          _createNewExpenseButton(),
        ],
      ),
    );
  }

  // Build method using StreamBuilder to fetch expenses
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 127, 112, 228),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.of(context).pushReplacementNamed('/login');
                  },
                ),
                const SizedBox(width: 8),
                const Icon(Icons.account_circle),
                const SizedBox(width: 8),
                Text(
                  user?.email ?? 'User',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: openNewExpenseBox,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Expense>>(
        stream: ExpenseDatabase().getExpenses(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong!'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final expenses = snapshot.data ?? [];
          return ListView.builder(
            itemCount: expenses.length,
            itemBuilder: (context, index) {
              final expense = expenses[index];
              return ListTile(
                title: Text(expense.name),
                trailing: Text('\$${expense.amount.toString()}'),
              );
            },
          );
        },
      ),
    );
  }

  // Cancel button
  Widget _cancelButton() {
    return MaterialButton(
      onPressed: () {
        Navigator.pop(context);
        nameController.clear();
        amountController.clear();
      },
      child: const Text('Cancel'),
    );
  }

  // Save new expense to Firestore
  Widget _createNewExpenseButton() {
    return MaterialButton(
      onPressed: () async {
        if (nameController.text.isNotEmpty && amountController.text.isNotEmpty) {
          Navigator.pop(context);

          final newExpense = Expense(
            id: '',
            name: nameController.text,
            amount: double.parse(amountController.text),
            date: DateTime.now(),
          );

          await ExpenseDatabase().createExpense(newExpense);

          nameController.clear();
          amountController.clear();
        }
      },
      child: const Text('Save'),
    );
  }
}
