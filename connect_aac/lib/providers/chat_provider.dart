// lib/providers/chat_provider.dart
import 'package:flutter/material.dart';
import 'package:connect_aac/services/api_service.dart';
// Import ChatMessage model if you create one
//import 'package:connect_aac/models/chat_message.dart';

class ChatProvider extends ChangeNotifier {
   final ApiService _apiService;
   bool _isLoading = false;
   List<dynamic> _messages = []; // Replace 'dynamic' with ChatMessage model

   ChatProvider(this._apiService) {
       // Optionally load initial messages
       // fetchMessages();
   }

   // --- Getters ---
   List<dynamic> get messages => _messages;
   bool get isLoading => _isLoading;

   // --- Internal Loading Setter ---
    Future<void> _setLoading(bool value) async {
     if (_isLoading != value) {
        _isLoading = value;
        WidgetsBinding.instance.addPostFrameCallback((_) {
             if (hasListeners) notifyListeners();
        });
     }
   }

   // --- Methods ---
   Future<void> fetchMessages({int limit = 20, int? offset}) async {
       if (_isLoading) return;
       await _setLoading(true);
       try {
           final response = await _apiService.getChatMessages(limit: limit, offset: offset);
           // TODO: Parse response and update _messages list
           // Handle pagination logic if necessary
           final List<dynamic> fetchedMessages = response.data['messages'] ?? [];
           // Replace with proper model mapping and list management
           _messages = fetchedMessages; // Simplistic replacement for now
           notifyListeners();
       } catch (e) {
           print("Error fetching chat messages: $e");
       } finally {
           await _setLoading(false);
       }
   }

    Future<void> sendMessage(String content, String messageType) async {
       if (_isLoading) return;
        // Optional: Optimistic UI update - add user message immediately
       final userMessage = { // Replace with ChatMessage object
           'content': content,
           'message_type': messageType,
           'is_ai': false,
           'created_at': DateTime.now().toIso8601String(),
           // Add temporary ID if needed
       };
        _messages.insert(0, userMessage); // Add to beginning of list
        notifyListeners();

       await _setLoading(true); // Indicate loading for AI response
       try {
           final response = await _apiService.sendChatMessage({
               'content': content,
               'message_type': messageType,
           });
            // TODO: Process response, potentially update user message ID
            // and add AI response message to the list
            final aiResponse = response.data['response']; // Assuming structure from API doc
            if (aiResponse != null) {
                _messages.insert(0, aiResponse); // Add AI response
            }
            // Consider re-fetching or just adding the response
            notifyListeners();
       } catch (e) {
            print("Error sending chat message: $e");
             // Optional: Remove optimistic user message on error
            _messages.remove(userMessage);
            notifyListeners();
            // Show error message to user
       } finally {
            await _setLoading(false);
       }
   }

    Future<void> deleteConversation() async {
        if (_isLoading) return;
        await _setLoading(true);
        try {
            await _apiService.deleteChatMessages();
            _messages = []; // Clear local messages
            notifyListeners();
        } catch (e) {
             print("Error deleting chat messages: $e");
        } finally {
            await _setLoading(false);
        }
    }
  void clearMessages() {
        _messages = [];
        notifyListeners();
        print("Local chat messages cleared.");
    }
}
