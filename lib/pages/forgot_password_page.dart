import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:expensetracker/pages/custom_textfield.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPaState();
}

class _ForgotPaState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future passwordReset() async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _emailController.text.trim());
      showDialog(
          context: context,
          builder: (context) {
            return const AlertDialog(
              content: Text('Password reset link sent ! Check your email'),
            );
          });
    } on FirebaseAuthException catch (e) {
      print(e);
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text(e.message.toString()),
            );
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple[200],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 200,
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 25.0),
              child: Text(
                'Enter Your Email and we will send you a password reset link',
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            //e mail text field

            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: TextField(
                    controller: _emailController,
                    decoration: customInputDecoration('Email'))),

            const SizedBox(
              height: 10,
            ),

            //Reset Button

            MaterialButton(
              onPressed: passwordReset,
              child: Text('Reset Password'),
              color: Colors.deepPurple[200],
            )
          ],
        ),
      ),
    );
  }
}


//  InputDecoration(
//                     enabledBorder: OutlineInputBorder(
//                       borderSide: const BorderSide(color: Colors.white),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderSide: const BorderSide(color: Colors.deepPurple),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     hintText: 'Email',
//                     fillColor: Colors.grey[200],
//                     filled: true,
//                   ),