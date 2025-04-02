// lib/models/category.dart 업데이트
class Category {
  final String id;
  final String name;
  final String iconName;
  final String? description;

  const Category({
    required this.id,
    required this.name,
    required this.iconName,
    this.description,
  });

  // JSON 직렬화
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'iconName': iconName,
      'description': description,
    };
  }

  // JSON 역직렬화
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['category_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      iconName: json['icon_name'] ?? json['iconName'] ?? 'category',
      description: json['description'],
    );
  }
}
