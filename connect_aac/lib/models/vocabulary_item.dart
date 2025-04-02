// lib/models/vocabulary_item.dart 업데이트
class VocabularyItem {
  final String id;
  final String text;
  final String imageAsset;
  final String categoryId;
  final bool isCustom;
  final DateTime? createdAt;

  const VocabularyItem({
    required this.id,
    required this.text,
    required this.imageAsset,
    required this.categoryId,
    this.isCustom = false,
    this.createdAt,
  });

  // JSON 직렬화
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'imageAsset': imageAsset,
      'categoryId': categoryId,
      'isCustom': isCustom,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  // JSON 역직렬화
  factory VocabularyItem.fromJson(Map<String, dynamic> json) {
    return VocabularyItem(
      id: json['item_id'] ?? json['id'] ?? '',
      text: json['text'] ?? '',
      imageAsset: json['image_path'] ?? json['imageAsset'] ?? '',
      categoryId: json['category_id'] ?? json['categoryId'] ?? '',
      isCustom: json['isCustom'] ?? json['is_custom'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }
}
