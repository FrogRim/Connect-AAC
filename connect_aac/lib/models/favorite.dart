// lib/models/favorite.dart
class Favorite {
    final String favoriteId;
    final String itemId;
    final String userId; // Included in response but maybe not needed in frontend model often
    final String text; // Denormalized data from API response
    final String? imagePath; // Denormalized data
    final String categoryId; // Denormalized data
    final int displayOrder;
    final DateTime createdAt; // Included in response

    Favorite({
        required this.favoriteId,
        required this.itemId,
        required this.userId,
        required this.text,
        this.imagePath,
        required this.categoryId,
        required this.displayOrder,
        required this.createdAt,
    });

     factory Favorite.fromJson(Map<String, dynamic> json) {
        return Favorite(
            favoriteId: json['favorite_id'] as String,
            itemId: json['item_id'] as String,
            userId: json['user_id'] as String? ?? '', // Handle potential null from API response
            text: json['text'] as String? ?? '', // Handle potential null
            imagePath: json['image_path'] as String?,
            categoryId: json['category_id'] as String? ?? '', // Handle potential null
            displayOrder: (json['display_order'] ?? 0) as int,
            // Safely parse DateTime, provide default if parsing fails or value is null
            createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
        );
    }

     // Helper for image URL (similar to VocabularyItem)
      String? get fullImageUrl {
         // TODO: Confirm how image paths are returned and adjust base URL if needed
         const String imageBaseUrl = "http://localhost:5000"; // Example base URL
         if (imagePath != null && imagePath!.isNotEmpty) {
             if (imagePath!.startsWith('assets/')) { // Check for asset path
                 return imagePath;
             }
             // Assume network path otherwise (adjust logic as needed)
             return '$imageBaseUrl/$imagePath';
         }
         return null;
     }
}
