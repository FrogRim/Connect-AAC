import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AuthService with ChangeNotifier {
  bool _isLoggedIn = false;
  String? _userId;
  String? _username;

  bool get isLoggedIn => _isLoggedIn;
  String? get userId => _userId;
  String? get username => _username;

  final ApiService _apiService = ApiService();

  // 초기화 - 저장된 사용자 정보 확인
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('user_id');
    _username = prefs.getString('username');
    _isLoggedIn = _userId != null;
    notifyListeners();
  }

  // 회원가입
  Future<bool> register(String username, String email, String password,
      String preferredLanguage) async {
    try {
      final response = await _apiService.register(
          username, email, password, preferredLanguage);

      // 사용자 정보 저장
      _userId = response['user_id'];
      _username = response['username'];
      _isLoggedIn = true;

      // SharedPreferences에 저장
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', _userId!);
      await prefs.setString('username', _username!);

      notifyListeners();
      return true;
    } catch (e) {
      // 에러 발생시 로그인 실패 처리
      print('회원가입 오류: $e');
      return false;
    }
  }

  // 로그인
  Future<bool> login(String email, String password) async {
    try {
      final response = await _apiService.login(email, password);

      // 사용자 정보 저장
      _userId = response['user_id'];
      _username = response['username'] ??
          email.split('@')[0]; // 유저네임이 없을 경우 이메일의 아이디 부분 사용
      _isLoggedIn = true;

      // SharedPreferences에 저장
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', _userId!);
      await prefs.setString('username', _username!);

      notifyListeners();
      return true;
    } catch (e) {
      // 에러 발생시 로그인 실패 처리
      print('로그인 오류: $e');
      return false;
    }
  }

  // 로그아웃
  Future<bool> logout() async {
    try {
      await _apiService.logout();

      // 사용자 정보 초기화
      _userId = null;
      _username = null;
      _isLoggedIn = false;

      // SharedPreferences에서 삭제
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_id');
      await prefs.remove('username');

      notifyListeners();
      return true;
    } catch (e) {
      print('로그아웃 오류: $e');
      return false;
    }
  }

  // 사용자 정보 조회
  Future<Map<String, dynamic>> getUserProfile() async {
    // API 서비스를 통해 사용자 프로필 정보 조회 구현
    // 현재는 간단히 저장된 정보 반환
    return {
      'user_id': _userId,
      'username': _username,
    };
  }
}
