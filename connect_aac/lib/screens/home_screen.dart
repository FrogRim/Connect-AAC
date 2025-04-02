// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/vocabulary_provider.dart';
import '../widgets/favorite_grid.dart';
import '../widgets/app_scaffold.dart';
import '../utils/app_theme.dart';
import 'category_screen.dart';
import 'chat_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Connect AAC',
      showBackButton: false,
      body: RefreshIndicator(
        onRefresh: () async {
          await Provider.of<VocabularyProvider>(context, listen: false)
              .refreshData();
          await Provider.of<FavoritesProvider>(context, listen: false)
              .refreshFavorites();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 앱 로고 및 제목
                _buildHeader(context),

                const SizedBox(height: 32),

                // 즐겨찾기 섹션
                _buildSectionTitle(context, '즐겨찾기 표현'),
                const SizedBox(height: 16),
                const FavoriteGrid(),

                const SizedBox(height: 32),

                // 메뉴 섹션
                _buildSectionTitle(context, '메뉴'),
                const SizedBox(height: 16),
                _buildNavigationCards(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 앱 헤더 섹션
  Widget _buildHeader(BuildContext context) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        decoration: AppTheme.gradientDecoration(radius: 24),
        child: Column(
          children: [
            // 앱 로고
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.sign_language,
                size: 60,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            // 앱 제목
            const Text(
              'Connect AAC',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            // 앱 설명
            const Text(
              '보완대체의사소통 앱',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 섹션 제목
  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 24,
            decoration: BoxDecoration(
              color: AppTheme.accentColor,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  // 메뉴 카드 영역
  Widget _buildNavigationCards(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildNavigationCard(
          context,
          '카테고리',
          Icons.category_rounded,
          AppTheme.primaryColor,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CategoryScreen()),
          ),
        ),
        _buildNavigationCard(
          context,
          'AI 챗봇',
          Icons.chat_rounded,
          AppTheme.secondaryColor,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ChatScreen()),
          ),
        ),
        _buildNavigationCard(
          context,
          '설정',
          Icons.settings_rounded,
          AppTheme.accentColor,
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SettingsScreen()),
          ),
        ),
      ],
    );
  }

  // 각 메뉴 카드
  Widget _buildNavigationCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      shadowColor: color.withOpacity(0.3),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  icon,
                  size: 30,
                  color: color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
