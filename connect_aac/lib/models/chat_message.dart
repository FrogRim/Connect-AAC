// lib/models/chat_message.dart 업데이트
class ChatMessage {
  String id;
  final String text;
  final DateTime timestamp;
  final bool isUser;
  final String? imageAsset;

  ChatMessage({
    required this.id,
    required this.text,
    required this.timestamp,
    required this.isUser,
    this.imageAsset,
  });

  // JSON 직렬화
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
      'isUser': isUser,
      'imageAsset': imageAsset,
    };
  }

  // JSON 역직렬화
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['message_id'] ?? json['id'] ?? '',
      text: json['content'] ?? json['text'] ?? '',
      timestamp: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : (json['timestamp'] != null
              ? DateTime.parse(json['timestamp'])
              : DateTime.now()),
      isUser: !(json['is_ai'] ?? !json['isUser'] ?? false),
      imageAsset: json['image_path'] ?? json['imageAsset'],
    );
  }
}
