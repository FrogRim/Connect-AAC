// lib/models/favorite.dart 추가
class Favorite {
  final String id;
  final String userId;
  final String itemId;
  final int displayOrder;
  final DateTime createdAt;

  const Favorite({
    required this.id,
    required this.userId,
    required this.itemId,
    this.displayOrder = 0,
    required this.createdAt,
  });

  // JSON 직렬화
  Map<String, dynamic> toJson() {
    return {
      'favorite_id': id,
      'user_id': userId,
      'item_id': itemId,
      'display_order': displayOrder,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // JSON 역직렬화
  factory Favorite.fromJson(Map<String, dynamic> json) {
    return Favorite(
      id: json['favorite_id'] ?? '',
      userId: json['user_id'] ?? '',
      itemId: json['item_id'] ?? '',
      displayOrder: json['display_order'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }
}
