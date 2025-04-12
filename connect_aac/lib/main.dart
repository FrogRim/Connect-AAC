// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:connect_aac/providers/vocabulary_provider.dart';
import 'package:connect_aac/providers/favorites_provider.dart';
import 'package:connect_aac/providers/settings_provider.dart';
import 'package:connect_aac/providers/chat_provider.dart';
import 'package:connect_aac/services/auth_service.dart'; // Import AuthService
import 'package:connect_aac/services/api_service.dart'; // Import ApiService
import 'package:connect_aac/utils/app_theme.dart';
import 'package:connect_aac/screens/splash_screen.dart';

void main() {
  // Ensure Flutter bindings are initialized (good practice)
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ConnectAACApp());
}

class ConnectAACApp extends StatelessWidget {
  const ConnectAACApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Create ApiService instance once
    final apiService = ApiService();

    return MultiProvider(
      providers: [
        // Provide ApiService itself if needed by multiple providers/widgets
        Provider<ApiService>.value(value: apiService),

        // ChangeNotifierProvider for Authentication
        ChangeNotifierProvider(create: (_) => AuthService()), // AuthService uses its own ApiService instance

        // Other providers that depend on ApiService
        // Use the ApiService instance created above
        ChangeNotifierProvider(create: (_) => VocabularyProvider(apiService)),
        ChangeNotifierProvider(create: (_) => FavoritesProvider(apiService)),
        ChangeNotifierProvider(create: (_) => SettingsProvider(apiService)),
        ChangeNotifierProvider(create: (_) => ChatProvider(apiService)),
        // Add other providers if necessary, providing ApiService if needed
      ],
      child: Consumer<SettingsProvider>( // Consume SettingsProvider for theme
        builder: (context, settingsProvider, child) {
          return MaterialApp(
            title: 'Connect AAC',
            theme: AppTheme.lightTheme, // Use light theme from AppTheme
            darkTheme: AppTheme.darkTheme, // Use dark theme from AppTheme
            themeMode: settingsProvider.themeMode, // Control theme mode via SettingsProvider
            home: const SplashScreen(), // Start with SplashScreen
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
