// lib/models/recent_usage.dart 추가
class RecentUsage {
  final String id;
  final String userId;
  final String itemId;
  final int usageCount;
  final DateTime lastUsed;

  const RecentUsage({
    required this.id,
    required this.userId,
    required this.itemId,
    this.usageCount = 1,
    required this.lastUsed,
  });

  // JSON 직렬화
  Map<String, dynamic> toJson() {
    return {
      'usage_id': id,
      'user_id': userId,
      'item_id': itemId,
      'usage_count': usageCount,
      'last_used': lastUsed.toIso8601String(),
    };
  }

  // JSON 역직렬화
  factory RecentUsage.fromJson(Map<String, dynamic> json) {
    return RecentUsage(
      id: json['usage_id'] ?? '',
      userId: json['user_id'] ?? '',
      itemId: json['item_id'] ?? '',
      usageCount: json['usage_count'] ?? 1,
      lastUsed: json['last_used'] != null
          ? DateTime.parse(json['last_used'])
          : DateTime.now(),
    );
  }
}
