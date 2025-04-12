// lib/models/vocabulary_item.dart
class VocabularyItem {
  final String id;
  final String text;
  final String? imagePath; // API returns path, adjust if it returns full URL
  final String categoryId;
  final int displayOrder; // Added based on API spec

  VocabularyItem({
    required this.id,
    required this.text,
    this.imagePath,
    required this.categoryId,
    required this.displayOrder,
  });

  factory VocabularyItem.fromJson(Map<String, dynamic> json) {
    return VocabularyItem(
      id: json['item_id'] as String,
      text: json['text'] as String,
      imagePath: json['image_path'] as String?,
      categoryId: json['category_id'] as String,
      // Provide a default value if display_order might be null/missing
      displayOrder: (json['display_order'] ?? 0) as int,
    );
  }

   // Helper to construct full image URL if base URL is known and API returns path
   String? get fullImageUrl {
     // TODO: Confirm how image paths are returned and adjust base URL if needed
     const String imageBaseUrl = "http://localhost:5000"; // Example base URL

     if (imagePath != null && imagePath!.isNotEmpty) {
        // Option 1: If API returns full URL already
        // if (imagePath!.startsWith('http')) {
        //   return imagePath;
        // }

        // Option 2: If API returns path relative to server root (e.g., /uploads/image.png)
        // if (imagePath!.startsWith('/')) {
        //   return '$imageBaseUrl$imagePath';
        // }

        // Option 3: If API returns path relative to a specific folder (e.g., images/image.png)
        // return '$imageBaseUrl/path/to/images/$imagePath';

        // Option 4: If API returns path usable by Flutter assets (e.g., assets/images/...)
        // This seems likely based on the initial data structure provided
         if (imagePath!.startsWith('assets/')) {
            return imagePath;
         }

         // Fallback/Default: Assume relative path needs base URL (adjust as needed)
         return '$imageBaseUrl/$imagePath';
     }
     return null;
   }
}
