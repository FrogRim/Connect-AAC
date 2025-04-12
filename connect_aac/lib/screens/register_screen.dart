// lib/screens/register_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:connect_aac/services/auth_service.dart';
import 'package:connect_aac/screens/home_screen.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String _preferredLanguage = 'ko'; // Default language ('ko', 'en', etc.)

  // List of available languages - adjust based on your app's support
  final List<Map<String, String>> _languages = [
    {'code': 'ko', 'name': '한국어'},
    {'code': 'en', 'name': 'English'},
    // Add other languages as needed
  ];

  Future<void> _register(BuildContext context) async {
    // Validate the form first
    if (!_formKey.currentState!.validate()) {
      return; // Stop if form is not valid
    }

    // Password match validation is handled by the validator, but double check is safe
    if (_passwordController.text != _confirmPasswordController.text) {
        // This should ideally not be reached if validator is working
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('비밀번호가 일치하지 않습니다.')),
        );
        return;
    }

    final authService = Provider.of<AuthService>(context, listen: false);
    final success = await authService.register(
      _usernameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text, // Don't trim password
      _preferredLanguage,
    );

    if (success && mounted) {
      // Navigate to HomeScreen on successful registration
      Navigator.pushAndRemoveUntil( // Use pushAndRemoveUntil to clear the stack
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
        (Route<dynamic> route) => false, // Remove all routes below
      );
    } else if (mounted) {
      // Provide more specific feedback if the API gives error details
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('회원가입 실패. 사용자 이름 또는 이메일이 이미 사용 중일 수 있습니다.')),
      );
    }
  }

   @override
  void dispose() {
    // Dispose controllers when the widget is removed from the widget tree
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
     // Listen to loading state to disable inputs/button
     final isLoading = Provider.of<AuthService>(context).isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('회원가입')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView( // Use ListView for scrolling if form gets long
            children: [
              TextFormField(
                controller: _usernameController,
                enabled: !isLoading, // Disable when loading
                decoration: const InputDecoration(labelText: '사용자 이름', prefixIcon: Icon(Icons.person)),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '사용자 이름을 입력하세요.';
                  }
                  if (value.trim().length < 3) {
                      return '사용자 이름은 3자 이상이어야 합니다.';
                  }
                  return null;
                },
              ),
               const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                enabled: !isLoading,
                decoration: const InputDecoration(labelText: '이메일', prefixIcon: Icon(Icons.email)),
                keyboardType: TextInputType.emailAddress,
                 textInputAction: TextInputAction.next,
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
                enabled: !isLoading,
                decoration: const InputDecoration(labelText: '비밀번호', prefixIcon: Icon(Icons.lock_outline)),
                obscureText: true,
                 textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '비밀번호를 입력하세요.';
                  }
                  if (value.length < 6) { // Example: Minimum length validation
                      return '비밀번호는 6자 이상이어야 합니다.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                  controller: _confirmPasswordController,
                  enabled: !isLoading,
                  decoration: const InputDecoration(labelText: '비밀번호 확인', prefixIcon: Icon(Icons.lock)),
                  obscureText: true,
                   textInputAction: TextInputAction.next, // Change to next if language dropdown is after
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '비밀번호 확인을 입력하세요.';
                    }
                    if (value != _passwordController.text) {
                      return '비밀번호가 일치하지 않습니다.';
                    }
                    return null;
                },
              ),
              const SizedBox(height: 16),
               // Language Selection Dropdown
               DropdownButtonFormField<String>(
                 value: _preferredLanguage,
                 // Disable dropdown when loading
                 // Note: DropdownButtonFormField doesn't have a direct 'enabled' property.
                 // Wrap with IgnorePointer or handle within onChanged. A simple way is to
                 // return null from onChanged when isLoading is true.
                 decoration: const InputDecoration(labelText: '선호 언어', prefixIcon: Icon(Icons.language)),
                 items: _languages.map((lang) {
                   return DropdownMenuItem<String>(
                     value: lang['code'],
                     child: Text(lang['name']!),
                   );
                 }).toList(),
                 onChanged: isLoading ? null : (value) { // Disable onChanged when loading
                   if (value != null) {
                     setState(() {
                       _preferredLanguage = value;
                     });
                   }
                 },
                 validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '선호 언어를 선택하세요.';
                    }
                    return null;
                 },
               ),
              const SizedBox(height: 32), // More spacing before button
               ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  // Disable button while loading
                  onPressed: isLoading ? null : () => _register(context),
                  child: isLoading
                     ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white))
                     : const Text('회원가입'),
               ),
              const SizedBox(height: 16),
               // Option to go back to login
                TextButton(
                    // Disable button when loading
                    onPressed: isLoading ? null : () => Navigator.pop(context), // Go back
                    child: const Text('이미 계정이 있으신가요? 로그인'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
