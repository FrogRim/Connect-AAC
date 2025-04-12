// lib/providers/settings_provider.dart
import 'package:flutter/material.dart';
import 'package:connect_aac/services/api_service.dart';
// Import flutter_secure_storage or shared_preferences for local caching if needed
// import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
   final ApiService _apiService;
   bool _isLoading = false;

   // --- Default Settings ---
   ThemeMode _themeMode = ThemeMode.system;
   bool _ttsEnabled = true;
   String _voiceType = 'default'; // Example: Get actual default from API/Config
   double _speechRate = 1.0;
   double _textSize = 16.0; // Example default text size
   double _iconSize = 24.0; // Example default icon size
   // Add other settings properties as needed

   SettingsProvider(this._apiService) {
     // Load settings from API or local storage on initialization
     loadSettings();
   }

   // --- Getters ---
   ThemeMode get themeMode => _themeMode;
   bool get isLoading => _isLoading;
   bool get ttsEnabled => _ttsEnabled;
   String get voiceType => _voiceType;
   double get speechRate => _speechRate;
   double get textSize => _textSize;
   double get iconSize => _iconSize;

   // --- Internal Loading Setter ---
    Future<void> _setLoading(bool value) async {
     if (_isLoading != value) {
        _isLoading = value;
         WidgetsBinding.instance.addPostFrameCallback((_) {
             if (hasListeners) notifyListeners();
         });
     }
   }

   // --- Load and Save Settings ---
   Future<void> loadSettings() async {
       // TODO: Consider adding local caching (SharedPreferences) for faster load
       // and fallback if API is unavailable.
       await _setLoading(true);
       try {
           final response = await _apiService.getSettings();
           final settingsData = response.data; // Assuming response.data contains the settings map

           _themeMode = _parseThemeMode(settingsData['theme_mode'] ?? 'system');
           _ttsEnabled = (settingsData['tts_enabled'] ?? true) as bool;
           _voiceType = (settingsData['voice_type'] ?? 'default') as String;
           _speechRate = (settingsData['speech_rate'] ?? 1.0).toDouble(); // Ensure double
           _textSize = (settingsData['text_size'] ?? 16.0).toDouble();
           _iconSize = (settingsData['icon_size'] ?? 24.0).toDouble();
           // Load other settings...

           print("Settings loaded successfully.");

       } catch(e) {
           print("Failed to load settings from API: $e. Using defaults.");
           // Keep default settings on error
       } finally {
           await _setLoading(false);
       }
   }

   // Saves all current settings to the backend
   Future<bool> saveSettings() async {
       if (_isLoading) return false; // Prevent concurrent saves
       await _setLoading(true);
       try {
            final settingsData = {
               'theme_mode': _themeMode.toString().split('.').last,
               'tts_enabled': _ttsEnabled,
               'voice_type': _voiceType,
               'speech_rate': _speechRate,
               'text_size': _textSize,
               'icon_size': _iconSize,
               // Add other settings...
           };
           await _apiService.saveSettings(settingsData);
           print("Settings saved successfully.");
           await _setLoading(false);
           return true;
       } catch(e) {
           print("Failed to save settings: $e");
           await _setLoading(false);
           return false;
       }
   }

   // --- Individual Setting Modifiers ---
   // These methods update the local state and trigger a save.
   void setThemeMode(ThemeMode mode) {
     if (_themeMode != mode) {
       _themeMode = mode;
       notifyListeners();
       saveSettings(); // Save all settings when one changes
     }
   }

    void setTtsEnabled(bool enabled) {
     if (_ttsEnabled != enabled) {
       _ttsEnabled = enabled;
       notifyListeners();
       saveSettings();
     }
   }

    void setVoiceType(String voice) {
     if (_voiceType != voice) {
       _voiceType = voice;
       notifyListeners();
       saveSettings();
     }
   }

   void setSpeechRate(double rate) {
     // Add validation/clamping if needed (e.g., rate between 0.5 and 2.0)
     rate = rate.clamp(0.5, 2.0);
     if (_speechRate != rate) {
       _speechRate = rate;
       notifyListeners();
       saveSettings();
     }
   }

     void setTextSize(double size) {
     // Add validation/clamping if needed
     size = size.clamp(12.0, 30.0); // Example range
     if (_textSize != size) {
       _textSize = size;
       notifyListeners();
       saveSettings();
     }
   }

    void setIconSize(double size) {
     // Add validation/clamping if needed
      size = size.clamp(18.0, 48.0); // Example range
     if (_iconSize != size) {
       _iconSize = size;
       notifyListeners();
       saveSettings();
     }
   }


   // --- Helper Methods ---
    ThemeMode _parseThemeMode(String? modeStr) {
       switch (modeStr?.toLowerCase()) {
         case 'light': return ThemeMode.light;
         case 'dark': return ThemeMode.dark;
         default: return ThemeMode.system;
       }
     }
}
