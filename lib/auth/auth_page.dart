import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../pages/home_page.dart'; // Import HomePage
import '../pages/login_page.dart';
import '../pages/register_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool showLoginPage = true;

  void toggleScreens() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Check if the authentication state is being retrieved
        if (snapshot.connectionState == ConnectionState.active) {
          User? user = snapshot.data;
          // If user is signed in, go to HomePage
          if (user != null) {
            return HomePage();
          }
          // If user is not signed in, show login or register page based on `showLoginPage` state
          else {
            return showLoginPage
                ? LoginPage(showRegisterPage: toggleScreens)
                : RegisterPage(showLoginPage: toggleScreens);
          }
        }
        // Loading state
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
