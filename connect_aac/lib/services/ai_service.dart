// lib/services/ai_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class AIService {
  final ApiService _apiService = ApiService();

  // LLM 모델을 통한 챗봇 응답 가져오기
  Future<String> getResponse(String message) async {
    try {
      // 백엔드 API를 통해 LLM 모델 응답 가져오기
      final response = await _apiService.sendChatMessage(message);

      // AI 응답 추출
      final aiResponse = response['response'];
      if (aiResponse != null && aiResponse['content'] != null) {
        return aiResponse['content'];
      } else {
        throw Exception('AI 응답을 가져올 수 없습니다.');
      }
    } catch (e) {
      print('AI 응답 오류: $e');

      // 오류 발생 시 기본 응답 반환 (실제 서비스에서는 더 나은 오류 처리 필요)
      return '현재 응답을 생성할 수 없습니다. 잠시 후 다시 시도해 주세요.';
    }
  }

  // 음성 합성 (TTS) 함수
  Future<List<int>> synthesizeSpeech(String text,
      {String? voiceType, double? speechRate}) async {
    try {
      return await _apiService.synthesizeSpeech(text,
          voiceType: voiceType, speechRate: speechRate);
    } catch (e) {
      print('음성 합성 오류: $e');
      throw Exception('음성 합성에 실패했습니다.');
    }
  }
}
