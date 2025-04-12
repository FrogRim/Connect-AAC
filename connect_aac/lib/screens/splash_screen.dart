// lib/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:connect_aac/services/auth_service.dart';
import 'package:connect_aac/screens/home_screen.dart';
import 'package:connect_aac/screens/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Use addPostFrameCallback to ensure context is available and AuthService is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authService = Provider.of<AuthService>(context, listen: false);

      // Wait until the initial loading state of AuthService is false
      // This loop ensures we wait for the _checkAuthStatus in AuthService constructor
      while (authService.isLoading) {
          await Future.delayed(const Duration(milliseconds: 50));
          // Break loop if widget is disposed while waiting
          if (!mounted) return;
      }

      if (mounted) { // Check again if widget is still mounted
        if (authService.isAuthenticated) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show a loading indicator while checking auth status
    return const Scaffold(
      body: Center(
        // TODO: Add a nicer splash screen logo/graphic if desired
        child: CircularProgressIndicator(),
      ),
    );
  }
}
