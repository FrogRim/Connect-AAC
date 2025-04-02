// lib/providers/vocabulary_provider.dart
import 'package:flutter/material.dart';
import '../models/vocabulary_item.dart';
import '../models/category.dart';
import '../services/api_service.dart';

class VocabularyProvider extends ChangeNotifier {
  List<Category> _categories = [];
  List<VocabularyItem> _vocabularyItems = [];
  bool _isLoading = true;
  String _searchQuery = '';

  // 에러 상태 관리
  String? _error;

  // API 서비스
  final ApiService _apiService = ApiService();

  // Getters
  List<Category> get categories => _categories;
  List<VocabularyItem> get vocabularyItems => _vocabularyItems;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String? get error => _error;

  VocabularyProvider() {
    _initializeData();
  }

  // 데이터 초기화 - 백엔드에서 데이터 가져오기
  Future<void> _initializeData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 카테고리 가져오기
      _categories = await _apiService.getCategories();

      // 모든 카테고리의 어휘 항목 가져오기
      _vocabularyItems = [];
      for (var category in _categories) {
        final items = await _apiService.getVocabularyByCategory(category.id);
        _vocabularyItems.addAll(items);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('어휘 데이터 초기화 오류: $e');
      _error = '데이터를 불러오는 중 오류가 발생했습니다.';
      _isLoading = false;
      notifyListeners();

      // 오류 발생 시에도 로컬 데이터 시도 (나중에 구현 예정)
    }
  }

  // 데이터 새로고침
  Future<void> refreshData() async {
    await _initializeData();
  }

  // 카테고리별 어휘 항목 가져오기
  Future<List<VocabularyItem>> getItemsByCategory(String categoryId) async {
    try {
      // 이미 로드된 데이터가 있으면 캐시에서 반환
      if (_vocabularyItems.isNotEmpty) {
        return _vocabularyItems
            .where((item) => item.categoryId == categoryId)
            .toList();
      }

      // 아직 데이터가 로드되지 않았으면 API 호출
      return await _apiService.getVocabularyByCategory(categoryId);
    } catch (e) {
      print('카테고리별 어휘 항목 조회 오류: $e');
      return [];
    }
  }

  // ID로 카테고리 찾기
  Category? getCategoryById(String categoryId) {
    try {
      return _categories.firstWhere((category) => category.id == categoryId);
    } catch (e) {
      return null;
    }
  }

  // ID로 어휘 항목 찾기
  VocabularyItem? getItemById(String itemId) {
    try {
      return _vocabularyItems.firstWhere((item) => item.id == itemId);
    } catch (e) {
      return null;
    }
  }

  // 검색 쿼리 설정
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // 검색 결과 가져오기 - 백엔드 API 사용
  Future<List<VocabularyItem>> getSearchResults() async {
    if (_searchQuery.isEmpty) {
      return [];
    }

    try {
      return await _apiService.searchVocabulary(_searchQuery);
    } catch (e) {
      print('검색 오류: $e');

      // API 오류 시 로컬 검색 수행
      return _vocabularyItems.where((item) {
        return item.text.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }
  }

  // 카테고리 검색 결과
  List<Category> get searchCategories {
    if (_searchQuery.isEmpty) {
      return [];
    }

    return _categories.where((category) {
      return category.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  // 검색 결과 getter
  List<VocabularyItem> get searchResults {
    if (_searchQuery.isEmpty) {
      return [];
    }

    return _vocabularyItems.where((item) {
      return item.text.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  // 어휘 사용 기록 추가
  Future<bool> recordItemUsage(String itemId) async {
    try {
      await _apiService.addUsageRecord(itemId);
      return true;
    } catch (e) {
      print('사용 기록 추가 오류: $e');
      return false;
    }
  }

  // 최근 사용 항목 가져오기
  Future<List<VocabularyItem>> getRecentlyUsedItems({int limit = 10}) async {
    try {
      final recentUsage = await _apiService.getRecentUsage(limit: limit);
      List<VocabularyItem> recentItems = [];

      for (var usage in recentUsage) {
        final itemId = usage['item_id'];
        final item = getItemById(itemId);

        if (item != null) {
          recentItems.add(item);
        }
      }

      return recentItems;
    } catch (e) {
      print('최근 사용 항목 조회 오류: $e');
      return [];
    }
  }
}
