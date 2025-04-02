// lib/services/tts_service.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import 'api_service.dart';

class TTSService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final ApiService _apiService = ApiService();

  // 캐시 - 성능 최적화를 위해 이미 합성된 음성 저장
  final Map<String, Uint8List> _audioCache = {};

  // 초기화
  Future<void> initialize() async {
    // 필요한 초기화 작업 수행
  }

  // 음성 합성 및 재생
  Future<void> speak(String text, {BuildContext? context}) async {
    try {
      // 설정 값 가져오기 (제공된 경우)
      String? voiceType;
      double? speechRate;

      if (context != null) {
        final settingsProvider =
            Provider.of<SettingsProvider>(context, listen: false);
        voiceType = settingsProvider.voiceType;
        speechRate = settingsProvider.speechRate;
      } else {
        // 컨텍스트가 없는 경우 SharedPreferences에서 직접 설정 가져오기
        final prefs = await SharedPreferences.getInstance();
        voiceType = prefs.getString('voice_type');
        speechRate = prefs.getDouble('speech_rate');
      }

      // 캐시 키 생성
      final cacheKey = '$text-$voiceType-$speechRate';

      // 캐시에 있는지 확인
      if (_audioCache.containsKey(cacheKey)) {
        // 캐시된 오디오 재생
        await _playAudio(_audioCache[cacheKey]!);
      } else {
        // API에서 음성 데이터 가져오기
        final audioData = await _apiService.synthesizeSpeech(
          text,
          voiceType: voiceType,
          speechRate: speechRate,
        );

        // 오디오 재생
        await _playAudio(Uint8List.fromList(audioData));

        // 캐시에 저장 (크기 제한 적용)
        if (_audioCache.length >= 50) {
          // 가장 오래된 항목 제거 (간단한 구현)
          _audioCache.remove(_audioCache.keys.first);
        }
        _audioCache[cacheKey] = Uint8List.fromList(audioData);
      }
    } catch (e) {
      print('TTS 오류: $e');
      // 오류 발생 시 로컬 TTS로 대체하거나 사용자에게 알림
    }
  }

  // 오디오 재생 함수
  Future<void> _playAudio(Uint8List audioData) async {
    try {
      // 이전 재생 중지
      await _audioPlayer.stop();

      // 새 오디오 재생
      await _audioPlayer.play(BytesSource(audioData));
    } catch (e) {
      print('오디오 재생 오류: $e');
    }
  }

  // 재생 중지
  Future<void> stop() async {
    await _audioPlayer.stop();
  }

  // 리소스 해제
  void dispose() {
    _audioPlayer.dispose();
    _audioCache.clear();
  }

  // 음성 속도 설정
  void setSpeechRate(double rate) {
    // 음성 속도 설정은 speak 메서드에서 처리됨
  }

  // 음성 높낮이 설정
  void setPitch(double pitch) {
    // 음성 높낮이 설정은 speak 메서드에서 처리됨
  }
}
