// lib/services/auth_service.dart
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_service.dart';
import 'package:dio/dio.dart'; // Import DioError

class AuthService extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  String? _token;
  String? _userId;
  bool _isAuthenticated = false;
  bool _isLoading = true; // Start as true until initial check is done

  String? get token => _token;
  String? get userId => _userId;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading; // Getter for loading state

  AuthService() {
    _checkAuthStatus();
  }

  // Internal method to update loading state and notify listeners
  void _setLoading(bool value) {
    if (_isLoading != value) {
      _isLoading = value;
      // Use WidgetsBinding to avoid calling notifyListeners during build phase if necessary
      WidgetsBinding.instance.addPostFrameCallback((_) {
         if (hasListeners) { // Check if listeners exist before notifying
             notifyListeners();
         }
      });
    }
  }


  Future<void> _checkAuthStatus() async {
    _setLoading(true);
    try {
      _token = await _storage.read(key: 'jwt');
      _userId = await _storage.read(key: 'userId');
      // TODO: Add token validation if needed (e.g., check expiry using jwt_decoder)
      // if (_token != null) {
      //   Map<String, dynamic> decodedToken = JwtDecoder.decode(_token!);
      //   DateTime expiryDate = DateTime.fromMillisecondsSinceEpoch(decodedToken['exp'] * 1000);
      //   if (DateTime.now().isAfter(expiryDate)) {
      //      print("Token expired, logging out.");
      //      await logout(); // Logout if expired
      //      _token = null; // Ensure token is null after logout
      //   }
      // }
      _isAuthenticated = _token != null;
    } catch (e) {
       print("Error reading auth status from storage: $e");
        _isAuthenticated = false;
        _token = null;
        _userId = null;
    } finally {
       _setLoading(false);
       // Initial check might need notification if UI depends on it immediately
       // notifyListeners(); // Be careful calling notifyListeners directly in constructor/initState
    }
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    try {
      final response = await _apiService.login({'email': email, 'password': password});
      _token = response.data['token'];
      _userId = response.data['user_id'];
      await _storage.write(key: 'jwt', value: _token);
      await _storage.write(key: 'userId', value: _userId);
      _isAuthenticated = true;
      _setLoading(false);
      return true;
    } on DioError catch (e) {
      print('Login failed: ${e.response?.data ?? e.message}');
      _isAuthenticated = false;
      _setLoading(false);
      return false;
    } catch (e) {
      print('Login failed unexpectedly: $e');
       _isAuthenticated = false;
       _setLoading(false);
      return false;
    }
  }

   Future<bool> register(String username, String email, String password, String preferredLanguage) async {
     _setLoading(true);
     try {
       final response = await _apiService.register({
         'username': username,
         'email': email,
         'password': password,
         'preferred_language': preferredLanguage,
       });
       _token = response.data['token'];
       _userId = response.data['user_id'];
       await _storage.write(key: 'jwt', value: _token);
       await _storage.write(key: 'userId', value: _userId);
       _isAuthenticated = true;
       _setLoading(false);
       return true;
     } on DioError catch (e) {
       print('Registration failed: ${e.response?.data ?? e.message}');
        _isAuthenticated = false;
        _setLoading(false);
       return false;
     } catch (e) {
      print('Registration failed unexpectedly: $e');
       _isAuthenticated = false;
       _setLoading(false);
      return false;
     }
   }

  Future<void> logout() async {
    _setLoading(true);
    final currentToken = _token; // Store token before clearing
    _token = null;
    _userId = null;
    _isAuthenticated = false;
    await _storage.delete(key: 'jwt');
    await _storage.delete(key: 'userId');
    // Notify listeners immediately about local state change
    notifyListeners();

    // Attempt to invalidate token on the backend, but don't block UI
    if (currentToken != null) {
        try {
             // Manually set the Authorization header for this specific call
             // as the interceptor might not have the token anymore.
             await _apiService.logout();
              print("Server logout successful");
        } on DioError catch (e) {
             print('Logout API call failed (might be expected if token was already invalid): ${e.response?.data ?? e.message}');
        } catch (e) {
             print('Logout API call failed unexpectedly: $e');
        }
    }
    _setLoading(false); // Ensure loading is set to false after attempt
  }
}
