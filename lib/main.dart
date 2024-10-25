import 'package:expensetracker/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:expensetracker/auth/main_page.dart';
import 'package:provider/provider.dart';
import 'package:expensetracker/database/expense_service.dart'; // Update this to your new Firebase service

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    ChangeNotifierProvider(
      create: (context) => ExpenseService(), // Assuming you'll create this service for Firebase data handling
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainPage(), // Your authentication logic
    );
  }
}
