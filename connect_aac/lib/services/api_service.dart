// lib/services/api_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/category.dart';
import '../models/vocabulary_item.dart';
import '../models/chat_message.dart';

class ApiService {
  // API 기본 URL (실제 서버 주소로 변경 필요)
  static const String baseUrl = 'http://localhost:5000/api/v1';

  // 토큰 저장 키
  static const String tokenKey = 'auth_token';

  // HTTP 헤더 생성 함수
  Future<Map<String, String>> _getHeaders({bool requiresAuth = true}) async {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    if (requiresAuth) {
      final token = await _getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // 토큰 가져오기
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  // 토큰 저장
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
  }

  // 토큰 삭제
  Future<void> _deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
  }

  // 에러 처리
  Exception _handleError(http.Response response) {
    switch (response.statusCode) {
      case 400:
        return Exception('잘못된 요청입니다. (400)');
      case 401:
        return Exception('인증이 필요합니다. (401)');
      case 403:
        return Exception('접근 권한이 없습니다. (403)');
      case 404:
        return Exception('요청한 리소스를 찾을 수 없습니다. (404)');
      case 500:
        return Exception('서버 오류가 발생했습니다. (500)');
      default:
        return Exception('오류가 발생했습니다. 상태 코드: ${response.statusCode}');
    }
  }

  // 회원가입 API
  Future<Map<String, dynamic>> register(String username, String email,
      String password, String preferredLanguage) async {
    final url = Uri.parse('$baseUrl/auth/register');
    final response = await http.post(
      url,
      headers: await _getHeaders(requiresAuth: false),
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
        'preferred_language': preferredLanguage,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      if (data['token'] != null) {
        await _saveToken(data['token']);
      }
      return data;
    } else {
      throw _handleError(response);
    }
  }

