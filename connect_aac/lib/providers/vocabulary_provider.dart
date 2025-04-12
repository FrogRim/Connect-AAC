// lib/providers/vocabulary_provider.dart
import 'package:flutter/material.dart';
import 'package:connect_aac/services/api_service.dart';
import 'package:connect_aac/models/category.dart';
import 'package:connect_aac/models/vocabulary_item.dart';

class VocabularyProvider extends ChangeNotifier {
  final ApiService _apiService;
  List<Category> _categories = []; // Use Category model
  List<VocabularyItem> _items = []; // Use VocabularyItem model (items for current category)
  bool _isLoadingCategories = false;
  bool _isLoadingItems = false;
  bool _isLoadingSearch = false;
  String _searchQuery = '';
  List<VocabularyItem> _searchResults = []; // Use VocabularyItem model
  List<Category> _searchCategories = []; // Use Category model

  VocabularyProvider(this._apiService) {
    fetchCategories(); // Fetch categories on initialization
  }

  // --- Getters ---
  List<Category> get categories => _categories;
  List<VocabularyItem> get items => _items; // Items for the current category
  bool get isLoading => _isLoadingCategories || _isLoadingItems || _isLoadingSearch; // Combined loading state
  bool get isLoadingCategories => _isLoadingCategories;
  bool get isLoadingItems => _isLoadingItems;
  bool get isLoadingSearch => _isLoadingSearch;
  String get searchQuery => _searchQuery;
  List<VocabularyItem> get searchResults => _searchResults;
  List<Category> get searchCategories => _searchCategories;

  // --- Internal Loading Setters ---
  // These help manage specific loading states and notify listeners
  Future<void> _setLoadingCategories(bool value) async {
    if (_isLoadingCategories != value) {
      _isLoadingCategories = value;
      // Use WidgetsBinding to prevent calling notifyListeners during build phase
      WidgetsBinding.instance.addPostFrameCallback((_) {
          if (hasListeners) notifyListeners();
      });
    }
  }

  Future<void> _setLoadingItems(bool value) async {
    if (_isLoadingItems != value) {
      _isLoadingItems = value;
      WidgetsBinding.instance.addPostFrameCallback((_) {
           if (hasListeners) notifyListeners();
      });
    }
  }

    Future<void> _setLoadingSearch(bool value) async {
    if (_isLoadingSearch != value) {
      _isLoadingSearch = value;
       WidgetsBinding.instance.addPostFrameCallback((_) {
           if (hasListeners) notifyListeners();
       });
    }
  }


  // --- Data Fetching Methods ---
  Future<void> fetchCategories() async {
    await _setLoadingCategories(true);
    try {
      final response = await _apiService.getCategories();
      // Map JSON list to List<Category>
      final List<dynamic> categoryJson = response.data['categories'] ?? [];
      _categories = categoryJson.map((json) => Category.fromJson(json)).toList();
      // Sort categories by display order
      _categories.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

    } catch (e) {
      print("Error fetching categories: $e");
      _categories = []; // Clear on error to indicate failure
    } finally {
       await _setLoadingCategories(false);
    }
  }

    Future<void> fetchVocabularyItems({required String categoryId}) async {
      await _setLoadingItems(true);
      // Don't clear items immediately if you want to show old items while loading new ones
      // _items = [];
      // notifyListeners(); // Update UI to show loading for items
      try {
        // API 3.2 fetches vocabulary for a specific category
        final response = await _apiService.getVocabularyByCategory(categoryId);
         final List<dynamic> itemJson = response.data['items'] ?? [];
         _items = itemJson.map((json) => VocabularyItem.fromJson(json)).toList();
         // Sort items by display order
         _items.sort((a,b) => a.displayOrder.compareTo(b.displayOrder));
      } catch (e) {
         print("Error fetching vocabulary items for category $categoryId: $e");
         _items = []; // Clear items on error
      } finally {
         await _setLoadingItems(false);
      }
    }

    // --- Search Methods ---
    Future<void> search(String query) async {
       _searchQuery = query.trim(); // Trim whitespace
       if (_searchQuery.isEmpty) {
         clearSearch(); // Clear results if query is empty
         return;
       }

       await _setLoadingSearch(true);
       try {
         // Search items via API
         final itemResponse = await _apiService.searchVocabulary(query: _searchQuery);
         final List<dynamic> itemJson = itemResponse.data['items'] ?? [];
         _searchResults = itemJson.map((json) => VocabularyItem.fromJson(json)).toList();

         // Client-side category search (can be slow for large category lists)
         // Consider a dedicated backend endpoint for category search if performance is an issue.
         _searchCategories = _categories.where((cat) =>
            cat.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (cat.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false)
         ).toList();

       } catch (e) {
         print("Error searching: $e");
         _searchResults = [];
         _searchCategories = [];
       } finally {
         await _setLoadingSearch(false);
       }
    }

     // Called when the search input changes
     void setSearchQuery(String query) {
       if (query.isEmpty) {
          clearSearch();
       } else {
          search(query);
       }
     }

      // Clears search query and results
     void clearSearch() {
         _searchQuery = '';
         _searchResults = [];
         _searchCategories = [];
         _isLoadingSearch = false; // Ensure loading is off
         notifyListeners();
     }

    // --- Helper Methods ---
    // Helper to get category by ID
    Category? getCategoryById(String id) {
        try {
          // Use firstWhereOrNull for safer lookup (requires collection package)
          // Or use try-catch
          return _categories.firstWhere((cat) => cat.id == id);
        } catch (e) {
          return null; // Not found
        }
      }
}
