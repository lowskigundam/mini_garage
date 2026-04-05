import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _auth = AuthService();

  final emailController = TextEditingController();

  final passwordController = TextEditingController();

  bool isLogin = true;

  void handleAuth() async {
    try {
      if (isLogin) {
        await _auth.signIn(
          emailController.text.trim(),
          passwordController.text.trim(),
        );
      } else {
        await _auth.signUp(
          emailController.text.trim(),
          passwordController.text.trim(),
        );
      }
    } catch (e) {
      print("Auth error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isLogin ? "Login" : "Sign Up")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: handleAuth,
              child: Text(isLogin ? "Login" : "Sign Up"),
            ),

            TextButton(
              onPressed: () {
                setState(() {
                  isLogin = !isLogin;
                });
              },
              child: Text(isLogin ? "Create account" : "Already have account"),
            ),
          ],
        ),
      ),
    );
  }
}