  // 로그인 API
  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/auth/login');
    final response = await http.post(
      url,
      headers: await _getHeaders(requiresAuth: false),
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['token'] != null) {
        await _saveToken(data['token']);
      }
      return data;
    } else {
      throw _handleError(response);
    }
  }

  // 로그아웃 API
  Future<bool> logout() async {
    final url = Uri.parse('$baseUrl/auth/logout');
    final response = await http.post(
      url,
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      await _deleteToken();
      return true;
    } else {
      throw _handleError(response);
    }
  }

  // 카테고리 목록 조회 API
  Future<List<Category>> getCategories() async {
    final url = Uri.parse('$baseUrl/categories');
    final response = await http.get(
      url,
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<Category> categories = [];

      for (var item in data['categories']) {
        categories.add(Category.fromJson(item));
      }

      return categories;
    } else {
      throw _handleError(response);
    }
  }

  // 특정 카테고리의 어휘 항목 조회 API
  Future<List<VocabularyItem>> getVocabularyByCategory(
      String categoryId) async {
    final url = Uri.parse('$baseUrl/categories/$categoryId/vocabulary');
    final response = await http.get(
      url,
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<VocabularyItem> items = [];

      for (var item in data['items']) {
        items.add(VocabularyItem.fromJson(item));
      }

      return items;
    } else {
      throw _handleError(response);
    }
  }

  // 어휘 검색 API
  Future<List<VocabularyItem>> searchVocabulary(String query,
      {String? categoryId}) async {
    final queryParams = {'query': query};

    if (categoryId != null) {
      queryParams['category_id'] = categoryId;
    }

    final url = Uri.parse('$baseUrl/vocabulary/search')
        .replace(queryParameters: queryParams);
    final response = await http.get(
      url,
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<VocabularyItem> items = [];

      for (var item in data['items']) {
        items.add(VocabularyItem.fromJson(item));
      }

      return items;
    } else {
      throw _handleError(response);
    }
  }

  // 즐겨찾기 목록 조회 API
  Future<List<VocabularyItem>> getFavorites() async {
    final url = Uri.parse('$baseUrl/favorites');
    final response = await http.get(
      url,
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<VocabularyItem> items = [];

      for (var item in data['favorites']) {
        // API에서 반환된 데이터를 VocabularyItem으로 변환
        items.add(VocabularyItem(
          id: item['item_id'],
          text: item['text'],
          imageAsset: item['image_path'],
          categoryId: item['category_id'],
        ));
      }

      return items;
    } else {
      throw _handleError(response);
    }
  }

  // 즐겨찾기 추가 API
  Future<Map<String, dynamic>> addFavorite(String itemId) async {
    final url = Uri.parse('$baseUrl/favorites');
    final response = await http.post(
      url,
      headers: await _getHeaders(),
      body: jsonEncode({
        'item_id': itemId,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw _handleError(response);
    }
  }

  // 즐겨찾기 삭제 API
  Future<bool> removeFavorite(String favoriteId) async {
    final url = Uri.parse('$baseUrl/favorites/$favoriteId');
    final response = await http.delete(
      url,
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw _handleError(response);
    }
  }

  // 즐겨찾기 전체 삭제 API
  Future<bool> clearFavorites() async {
    final url = Uri.parse('$baseUrl/favorites');
    final response = await http.delete(
      url,
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw _handleError(response);
    }
  }

  // 설정 조회 API
  Future<Map<String, dynamic>> getSettings() async {
    final url = Uri.parse('$baseUrl/settings');
    final response = await http.get(
      url,
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw _handleError(response);
    }
  }

  // 설정 저장 API
  Future<Map<String, dynamic>> saveSettings(
      Map<String, dynamic> settings) async {
    final url = Uri.parse('$baseUrl/settings');
    final response = await http.put(
      url,
      headers: await _getHeaders(),
      body: jsonEncode(settings),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw _handleError(response);
    }
  }

  // 메시지 기록 조회 API
  Future<List<ChatMessage>> getChatMessages(
      {int limit = 20, int offset = 0}) async {
    final url = Uri.parse('$baseUrl/chat/messages').replace(queryParameters: {
      'limit': limit.toString(),
      'offset': offset.toString()
    });
    final response = await http.get(
      url,
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<ChatMessage> messages = [];

      for (var item in data['messages']) {
        messages.add(ChatMessage(
          id: item['message_id'],
          text: item['content'],
          timestamp: DateTime.parse(item['created_at']),
          isUser: !item['is_ai'],
        ));
      }

      return messages;
    } else {
      throw _handleError(response);
    }
  }

  // 메시지 전송 API (AI 응답 포함)
  Future<Map<String, dynamic>> sendChatMessage(String content,
      {String messageType = 'text'}) async {
    final url = Uri.parse('$baseUrl/chat/messages');
    final response = await http.post(
      url,
      headers: await _getHeaders(),
      body: jsonEncode({
        'content': content,
        'message_type': messageType,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw _handleError(response);
    }
  }

  // 최근 사용 기록 조회 API
  Future<List<Map<String, dynamic>>> getRecentUsage({int limit = 10}) async {
    final url = Uri.parse('$baseUrl/recent-usage')
        .replace(queryParameters: {'limit': limit.toString()});
    final response = await http.get(
      url,
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['items']);
    } else {
      throw _handleError(response);
    }
  }

  // 사용 기록 추가 API
  Future<Map<String, dynamic>> addUsageRecord(String itemId) async {
    final url = Uri.parse('$baseUrl/recent-usage');
    final response = await http.post(
      url,
      headers: await _getHeaders(),
      body: jsonEncode({
        'item_id': itemId,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw _handleError(response);
    }
  }

  // 이미지 업로드 API
  Future<String> uploadImage(File imageFile, String type) async {
    final url = Uri.parse('$baseUrl/upload/image');

    // multipart/form-data 요청 생성
    var request = http.MultipartRequest('POST', url);

    // 헤더 추가
    final token = await _getToken();
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    // 파일 추가
    request.files.add(await http.MultipartFile.fromPath(
      'image',
      imageFile.path,
    ));

    // 타입 추가
    request.fields['type'] = type;

    // 요청 전송 및 응답 처리
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data['image_path'];
    } else {
      throw _handleError(response);
    }
  }

  // TTS 합성 API (바이너리 데이터 반환)
  Future<List<int>> synthesizeSpeech(String text,
      {String? voiceType, double? speechRate}) async {
    final url = Uri.parse('$baseUrl/tts/synthesize');

    final requestBody = {
      'text': text,
    };

    if (voiceType != null) {
      requestBody['voice_type'] = voiceType;
    }

    if (speechRate != null) {
      requestBody['speech_rate'] = speechRate.toString();
    }

    final response = await http.post(
      url,
      headers: await _getHeaders(),
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw _handleError(response);
    }
  }
}
