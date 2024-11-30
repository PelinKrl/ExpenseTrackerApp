import 'package:expensetracker/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:expensetracker/auth/main_page.dart';
import 'package:provider/provider.dart';
import 'package:expensetracker/database/expense_db.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        // Listen to authentication state changes
        StreamProvider<User?>.value(
          value: FirebaseAuth.instance.authStateChanges(),
          initialData: null,
        ),
        ChangeNotifierProvider(
          create: (context) => ExpenseDatabase(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);

    // Reinitialize data for user-specific expenses
    if (user != null) {
      Provider.of<ExpenseDatabase>(context, listen: false).initialize(user.uid);
    }

    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainPage(),
    );
  }
}
