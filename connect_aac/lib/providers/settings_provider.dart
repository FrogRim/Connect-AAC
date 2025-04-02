// lib/providers/settings_provider.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class SettingsProvider extends ChangeNotifier {
  // TTS 관련 설정
  bool _ttsEnabled = true;
  String _voiceType = 'default';
  double _speechRate = 1.0;
  double _speechPitch = 1.0;

  // UI 관련 설정
  double _textSize = 1.0;
  double _iconSize = 1.0;
  ThemeMode _themeMode = ThemeMode.system;
  int _gridColumns = 2;

  // 로딩 상태
  bool _isLoading = true;
  String? _error;

  // API 서비스
  final ApiService _apiService = ApiService();

  // 추가된 코드
  bool _autoSpeak = true;

  // Getters
  bool get ttsEnabled => _ttsEnabled;
  String get voiceType => _voiceType;
  double get speechRate => _speechRate;
  double get speechPitch => _speechPitch;
  double get textSize => _textSize;
  double get iconSize => _iconSize;
  ThemeMode get themeMode => _themeMode;
  int get gridColumns => _gridColumns;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get autoSpeak => _autoSpeak;

  SettingsProvider() {
    _loadSettings();
  }

  // 설정 불러오기
  Future<void> _loadSettings() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 백엔드에서 설정 데이터 불러오기
      final settings = await _apiService.getSettings();

      // TTS 설정
      _ttsEnabled = settings['tts_enabled'] ?? true;
      _voiceType = settings['voice_type'] ?? 'default';
      _speechRate = settings['speech_rate'] ?? 1.0;
      _speechPitch = settings['speech_pitch'] ?? 1.0;

      // UI 설정
      _textSize = settings['text_size'] ?? 1.0;
      _iconSize = settings['icon_size'] ?? 1.0;
      _gridColumns = settings['grid_columns'] ?? 2;

      // 테마 설정
      final themeString = settings['theme_mode'] ?? 'system';
      switch (themeString) {
        case 'light':
          _themeMode = ThemeMode.light;
          break;
        case 'dark':
          _themeMode = ThemeMode.dark;
          break;
        default:
          _themeMode = ThemeMode.system;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('설정 로드 오류: $e');
      _error = '설정을 불러오는 중 오류가 발생했습니다.';
      _isLoading = false;

      // 오류 발생 시 기본 설정 사용
      _initializeDefaultSettings();
      notifyListeners();
    }
  }

  // 기본 설정 초기화
  void _initializeDefaultSettings() {
    _ttsEnabled = true;
    _voiceType = 'default';
    _speechRate = 1.0;
    _speechPitch = 1.0;
    _textSize = 1.0;
    _iconSize = 1.0;
    _gridColumns = 2;
    _themeMode = ThemeMode.system;
  }

  // 설정 저장
  Future<bool> saveSettings() async {
    try {
      final settings = {
        'tts_enabled': _ttsEnabled,
        'voice_type': _voiceType,
        'speech_rate': _speechRate,
        'speech_pitch': _speechPitch,
        'text_size': _textSize,
        'icon_size': _iconSize,
        'grid_columns': _gridColumns,
        'theme_mode': _getThemeModeString(),
      };

      // 백엔드에 설정 저장
      await _apiService.saveSettings(settings);
      return true;
    } catch (e) {
      print('설정 저장 오류: $e');
      _error = '설정을 저장하는 중 오류가 발생했습니다.';
      notifyListeners();
      return false;
    }
  }

  // 설정 업데이트 함수들

  // TTS 활성화 설정
  Future<bool> setTtsEnabled(bool enabled) async {
    _ttsEnabled = enabled;
    notifyListeners();
    return await saveSettings();
  }

  // 음성 유형 설정
  Future<bool> setVoiceType(String type) async {
    _voiceType = type;
    notifyListeners();
    return await saveSettings();
  }

  // 음성 속도 설정
  Future<bool> setSpeechRate(double rate) async {
    _speechRate = rate;
    notifyListeners();
    return await saveSettings();
  }

  // 음성 높낮이 설정
  Future<bool> setSpeechPitch(double pitch) async {
    _speechPitch = pitch;
    notifyListeners();
    return await saveSettings();
  }

  // 텍스트 크기 설정
  Future<bool> setTextSize(double size) async {
    _textSize = size;
    notifyListeners();
    return await saveSettings();
  }

  // 아이콘 크기 설정
  Future<bool> setIconSize(double size) async {
    _iconSize = size;
    notifyListeners();
    return await saveSettings();
  }

  // 그리드 열 개수 설정
  Future<bool> setGridColumns(int columns) async {
    _gridColumns = columns;
    notifyListeners();
    return await saveSettings();
  }

  // 테마 모드 설정
  Future<bool> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    return await saveSettings();
  }

  // ThemeMode를 문자열로 변환
  String _getThemeModeString() {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      default:
        return 'system';
    }
  }

  // 추가된 코드
  Future<bool> setAutoSpeak(bool value) async {
    _autoSpeak = value;
    notifyListeners();
    return await saveSettings();
  }

  Future<bool> resetSettings() async {
    _themeMode = ThemeMode.system;
    _textSize = 1.0;
    _iconSize = 1.0;
    _gridColumns = 2;
    _speechRate = 1.0;
    _speechPitch = 1.0;
    _autoSpeak = true;
    notifyListeners();
    return await saveSettings();
  }
}
