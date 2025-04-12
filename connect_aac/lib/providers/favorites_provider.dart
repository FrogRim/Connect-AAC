// lib/providers/favorites_provider.dart
import 'package:flutter/material.dart';
import 'package:connect_aac/services/api_service.dart';
import 'package:connect_aac/models/favorite.dart'; // Use Favorite model

class FavoritesProvider extends ChangeNotifier {
  final ApiService _apiService;
   List<Favorite> _favorites = []; // Use Favorite model
   bool _isLoading = false;
   String? _error;
   

   FavoritesProvider(this._apiService) {
     // Optionally fetch favorites immediately, or lazily when needed
     // fetchFavorites();
   }

   // --- Getters ---
   List<Favorite> get favorites => _favorites;
   bool get isLoading => _isLoading;
   String? get error => _error;

   // --- Internal Loading Setter ---
   Future<void> _setLoading(bool value) async {
     if (_isLoading != value) {
        _isLoading = value;
        WidgetsBinding.instance.addPostFrameCallback((_) {
             if (hasListeners) notifyListeners();
        });
     }
   }

   // --- Data Fetching ---
   Future<void> fetchFavorites() async {
     // Prevent concurrent fetches
     if (_isLoading) return;

     await _setLoading(true);
     try {
       final response = await _apiService.getFavorites();
       final List<dynamic> favJson = response.data['favorites'] ?? [];
       _favorites = favJson.map((json) => Favorite.fromJson(json)).toList();
        // Sort favorites by display order
       _favorites.sort((a,b) => a.displayOrder.compareTo(b.displayOrder));
     } catch (e) {
       print("Error fetching favorites: $e");
       _favorites = []; // Clear on error
     } finally {
        await _setLoading(false);
     }
   }

   // --- Modification Methods ---
    Future<bool> addFavorite(String itemId) async {
      // Prevent adding if already favorited
      if (isFavorite(itemId)) {
         print("Item $itemId already in favorites.");
         return false;
      }
      // Avoid concurrent modifications
      if (_isLoading) return false;

      await _setLoading(true);
      try {
        await _apiService.addFavorite(itemId);
        // Refetch favorites to get the updated list and order from the server
        await fetchFavorites(); // This will set loading to false and notify listeners
        return true;
      } catch (e) {
        print("Error adding favorite: $e");
        await _setLoading(false); // Ensure loading is false on error
        return false;
      }
    }

     // Deletes a favorite based on the VocabularyItem's ID
     Future<bool> deleteFavoriteByItemId(String itemId) async {
         final favoriteId = getFavoriteId(itemId);
         if (favoriteId == null) {
             print("Item $itemId not found in favorites to delete.");
             return false; // Not favorited
         }
          // Avoid concurrent modifications
         if (_isLoading) return false;

         return await deleteFavorite(favoriteId); // Reuse the delete by favorite ID logic
     }

     // Deletes a favorite based on the Favorite's own ID
      Future<bool> deleteFavorite(String favoriteId) async {
           // Avoid concurrent modifications
          if (_isLoading) return false;

          await _setLoading(true);
          try {
              await _apiService.deleteFavorite(favoriteId);
              // Refetch the updated list from the server
              await fetchFavorites(); // This will set loading to false and notify
              return true;
          } catch (e) {
              print("Error deleting favorite with ID $favoriteId: $e");
              await _setLoading(false); // Ensure loading is false on error
              return false;
          }
      }

     // --- Helper Methods ---
     // Method to check if an item is already favorited
     bool isFavorite(String itemId) {
       return _favorites.any((fav) => fav.itemId == itemId);
     }

      // Get favorite ID for a given item ID
      String? getFavoriteId(String itemId) {
        try {
          // Use firstWhereOrNull for safety if using 'collection' package
          return _favorites.firstWhere((fav) => fav.itemId == itemId).favoriteId;
        } catch (e) {
          return null; // Not found
        }
      }

      Future<void> refreshFavorites() async
      {
        await fetchFavorites();
      }
}
