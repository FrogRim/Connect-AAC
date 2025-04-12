// lib/services/api_service.dart
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart'; // For MultipartFile

class ApiService {
  final Dio _dio;
  final FlutterSecureStorage _storage;
  // TODO: Replace with your actual backend URL (use localhost for local dev)
  static const String _baseUrl = 'http://localhost:5000/api/v1'; // Example: Local backend URL
  // static const String _baseUrl = 'https://api.connectaac.com/v1'; // Example: Production URL

  ApiService()
      : _dio = Dio(BaseOptions(baseUrl: _baseUrl)),
        _storage = const FlutterSecureStorage() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'jwt');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        // Log request details for debugging (optional)
        // print('--> ${options.method} ${options.path}');
        // print('Headers: ${options.headers}');
        // print('Data: ${options.data}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        // Log response details for debugging (optional)
        // print('<-- ${response.statusCode} ${response.requestOptions.method} ${response.requestOptions.path}');
        // print('Response: ${response.data}');
        return handler.next(response);
      },
      onError: (DioError e, handler) {
        // Log error details for debugging (optional)
        print('[Error] ${e.requestOptions.method} ${e.requestOptions.path}: ${e.message}');
        if (e.response != null) {
          print('Error Response Status: ${e.response?.statusCode}');
          print('Error Response Data: ${e.response?.data}');
        }
        // Handle 401 Unauthorized errors (e.g., navigate to login)
        if (e.response?.statusCode == 401) {
          // Potentially clear token and navigate to login screen
          // Consider using a global navigator key or passing context if needed
          print('Authentication Error: Token might be invalid or expired.');
          // Example: AuthService could listen for 401s or have a callback
        }
        return handler.next(e); // Important to pass the error along
      },
    ));
  }

  // --- Helper to get token ---
  Future<String?> _getToken() async {
    return await _storage.read(key: 'jwt');
  }

  // --- Authentication ---
  Future<Response> register(Map<String, dynamic> data) => _dio.post('/auth/register', data: data);
  Future<Response> login(Map<String, dynamic> data) => _dio.post('/auth/login', data: data);
  Future<Response> logout() => _dio.post('/auth/logout'); // Token added via interceptor
  Future<Response> getUserProfile() => _dio.get('/users/profile'); // Token added via interceptor
  Future<Response> updateUserProfile(Map<String, dynamic> data) => _dio.put('/users/profile', data: data); // Token added via interceptor
  Future<Response> changePassword(Map<String, dynamic> data) => _dio.put('/users/password', data: data); // Token added via interceptor

  // --- Categories ---
  Future<Response> getCategories() => _dio.get('/categories'); // Token added via interceptor
  Future<Response> getCategory(String categoryId) => _dio.get('/categories/$categoryId'); // Token added via interceptor

  // --- Vocabulary Items ---
  Future<Response> getVocabularyItems({String? categoryId}) => _dio.get('/vocabulary', queryParameters: categoryId != null ? {'category_id': categoryId} : null); // Token added via interceptor
  Future<Response> getVocabularyByCategory(String categoryId) => _dio.get('/categories/$categoryId/vocabulary'); // Token added via interceptor
  Future<Response> getVocabularyItem(String itemId) => _dio.get('/vocabulary/$itemId'); // Token added via interceptor
  Future<Response> searchVocabulary({required String query, String? categoryId}) {
    final params = {'query': query};
    if (categoryId != null) {
      params['category_id'] = categoryId;
    }
    return _dio.get('/vocabulary/search', queryParameters: params); // Token added via interceptor
  }

  // --- Favorites ---
  Future<Response> getFavorites() => _dio.get('/favorites'); // Token added via interceptor
  Future<Response> addFavorite(String itemId) => _dio.post('/favorites', data: {'item_id': itemId}); // Token added via interceptor
  Future<Response> deleteFavorite(String favoriteId) => _dio.delete('/favorites/$favoriteId'); // Token added via interceptor
  Future<Response> updateFavoriteOrder(List<Map<String, dynamic>> favoritesOrder) => _dio.put('/favorites/order', data: {'favorites': favoritesOrder}); // Token added via interceptor

  // --- Settings ---
  Future<Response> getSettings() => _dio.get('/settings'); // Token added via interceptor
  Future<Response> saveSettings(Map<String, dynamic> data) => _dio.put('/settings', data: data); // Token added via interceptor

  // --- Chat ---
  Future<Response> getChatMessages({int? limit, int? offset}) => _dio.get('/chat/messages', queryParameters: {'limit': limit, 'offset': offset}); // Token added via interceptor
  Future<Response> sendChatMessage(Map<String, dynamic> data) => _dio.post('/chat/messages', data: data); // Token added via interceptor
  Future<Response> deleteChatMessages() => _dio.delete('/chat/messages'); // Token added via interceptor

  // --- Recent Usage ---
  Future<Response> getRecentUsage({int? limit}) => _dio.get('/recent-usage', queryParameters: {'limit': limit}); // Token added via interceptor
  Future<Response> addRecentUsage(String itemId) => _dio.post('/recent-usage', data: {'item_id': itemId}); // Token added via interceptor
  Future<Response> deleteRecentUsageItem(String itemId) => _dio.delete('/recent-usage/$itemId'); // Token added via interceptor
  Future<Response> deleteAllRecentUsage() => _dio.delete('/recent-usage'); // Token added via interceptor

  // --- Custom Vocabulary ---
  Future<Response> getCustomVocabulary({String? categoryId}) => _dio.get('/custom-vocabulary', queryParameters: categoryId != null ? {'category_id': categoryId} : null); // Token added via interceptor
  Future<Response> getCustomVocabularyItem(String customId) => _dio.get('/custom-vocabulary/$customId'); // Token added via interceptor
  Future<Response> createCustomVocabulary({required String text, required String categoryId, XFile? imageFile}) async {
      FormData formData = FormData.fromMap({
        'text': text,
        'category_id': categoryId,
        if (imageFile != null)
          'image': await MultipartFile.fromFile(
            imageFile.path,
            filename: imageFile.name, // Ensure filename is provided
          ),
      });
      // Token is added by interceptor, Content-Type is set automatically by Dio for FormData
      return _dio.post('/custom-vocabulary', data: formData);
  }
  Future<Response> updateCustomVocabulary({required String customId, required String text, required String categoryId, XFile? imageFile}) async {
      FormData formData = FormData.fromMap({
        'text': text,
        'category_id': categoryId,
        if (imageFile != null)
          'image': await MultipartFile.fromFile(
            imageFile.path,
            filename: imageFile.name,
          ),
      });
       // Token is added by interceptor, Content-Type is set automatically
       return _dio.put('/custom-vocabulary/$customId', data: formData);
  }
  Future<Response> deleteCustomVocabulary(String customId) => _dio.delete('/custom-vocabulary/$customId'); // Token added via interceptor

  // --- Image Upload (Dedicated Endpoint, API 9.1) ---
  Future<Response> uploadImage(XFile imageFile, String type) async {
      FormData formData = FormData.fromMap({
        'type': type, // e.g., 'custom_vocabulary', 'profile'
        'image': await MultipartFile.fromFile(
            imageFile.path,
            filename: imageFile.name,
          ),
      });
       // Token is added by interceptor, Content-Type is set automatically
       return _dio.post('/upload/image', data: formData);
  }

  // --- TTS ---
  Future<Response> synthesizeTTS(Map<String, dynamic> data) => _dio.post('/tts/synthesize', data: data, options: Options(responseType: ResponseType.bytes)); // Expecting binary data, Token added via interceptor
  Future<Response> getTTSVoices() => _dio.get('/tts/voices'); // Token added via interceptor

  // --- Statistics ---
  Future<Response> getUsageStatistics({String? period}) => _dio.get('/statistics/usage', queryParameters: {'period': period}); // Token added via interceptor
}
