// lib/screens/category_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:connect_aac/providers/vocabulary_provider.dart';
import 'package:connect_aac/models/category.dart';
import 'package:connect_aac/models/vocabulary_item.dart';
import 'package:connect_aac/screens/word_list_screen.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Fetch initial category data if not already loaded by the provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vocabProvider = Provider.of<VocabularyProvider>(context, listen: false);
      // Clear search on screen init if desired
      if (vocabProvider.searchQuery.isNotEmpty) {
         vocabProvider.clearSearch();
         _searchController.clear();
      }
      // Fetch categories if they are empty
      if (vocabProvider.categories.isEmpty && !vocabProvider.isLoadingCategories) {
        vocabProvider.fetchCategories();
      }
    });
  }

  @override
  void dispose() {
      _searchController.dispose();
      super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    // Use Consumer for reacting to changes in VocabularyProvider
    return Consumer<VocabularyProvider>(
      builder: (context, vocabularyProvider, child) {
        Widget bodyContent;

        if (vocabularyProvider.isLoadingCategories && vocabularyProvider.categories.isEmpty) {
          bodyContent = const Center(child: CircularProgressIndicator());
        } else if (!vocabularyProvider.isLoadingCategories && vocabularyProvider.categories.isEmpty) {
          bodyContent = Center(
             child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   const Text('카테고리를 불러오는데 실패했습니다.'),
                   const SizedBox(height: 8),
                    ElevatedButton(
                       onPressed: () => vocabularyProvider.fetchCategories(),
                       child: const Text('다시 시도'),
                   )
                ],
             )
          );
        } else {
          // Categories loaded or loading didn't fail catastrophically
          bodyContent = Expanded( // Make the content area expand
            child: vocabularyProvider.searchQuery.isNotEmpty
                ? _buildSearchResults(context, vocabularyProvider)
                : _buildCategoryGrid(context, vocabularyProvider.categories),
          );
        }

        // Return AppScaffold or basic Column structure
        // Using basic column structure for this example
        return Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0), // Adjust padding
              child: TextField(
                  controller: _searchController,
                  // Trigger search on text change
                  onChanged: (value) {
                     vocabularyProvider.setSearchQuery(value);
                  },
                  // Optional: Trigger search on submission
                   onSubmitted: (value) {
                      vocabularyProvider.search(value);
                   },
                  decoration: InputDecoration(
                    hintText: '카테고리 또는 단어 검색...',
                    prefixIcon: const Icon(Icons.search),
                     // Add clear button
                     suffixIcon: vocabularyProvider.searchQuery.isNotEmpty
                       ? IconButton(
                           icon: const Icon(Icons.clear),
                           onPressed: () {
                             _searchController.clear();
                             vocabularyProvider.clearSearch();
                           },
                         )
                       : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                     // Use theme color for fill
                    fillColor: Theme.of(context).colorScheme.surfaceVariant,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20) // Adjust padding
                  ),
              ),
            ),
            // Content area (results or grid)
            bodyContent,
          ],
        );
      },
    );
  }

  // Builds the grid of category cards
  Widget _buildCategoryGrid(BuildContext context, List<Category> categories) {
     if (categories.isEmpty) {
       // This case might not be reached if loading handles it, but good fallback
       return const Center(child: Text('카테고리가 없습니다.'));
     }
    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Adjust based on screen size if needed
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.1, // Adjust for content
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return _buildCategoryCard(context, category);
      },
    );
  }

  // Builds a single category card
 Widget _buildCategoryCard(BuildContext context, Category category) {
    IconData iconData = category.iconData; // Use getter from model

    return Card(
       elevation: 2,
       clipBehavior: Clip.antiAlias, // Ensures ink splash stays within rounded corners
       shape: RoundedRectangleBorder(
         borderRadius: BorderRadius.circular(16),
       ),
      child: InkWell(
        onTap: () {
          // Navigate to WordListScreen for the selected category
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => WordListScreen(categoryId: category.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                 radius: 30,
                 backgroundColor: Theme.of(context).colorScheme.primaryContainer, // Use theme color
                 child: Icon(
                   iconData,
                   size: 30,
                   color: Theme.of(context).colorScheme.onPrimaryContainer, // Use theme color
                 ),
              ),
              const SizedBox(height: 12),
              Text(
                category.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                 maxLines: 1,
                 overflow: TextOverflow.ellipsis,
              ),
              // Show description if available
              if (category.description != null && category.description!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Expanded( // Allow description to take remaining space
                  child: Text(
                    category.description!,
                     style: Theme.of(context).textTheme.bodySmall?.copyWith(
                           color: Theme.of(context).colorScheme.onSurfaceVariant, // Use theme color
                         ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }


 // Builds the list of search results (categories and items)
  Widget _buildSearchResults(BuildContext context, VocabularyProvider vocabularyProvider) {
     final List<Category> categoryResults = vocabularyProvider.searchCategories;
     final List<VocabularyItem> itemResults = vocabularyProvider.searchResults;

     // Show loading indicator specific to search
     if (vocabularyProvider.isLoadingSearch) {
         return const Center(child: CircularProgressIndicator());
     }

     // Show 'no results' message
     if (categoryResults.isEmpty && itemResults.isEmpty) {
       return Center(
         child: Column(
           mainAxisAlignment: MainAxisAlignment.center,
           children: [
             Icon(
               Icons.search_off,
               size: 64,
               color: Theme.of(context).colorScheme.onSurfaceVariant, // Use theme color
             ),
             const SizedBox(height: 16),
             Text(
               '\'${vocabularyProvider.searchQuery}\'에 대한 검색 결과가 없습니다',
               style: Theme.of(context).textTheme.titleMedium?.copyWith(
                     color: Theme.of(context).colorScheme.onSurfaceVariant,
                   ),
                textAlign: TextAlign.center,
                ),
           ],
         ),
       );
     }

     // Build the list view for results
     return ListView(
       padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
       children: [
         // Category Results Section
         if (categoryResults.isNotEmpty) ...[
           Padding(
             padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
             child: Text(
               '카테고리 (${categoryResults.length})', // Show count
               style: Theme.of(context).textTheme.titleSmall?.copyWith(
                     fontWeight: FontWeight.bold,
                     color: Theme.of(context).colorScheme.primary, // Highlight title
                   ),
             ),
           ),
           ...categoryResults.map((category) {
               return ListTile(
                 leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    child: Icon(
                      category.iconData,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      size: 24, // Slightly smaller icon in list
                    ),
                 ),
                 title: Text(category.name),
                 subtitle: category.description != null && category.description!.isNotEmpty
                             ? Text(category.description!, maxLines: 1, overflow: TextOverflow.ellipsis)
                             : null,
                 onTap: () {
                   // Clear search before navigating? Optional.
                   // vocabularyProvider.clearSearch();
                   // _searchController.clear();
                   Navigator.push(
                     context,
                     MaterialPageRoute(
                       builder: (_) => WordListScreen(categoryId: category.id),
                     ),
                   );
                 },
                 dense: true, // Make list items more compact
               );
             }).toList(), // Use toList() here
           const SizedBox(height: 16), // Spacing between sections
         ],

         // Vocabulary Item Results Section
         if (itemResults.isNotEmpty) ...[
            Padding(
             padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
             child: Text(
               '단어 (${itemResults.length})', // Show count
               style: Theme.of(context).textTheme.titleSmall?.copyWith(
                     fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                   ),
             ),
           ),
           ...itemResults.map((item) {
             final category = vocabularyProvider.getCategoryById(item.categoryId);
             final categoryName = category?.name ?? '카테고리 없음';

             return ListTile(
               leading: _buildItemLeading(context, item), // Use helper for leading widget
               title: Text(item.text),
               subtitle: Text("카테고리: $categoryName"),
               onTap: () {
                 // vocabularyProvider.clearSearch();
                 // _searchController.clear();
                 Navigator.push(
                   context,
                   MaterialPageRoute(
                     builder: (_) => WordListScreen(
                       categoryId: item.categoryId,
                       highlightItemId: item.id, // Pass item ID to highlight
                     ),
                   ),
                 );
               },
                dense: true,
             );
           }).toList(), // Use toList() here
         ],
       ],
     );
   }

  // Helper for building the leading widget (image or initial) for vocabulary items
  Widget _buildItemLeading(BuildContext context, VocabularyItem item) {
    final imageUrl = item.fullImageUrl; // Use helper from model

    Widget placeholder = CircleAvatar( // Default placeholder
       backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
       child: Text(
         item.text.isNotEmpty ? item.text.substring(0, 1) : '?',
         style: TextStyle(
           color: Theme.of(context).colorScheme.onSecondaryContainer,
           fontWeight: FontWeight.bold,
         ),
       ),
    );

    if (imageUrl != null) {
      // Check if it's an asset or network image
      if (imageUrl.startsWith('assets/')) {
        // Use AssetImage
        return CircleAvatar(
           backgroundImage: AssetImage(imageUrl),
           backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
           // Optional: Error handling for AssetImage is less common but possible
           onBackgroundImageError: (_, __) {
              print("Error loading asset image: $imageUrl");
           },
        );
      } else {
         // Use NetworkImage
         // Use FadeInImage for better loading experience
         return CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
              child: ClipOval( // Clip the image to the circle avatar shape
                  child: FadeInImage.assetNetwork(
                      placeholder: 'assets/images/placeholder.png', // TODO: Add a placeholder asset image
                      image: imageUrl,
                      fit: BoxFit.cover, // Cover the circle area
                      imageErrorBuilder: (_, error, stackTrace) {
                          print("Error loading network image: $imageUrl, Error: $error");
                          // Fallback to placeholder text if image fails
                          return Center(
                              child: Text(
                                item.text.isNotEmpty ? item.text.substring(0, 1) : '?',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          );
                      },
                  ),
              ),
         );
      }
    } else {
      // Fallback to initials placeholder if no image URL
      return placeholder;
    }
  }
}
