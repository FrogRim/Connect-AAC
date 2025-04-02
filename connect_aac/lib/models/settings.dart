// lib/models/settings.dart 추가
import 'package:flutter/material.dart';

class Settings {
  final String id;
  final String userId;
  final double textSize;
  final double iconSize;
  final String themeMode;
  final bool ttsEnabled;
  final String voiceType;
  final double speechRate;

  const Settings({
    required this.id,
    required this.userId,
    this.textSize = 1.0,
    this.iconSize = 1.0,
    this.themeMode = 'system',
    this.ttsEnabled = true,
    this.voiceType = 'default',
    this.speechRate = 1.0,
  });

  // JSON 직렬화
  Map<String, dynamic> toJson() {
    return {
      'setting_id': id,
      'user_id': userId,
      'text_size': textSize,
      'icon_size': iconSize,
      'theme_mode': themeMode,
      'tts_enabled': ttsEnabled,
      'voice_type': voiceType,
      'speech_rate': speechRate,
    };
  }

  // JSON 역직렬화
  factory Settings.fromJson(Map<String, dynamic> json) {
    return Settings(
      id: json['setting_id'] ?? '',
      userId: json['user_id'] ?? '',
      textSize: json['text_size']?.toDouble() ?? 1.0,
      iconSize: json['icon_size']?.toDouble() ?? 1.0,
      themeMode: json['theme_mode'] ?? 'system',
      ttsEnabled: json['tts_enabled'] ?? true,
      voiceType: json['voice_type'] ?? 'default',
      speechRate: json['speech_rate']?.toDouble() ?? 1.0,
    );
  }

  // ThemeMode로 변환하는 유틸리티 메서드
  ThemeMode getThemeMode() {
    switch (themeMode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}
