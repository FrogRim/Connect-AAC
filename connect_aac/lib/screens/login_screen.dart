// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:connect_aac/services/auth_service.dart';
import 'package:connect_aac/screens/home_screen.dart';
import 'package:connect_aac/screens/register_screen.dart'; // Import RegisterScreen

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _login(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final authService = Provider.of<AuthService>(context, listen: false);
      final success = await authService.login(
        _emailController.text.trim(), // Trim input
        _passwordController.text, // Don't trim password
      );

      if (success && mounted) { // Check if mounted before navigating
         // Navigate to HomeScreen on successful login
         Navigator.pushAndRemoveUntil( // Use pushAndRemoveUntil to clear the stack
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
            (Route<dynamic> route) => false, // Remove all routes below
         );
      } else if (mounted) { // Check if mounted before showing SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('로그인 실패. 이메일 또는 비밀번호를 확인하세요.')),
        );
      }
    }
  }

   @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Access the loading state from AuthService to disable buttons/show indicator
    final isLoading = Provider.of<AuthService>(context).isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('로그인')),
      body: Center( // Center the form vertically
        child: SingleChildScrollView( // Allow scrolling if content overflows
           padding: const EdgeInsets.all(24.0), // Add more padding
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch, // Make buttons stretch
              children: [
                 // Optional: Add Logo/Title
                 Text(
                    'Connect AAC',
                     style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                       fontWeight: FontWeight.bold,
                       color: Theme.of(context).colorScheme.primary,
                     ),
                     textAlign: TextAlign.center,
                 ),
                 const SizedBox(height: 32),

                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: '이메일', prefixIcon: Icon(Icons.email)),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next, // Move focus to password
                  validator: (value) {
                    if (value == null || value.trim().isEmpty || !value.contains('@')) {
                      return '유효한 이메일을 입력하세요.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: '비밀번호', prefixIcon: Icon(Icons.lock)),
                  obscureText: true,
                  textInputAction: TextInputAction.done, // Submit form on done
                   onFieldSubmitted: (_) { // Allow login on keyboard done
                      if (!isLoading) _login(context);
                   },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '비밀번호를 입력하세요.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                // Show CircularProgressIndicator inside the button when loading
                ElevatedButton(
                   style: ElevatedButton.styleFrom(
                       padding: const EdgeInsets.symmetric(vertical: 16), // Increase button height
                   ),
                   onPressed: isLoading ? null : () => _login(context),
                   child: isLoading
                       ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                                strokeWidth: 3, color: Colors.white))
                       : const Text('로그인'),
                 ),
                 const SizedBox(height: 16),
                  TextButton(
                    onPressed: isLoading ? null : () { // Disable button when loading
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RegisterScreen()), // Navigate to RegisterScreen
                      );
                    },
                    child: const Text('계정이 없으신가요? 회원가입'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
