//Category selection screen
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/vocabulary_provider.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/search_bar.dart';
import 'word_list_screen.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vocabularyProvider = Provider.of<VocabularyProvider>(context);
    final categories = vocabularyProvider.categories;

    return AppScaffold(
      title: '카테고리',
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SearchBar(
              onChanged: (value) {
                vocabularyProvider.setSearchQuery(value);
              },
              hintText: '카테고리 또는 단어 검색...',
            ),
          ),

          // Search results or categories
          Expanded(
            child: vocabularyProvider.searchQuery.isNotEmpty
                ? _buildSearchResults(context)
                : _buildCategoryGrid(context, categories),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid(BuildContext context, List<dynamic> categories) {
    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return _buildCategoryCard(context, category);
      },
    );
  }

  Widget _buildCategoryCard(BuildContext context, dynamic category) {
    IconData iconData;

    // Map category icon name to IconData
    switch (category.iconName) {
      case 'sentiment_satisfied':
        iconData = Icons.sentiment_satisfied;
        break;
      case 'restaurant':
        iconData = Icons.restaurant;
        break;
      case 'directions_run':
        iconData = Icons.directions_run;
        break;
      case 'access_time':
        iconData = Icons.access_time;
        break;
      case 'place':
        iconData = Icons.place;
        break;
      case 'cleaning_services':
        iconData = Icons.cleaning_services;
        break;
      default:
        iconData = Icons.category;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
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
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor:
                    Theme.of(context).colorScheme.primary.withOpacity(0.1),
                child: Icon(
                  iconData,
                  size: 30,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                category.name,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              if (category.description != null) ...[
                const SizedBox(height: 4),
                Text(
                  category.description!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onBackground
                            .withOpacity(0.7),
                      ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults(BuildContext context) {
    final vocabularyProvider = Provider.of<VocabularyProvider>(context);
    final categoryResults = vocabularyProvider.searchCategories;
    final itemResults = vocabularyProvider.searchResults;

    if (categoryResults.isEmpty && itemResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color:
                  Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              '검색 결과가 없습니다',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onBackground
                        .withOpacity(0.7),
                  ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        if (categoryResults.isNotEmpty) ...[
          Text(
            '카테고리',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          ...categoryResults.map((category) => ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  child: Icon(
                    Icons.category,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                title: Text(category.name),
                subtitle: category.description != null
                    ? Text(category.description!)
                    : null,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => WordListScreen(categoryId: category.id),
                    ),
                  );
                },
              )),
          const SizedBox(height: 16),
        ],
        if (itemResults.isNotEmpty) ...[
          Text(
            '단어',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          ...itemResults.map((item) {
            final category =
                vocabularyProvider.getCategoryById(item.categoryId);
            return ListTile(
              leading: CircleAvatar(
                backgroundColor:
                    Theme.of(context).colorScheme.primary.withOpacity(0.1),
                child: Text(
                  item.text.substring(0, 1),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(item.text),
              subtitle: category != null ? Text(category.name) : null,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => WordListScreen(
                      categoryId: item.categoryId,
                      highlightItemId: item.id,
                    ),
                  ),
                );
              },
            );
          }),
        ],
      ],
    );
  }
}
