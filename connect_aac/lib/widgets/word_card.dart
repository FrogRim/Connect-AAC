// lib/widgets/word_card.dart
import 'package:flutter/material.dart';
import 'package:connect_aac/models/vocabulary_item.dart';

class WordCard extends StatelessWidget {
  final VocabularyItem item;
  final bool isFavorite;
  final bool isHighlighted; // To visually indicate selection/highlight
  final VoidCallback? onTap; // Action when the card body is tapped
  final VoidCallback? onFavoriteToggle; // Action for the favorite button

  const WordCard({
    super.key,
    required this.item,
    this.isFavorite = false,
    this.isHighlighted = false, // Default to false
    this.onTap,
    this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = item.fullImageUrl; // Get potentially full URL or asset path
    final theme = Theme.of(context);

    return Card(
       elevation: isHighlighted ? 6 : 2, // Increase elevation if highlighted
       clipBehavior: Clip.antiAlias, // Ensures ink splash/border radius applies correctly
       shape: RoundedRectangleBorder(
         borderRadius: BorderRadius.circular(16),
         // Add a visual border if highlighted
         side: isHighlighted
             ? BorderSide(color: theme.colorScheme.primary, width: 2.5) // Thicker border
             : BorderSide(color: theme.dividerColor.withOpacity(0.5), width: 0.5), // Subtle border always
       ),
       color: isHighlighted ? theme.colorScheme.primaryContainer.withOpacity(0.3) : theme.cardColor, // Background highlight
      child: InkWell(
        onTap: onTap, // Trigger main action on tap
        borderRadius: BorderRadius.circular(16), // Match card shape for ink effect
        child: Padding(
          padding: const EdgeInsets.all(8.0), // Padding inside the card
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // Space out elements vertically
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Image Area with Favorite Button Overlay
              Expanded( // Allow image area to take available space
                flex: 3, // Give more space to image
                child: Stack(
                  alignment: Alignment.topRight,
                  children: [
                    // Image or Placeholder Container
                    Center(
                      child: AspectRatio(
                        aspectRatio: 1.0, // Keep image area square-ish
                        child: Container(
                           padding: const EdgeInsets.all(4), // Padding around image
                           decoration: BoxDecoration(
                             borderRadius: BorderRadius.circular(12),
                             // Use a subtle background color based on theme
                             color: theme.scaffoldBackgroundColor,
                           ),
                           // --- Image Display Logic ---
                           child: _buildImageWidget(context, imageUrl, item, theme),
                        ),
                      ),
                    ),
                    // Favorite Button (only if callback provided)
                    if (onFavoriteToggle != null)
                      Positioned( // Position precisely if needed
                        top: -4, // Adjust position
                        right: -4,
                        child: IconButton(
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? Colors.redAccent : Colors.grey.shade500,
                            size: 28, // Make favorite icon slightly larger
                          ),
                          // Reduce padding to make tappable area smaller if needed
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: onFavoriteToggle,
                          tooltip: isFavorite ? '즐겨찾기 해제' : '즐겨찾기 추가',
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Text Area
              Expanded( // Allow text to take remaining space
                 flex: 1,
                 child: Center( // Center the text vertically
                   child: Text(
                      item.text,
                      style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                      maxLines: 2, // Allow up to two lines for text
                      overflow: TextOverflow.ellipsis,
                   ),
                 ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget to build the image display part
  Widget _buildImageWidget(BuildContext context, String? imageUrl, VocabularyItem item, ThemeData theme) {
       // Placeholder using initials
     Widget placeholderWidget = Center(
       child: Text(
         item.text.isNotEmpty ? item.text[0] : '?', // Show first initial
         style: TextStyle(
             fontSize: 32,
             fontWeight: FontWeight.bold,
             color: theme.colorScheme.primary),
       ),
     );

     if (imageUrl != null) {
       if (imageUrl.startsWith('assets/')) {
         // Load from assets
         return Image.asset(
           imageUrl,
           fit: BoxFit.contain, // Contain ensures the whole image is visible
           errorBuilder: (_, __, ___) => placeholderWidget, // Fallback on error
         );
       } else {
         // Load from network
         // Use FadeInImage for smooth loading
         return FadeInImage.assetNetwork(
            // TODO: Add a suitable placeholder image in your assets
            placeholder: 'assets/images/placeholder.png', // Path to your placeholder asset
            image: imageUrl,
            fit: BoxFit.contain,
            placeholderErrorBuilder: (_, __, ___) => placeholderWidget, // Fallback if placeholder fails
            imageErrorBuilder: (_, error, stackTrace) {
              print("Error loading network image: $imageUrl, Error: $error");
              return placeholderWidget; // Fallback on error
            },
          );
       }
     } else {
       // If no image URL, return the placeholder
       return placeholderWidget;
     }
  }
}
