// lib/providers/chat_provider.dart
import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../services/api_service.dart';
import '../services/tts_service.dart';

class ChatProvider extends ChangeNotifier {
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _error;

  // 서비스
  final ApiService _apiService = ApiService();
  final TTSService _ttsService = TTSService();

  // Getters
  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;

  ChatProvider() {
    _loadChatHistory();
  }

  // 채팅 기록 로드
  Future<void> _loadChatHistory() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 백엔드에서 채팅 기록 불러오기
      final chatHistory = await _apiService.getChatMessages();
      _messages = chatHistory;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('채팅 기록 로드 오류: $e');
      _error = '채팅 기록을 불러오는 중 오류가 발생했습니다.';
      _isLoading = false;
      notifyListeners();
    }
  }

  // 채팅 기록 새로고침
  Future<void> refreshChatHistory() async {
    await _loadChatHistory();
  }

  // 사용자 메시지 전송 및 AI 응답 처리
  Future<bool> sendMessage(String content,
      {String messageType = 'text', bool useTts = true}) async {
    if (content.trim().isEmpty) return false;

    // 사용자 메시지 임시 추가 (낙관적 업데이트)
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: content,
      timestamp: DateTime.now(),
      isUser: true,
    );

    _messages.add(userMessage);
    notifyListeners();

    // 로딩 상태 설정
    _isLoading = true;
    notifyListeners();

    try {
      // 백엔드 API를 통해 메시지 전송
      final response =
          await _apiService.sendChatMessage(content, messageType: messageType);

      // 실제 사용자 메시지 ID 업데이트
      userMessage.id = response['message_id'] ?? userMessage.id;

      // AI 응답 처리
      final aiResponse = response['response'];
      if (aiResponse != null) {
        final aiMessage = ChatMessage(
          id: aiResponse['message_id'] ?? '',
          text: aiResponse['content'] ?? '응답을 생성할 수 없습니다.',
          timestamp: DateTime.parse(
              aiResponse['created_at'] ?? DateTime.now().toIso8601String()),
          isUser: false,
        );

        _messages.add(aiMessage);

        // TTS 활성화된 경우 음성 합성
        if (useTts) {
          _ttsService.speak(aiMessage.text);
        }
      }

      _isLoading = false;
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      print('메시지 전송 오류: $e');

      // 오류 발생 시 기본 응답 생성
      final errorMessage = ChatMessage(
        id: 'error-${DateTime.now().millisecondsSinceEpoch}',
        text: '현재 응답을 생성할 수 없습니다. 잠시 후 다시 시도해 주세요.',
        timestamp: DateTime.now(),
        isUser: false,
      );

      _messages.add(errorMessage);
      _isLoading = false;
      _error = '메시지 전송 중 오류가 발생했습니다.';
      notifyListeners();
      return false;
    }
  }

  // 메시지 삭제
  Future<bool> deleteMessage(String messageId) async {
    try {
      // 백엔드에서는 구현 필요 (현재는 로컬에서만 삭제)
      _messages.removeWhere((message) => message.id == messageId);
      notifyListeners();
      return true;
    } catch (e) {
      print('메시지 삭제 오류: $e');
      return false;
    }
  }

  // 채팅 기록 전체 삭제
  Future<bool> clearChatHistory() async {
    try {
      // 백엔드 API 호출
      await _apiService.logout(); // 임시 구현, 실제로는 채팅 기록 삭제 API 필요

      _messages = [];
      notifyListeners();
      return true;
    } catch (e) {
      print('채팅 기록 삭제 오류: $e');
      return false;
    }
  }

  Future<void> clearMessages() async {
    _messages.clear();
    notifyListeners();
  }

  // 리소스 해제
  void dispose() {
    _ttsService.dispose();
    super.dispose();
  }
}
