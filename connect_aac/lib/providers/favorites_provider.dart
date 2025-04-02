// lib/providers/favorites_provider.dart
import 'package:flutter/material.dart';
import '../models/vocabulary_item.dart';
import '../services/api_service.dart';

class FavoritesProvider extends ChangeNotifier {
  List<VocabularyItem> _favorites = [];
  bool _isLoading = true;
  String? _error;

  // 즐겨찾기 ID와 어휘 항목 ID 매핑
  Map<String, String> _favoriteIds = {}; // Map<item_id, favorite_id>

  // API 서비스
  final ApiService _apiService = ApiService();

  // Getters
  List<VocabularyItem> get favorites => _favorites;
  bool get isLoading => _isLoading;
  String? get error => _error;

  FavoritesProvider() {
    _loadFavorites();
  }

  // 즐겨찾기 로드
  Future<void> _loadFavorites() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 백엔드에서 즐겨찾기 목록 가져오기
      final items = await _apiService.getFavorites();
      _favorites = items;

      // 즐겨찾기 ID 매핑 구성
      _favoriteIds = {};
      for (var item in items) {
        _favoriteIds[item.id] = item.id; // 실제 API 응답에서는 favorite_id 매핑 필요
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('즐겨찾기 로드 오류: $e');
      _error = '즐겨찾기를 불러오는 중 오류가 발생했습니다.';
      _isLoading = false;
      notifyListeners();
    }
  }

  // 즐겨찾기 새로고침
  Future<void> refreshFavorites() async {
    await _loadFavorites();
  }

  // 즐겨찾기 여부 확인
  bool isFavorite(String itemId) {
    return _favoriteIds.containsKey(itemId);
  }

  // 즐겨찾기 토글
  Future<bool> toggleFavorite(String itemId) async {
    try {
      if (isFavorite(itemId)) {
        // 즐겨찾기 제거
        final favoriteId = _favoriteIds[itemId];
        if (favoriteId != null) {
          final success = await _apiService.removeFavorite(favoriteId);

          if (success) {
            _favorites.removeWhere((item) => item.id == itemId);
            _favoriteIds.remove(itemId);
            notifyListeners();
          }

          return success;
        }
        return false;
      } else {
        // 즐겨찾기 추가
        final response = await _apiService.addFavorite(itemId);

        if (response.containsKey('favorite_id')) {
          // 실제 어휘 항목 객체를 가져와서 추가해야 함
          // 임시로 ID만 사용하여 구현
          final item = _getFavoriteItemById(itemId);

          if (item != null) {
            _favorites.add(item);
            _favoriteIds[itemId] = response['favorite_id'];
            notifyListeners();
            return true;
          }
        }
        return false;
      }
    } catch (e) {
      print('즐겨찾기 토글 오류: $e');
      return false;
    }
  }

  // 임시 메서드: 일반적으로는 VocabularyProvider에서 아이템을 가져와야 함
  VocabularyItem? _getFavoriteItemById(String itemId) {
    try {
      // 여기서는 간단히 처리하기 위해 임시 객체 생성
      // 실제 구현에서는 Provider 간 의존성 적절히 처리 필요
      return VocabularyItem(
        id: itemId,
        text: "아이템 $itemId",
        imageAsset: "assets/images/placeholder.png",
        categoryId: "unknown",
      );
    } catch (e) {
      return null;
    }
  }

  // 즐겨찾기 순서 변경
  Future<bool> reorderFavorites(
      List<String> favoriteIds, List<int> newOrders) async {
    try {
      // 백엔드 API 호출 (실제 구현 필요)
      // final success = await _apiService.updateFavoriteOrder(favoriteIds, newOrders);

      // 임시 구현: 로컬에서만 순서 변경
      // 실제 구현 시 백엔드 API 연동 필요
      final tempFavorites = List<VocabularyItem>.from(_favorites);
      _favorites = [];

      for (int i = 0; i < favoriteIds.length; i++) {
        final favoriteId = favoriteIds[i];
        final item = tempFavorites.firstWhere(
          (item) => _favoriteIds[item.id] == favoriteId,
          orElse: () => tempFavorites[0], // 오류 방지
        );

        _favorites.add(item);
      }

      notifyListeners();
      return true;
    } catch (e) {
      print('즐겨찾기 순서 변경 오류: $e');
      return false;
    }
  }

  Future<bool> clearFavorites() async {
    try {
      await _apiService.clearFavorites();
      _favorites.clear();
      notifyListeners();
      return true;
    } catch (e) {
      print('즐겨찾기 초기화 오류: $e');
      return false;
    }
  }
}
