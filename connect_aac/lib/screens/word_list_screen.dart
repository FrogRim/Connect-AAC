//Words in a category
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/vocabulary_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/word_card.dart';
import '../models/vocabulary_item.dart';

class WordListScreen extends StatelessWidget {
  final String categoryId;
  final String? highlightItemId;

  const WordListScreen({
    super.key,
    required this.categoryId,
    this.highlightItemId,
  });

  @override
  Widget build(BuildContext context) {
    final vocabularyProvider = Provider.of<VocabularyProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final category = vocabularyProvider.getCategoryById(categoryId);
    final items = vocabularyProvider.getItemsByCategory(categoryId);

    if (category == null) {
      return AppScaffold(
        title: '오류',
        body: const Center(
          child: Text('카테고리를 찾을 수 없습니다.'),
        ),
      );
    }

    return AppScaffold(
      title: category.name,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category description
          if (category.description != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                category.description!,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onBackground
                          .withOpacity(0.7),
                    ),
              ),
            ),

          // Word grid
          Expanded(
            child: FutureBuilder<List<VocabularyItem>>(
              future: items,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('오류: ${snapshot.error}'));
                }

                final items = snapshot.data ?? [];
                return GridView.builder(
                  padding: const EdgeInsets.all(16.0),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: settingsProvider.gridColumns,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return WordCard(
                      item: item,
                      isHighlighted: item.id == highlightItemId,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
