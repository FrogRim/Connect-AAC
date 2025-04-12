// lib/screens/word_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:connect_aac/providers/vocabulary_provider.dart';
import 'package:connect_aac/providers/favorites_provider.dart';
import 'package:connect_aac/models/vocabulary_item.dart';
import 'package:connect_aac/models/category.dart'; // Import Category model
import 'package:connect_aac/widgets/word_card.dart';
// Import TTS service if available
// import 'package:connect_aac/services/tts_service.dart';
// Import SettingsProvider if TTS depends on settings
// import 'package:connect_aac/providers/settings_provider.dart';

class WordListScreen extends StatefulWidget {
  final String categoryId;
  final String? highlightItemId; // Item to highlight initially

  const WordListScreen({
    super.key,
    required this.categoryId,
    this.highlightItemId,
  });

  @override
  State<WordListScreen> createState() => _WordListScreenState();
}

class _WordListScreenState extends State<WordListScreen> {
   final ScrollController _scrollController = ScrollController();
   // TODO: Inject or get TTS service instance
   // final TtsService _ttsService = TtsService(); // Example initialization

  @override
  void initState() {
    super.initState();
    // Fetch items for this category when the screen loads
    // Fetching logic is moved to Consumers for better state handling during build
     WidgetsBinding.instance.addPostFrameCallback((_) {
        // Fetch favorites initially if not already loaded (provider handles duplicates)
       Provider.of<FavoritesProvider>(context, listen: false).fetchFavorites();
       // Trigger fetching items for this category
       Provider.of<VocabularyProvider>(context, listen: false)
          .fetchVocabularyItems(categoryId: widget.categoryId)
          .then((_) {
             // Attempt to scroll after items are fetched
             if (widget.highlightItemId != null && mounted) {
                // Need a slight delay for the list/grid to render items
                Future.delayed(const Duration(milliseconds: 400), _scrollToHighlightedItem);
             }
          });
     });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }


  void _scrollToHighlightedItem() {
     // Ensure provider has items before attempting to find index
     final vocabProvider = Provider.of<VocabularyProvider>(context, listen: false);
     final items = vocabProvider.items;
     if (items.isEmpty || !mounted) return; // Exit if no items or widget disposed

     final index = items.indexWhere((item) => item.id == widget.highlightItemId);

     if (index != -1 && _scrollController.hasClients) {
       // Calculating exact offset for GridView is tricky.
       // This estimation might need fine-tuning based on actual item render size.
       final screenWidth = MediaQuery.of(context).size.width;
       final crossAxisCount = (screenWidth > 600) ? 3 : 2; // Example responsive count
       final itemWidth = screenWidth / crossAxisCount;
       final itemHeight = itemWidth / 0.9; // Approximation based on aspect ratio 0.9
       final mainAxisSpacing = 16.0; // Match GridView's mainAxisSpacing

       final rowIndex = (index / crossAxisCount).floor();
       final offset = rowIndex * (itemHeight + mainAxisSpacing);

       _scrollController.animateTo(
         offset,
         duration: const Duration(milliseconds: 600), // Slightly longer duration
         curve: Curves.easeInOut,
       );
     }
   }

   // Function to handle word tap (e.g., trigger TTS)
   void _handleWordTap(VocabularyItem item) {
      print('Tapped: ${item.text}');
      // TODO: Implement TTS call
      // Example:
      // final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
      // if (settingsProvider.ttsEnabled) {
      //   _ttsService.speak(
      //     text: item.text,
      //     language: 'ko-KR', // Get language from settings or item?
      //     rate: settingsProvider.speechRate,
      //     voice: settingsProvider.voiceType,
      //   );
      // }
   }


  @override
  Widget build(BuildContext context) {
     // Get category details from the provider (listen: false as it's unlikely to change here)
    final Category? category = Provider.of<VocabularyProvider>(context, listen: false)
        .getCategoryById(widget.categoryId);

    // Use AppScaffold or a regular Scaffold
    return Scaffold( // Using Scaffold
      appBar: AppBar(
        title: Text(category?.name ?? '어휘 목록'), // Show category name if available
         // Optional: Add search or other actions specific to this screen
      ),
      // Use nested Consumers to react to changes in both providers
      body: Consumer<VocabularyProvider>(
        builder: (context, vocabProvider, _) {
           // Show loading specific to items
           if (vocabProvider.isLoadingItems && vocabProvider.items.isEmpty) {
              return const Center(child: CircularProgressIndicator());
           }
           // Show error if items failed to load
           if (!vocabProvider.isLoadingItems && vocabProvider.items.isEmpty) {
              return Center(
                 child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                             '이 카테고리에 어휘 항목을 불러오는데 실패했거나 항목이 없습니다.',
                              textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                           onPressed: () => vocabProvider.fetchVocabularyItems(categoryId: widget.categoryId),
                           child: const Text('다시 시도'),
                       ),
                    ],
                 )
              );
           }

           // Items are loaded (or partially loaded), display the grid
           final items = vocabProvider.items;

           return Consumer<FavoritesProvider>( // Inner consumer for favorites state
             builder: (context, favProvider, _) {
                // Show a subtle loading for favorites only if items are already displayed
               // if (favProvider.isLoading && items.isNotEmpty) {
               //    // Optionally show a small indicator or just let the buttons update
               // }

                // Determine cross axis count based on screen width for responsiveness
                final screenWidth = MediaQuery.of(context).size.width;
                final crossAxisCount = (screenWidth > 900) ? 4 : (screenWidth > 600 ? 3 : 2);

                return GridView.builder(
                  controller: _scrollController, // Attach scroll controller
                  padding: const EdgeInsets.all(16.0),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount, // Responsive count
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.9, // Adjust aspect ratio for WordCard
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    // Check if item should be highlighted (e.g., from search result click)
                    final isHighlighted = item.id == widget.highlightItemId;
                    // Check favorite status from the provider
                    final isFavorite = favProvider.isFavorite(item.id);

                    // Return the WordCard widget
                    return WordCard(
                      item: item,
                      isFavorite: isFavorite,
                      isHighlighted: isHighlighted,
                      onTap: () => _handleWordTap(item), // Pass tap handler
                      onFavoriteToggle: () {
                        // Toggle favorite status using the provider
                        // Prevent rapid toggling if provider is loading
                        if (!favProvider.isLoading) {
                            if (isFavorite) {
                              favProvider.deleteFavoriteByItemId(item.id);
                            } else {
                              favProvider.addFavorite(item.id);
                            }
                        }
                      },
                    );
                  },
                );
             },
           );
        },
      ),
    );
  }
}
