// lib/widgets/word_card.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/vocabulary_item.dart';
import '../providers/favorites_provider.dart';
import '../providers/settings_provider.dart';
import '../services/tts_service.dart';
import '../utils/app_theme.dart';

class WordCard extends StatelessWidget {
  final VocabularyItem item;
  final bool isHighlighted;

  const WordCard({
    super.key,
    required this.item,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final isFavorite = favoritesProvider.isFavorite(item.id);
    final ttsService = TTSService();

    // 설정에 따른 크기 조정
    final double iconSize = 80 * settingsProvider.iconSize;
    final double fontSize = 18 * settingsProvider.textSize;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isHighlighted
                ? AppTheme.primaryColor.withOpacity(0.3)
                : Colors.black.withOpacity(0.05),
            blurRadius: isHighlighted ? 10 : 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: isHighlighted
              ? BorderSide(color: AppTheme.primaryColor, width: 2)
              : BorderSide.none,
        ),
        child: InkWell(
          onTap: () {
            ttsService.speak(item.text);

            // 리플 효과 후 짧은 하이라이트 효과
            Future.delayed(const Duration(milliseconds: 200), () {
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('"${item.text}" 선택됨'),
                  duration: const Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            });
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 이미지 컨테이너
                Expanded(
                  child: Container(
                    width: iconSize,
                    height: iconSize,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: _buildImage(context, iconSize),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // 텍스트
                Text(
                  item.text,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                // 즐겨찾기 버튼
                IconButton(
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                      return ScaleTransition(scale: animation, child: child);
                    },
                    child: Icon(
                      isFavorite
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      key: ValueKey<bool>(isFavorite),
                      color: isFavorite ? Colors.amber : Colors.grey,
                      size: 28,
                    ),
                  ),
                  onPressed: () {
                    favoritesProvider.toggleFavorite(item.id);

                    // 피드백 제공
                    final message =
                        isFavorite ? '즐겨찾기에서 제거되었습니다' : '즐겨찾기에 추가되었습니다';

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(message),
                        duration: const Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 이미지 빌드 함수
  Widget _buildImage(BuildContext context, double size) {
    // 네트워크 또는 애셋 이미지 표시
    if (item.imageAsset.startsWith('http')) {
      // 네트워크 이미지
      return Image.network(
        item.imageAsset,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorImage(context, size);
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            ),
          );
        },
      );
    } else {
      // 애셋 이미지
      return Image.asset(
        item.imageAsset,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorImage(context, size);
        },
      );
    }
  }

  // 이미지 로드 실패 시 표시할 위젯
  Widget _buildErrorImage(BuildContext context, double size) {
    return Container(
      width: size,
      height: size,
      color: AppTheme.primaryColor.withOpacity(0.1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported_rounded,
            size: size * 0.4,
            color: AppTheme.primaryColor.withOpacity(0.7),
          ),
          const SizedBox(height: 4),
          Text(
            item.text,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.primaryColor.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
