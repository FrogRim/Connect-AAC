// lib/services/tts_service.dart
import 'dart:typed_data';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:audioplayers/audioplayers.dart';
import 'api_service.dart';
import 'package:dio/dio.dart'; // Import DioError for error handling

class TTSService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final ApiService _apiService = ApiService(); // Use ApiService for network calls

  // Simple in-memory cache: Map<cacheKey, audioBytes>
  // Key could be combination of text + voice + rate
  final Map<String, Uint8List> _audioCache = {};

  // Optional: Configure AudioPlayer defaults if needed
  TTSService() {
    // Example: Set release mode for audio player if needed
     _audioPlayer.setReleaseMode(ReleaseMode.stop);
     // Example: Set default volume (can be adjusted later)
     // _audioPlayer.setVolume(1.0);

     // Handle player state changes or errors if necessary
     _audioPlayer.onPlayerStateChanged.listen((state) {
        print("AudioPlayer State: $state");
     });
      _audioPlayer.onPlayerComplete.listen((event) {
         print("AudioPlayer Playback Complete");
      });
  }

  // Initialization (currently not much needed unless setting up player defaults)
  Future<void> initialize() async {
    print("TTS Service Initialized");
    // Perform any async setup if required in the future
  }

  /// Synthesizes speech for the given text using specified voice and rate,
  /// then plays the audio. Uses caching for performance.
  Future<void> speak(
    String text
    //, {required String voiceType, // Make required or get from SettingsProvider elsewhere
    //required double speechRate, // Make required or get from SettingsProvider elsewhere}
) async {
    if (text.isEmpty) {
      print("TTS Error: Cannot speak empty text.");
      return;
    }

    // Generate a unique key for caching based on content and settings
    //final cacheKey = "$text|$voiceType|$speechRate";
    final cacheKey = "text";

    try {
       // Check if audio is already playing, stop it first
       if (_audioPlayer.state == PlayerState.playing) {
           await _audioPlayer.stop();
       }

      Uint8List? audioBytes;

      // 1. Check cache
      if (_audioCache.containsKey(cacheKey)) {
        print("TTS Cache HIT for key: $cacheKey");
        audioBytes = _audioCache[cacheKey];
      } else {
        print("TTS Cache MISS for key: $cacheKey. Fetching from API...");
        // 2. Fetch from API if not in cache
        try {
           final response = await _apiService.synthesizeTTS({
               'text': text,
               //'voice_type': voiceType,
               //'speech_rate': speechRate,
           });

           // API returns binary data (List<int>), convert to Uint8List
           if (response.data is List<int>) {
              audioBytes = Uint8List.fromList(response.data as List<int>);
              // Add to cache
              _audioCache[cacheKey] = audioBytes;
              print("TTS Audio fetched and cached (${audioBytes.lengthInBytes} bytes).");
           } else {
              print("TTS Error: API did not return expected binary data. Response type: ${response.data.runtimeType}");
              // Fallback or throw specific error
           }

        } on DioError catch (e) {
             print('TTS API Error: ${e.response?.statusCode} - ${e.response?.data ?? e.message}');
             // Optionally re-throw or handle specific errors (e.g., rate limits)
             // return; // Stop execution on API error
             throw Exception('Failed to synthesize speech via API.'); // Re-throw
        } catch (e) {
            print('TTS Unexpected Error during API call: $e');
            throw Exception('Unexpected error during speech synthesis.'); // Re-throw
            // return;
        }
      }

      // 3. Play audio if bytes are available
      if (audioBytes != null && audioBytes.isNotEmpty) {
        print("Playing TTS audio...");
        // Use BytesSource for playing from memory
        await _audioPlayer.play(BytesSource(audioBytes));
      } else {
         print("TTS Error: Audio data is null or empty after fetch/cache check.");
      }

    } catch (e) {
      print('TTS Playback Error: $e');
      // Handle playback errors (e.g., show a message to the user)
       // Consider stopping the player in case of error
       await _audioPlayer.stop();
    }
  }

   // Optional: Method to stop any ongoing playback
   Future<void> stop() async {
      print("Stopping TTS playback.");
      await _audioPlayer.stop();
   }

   // Optional: Method to clear the cache
   void clearCache() {
      print("Clearing TTS cache.");
      _audioCache.clear();
   }

   // Optional: Dispose resources when service is no longer needed
   // (e.g., in the dispose method of a StatefulWidget or Provider)
   void dispose() {
       print("Disposing TTS Service");
       _audioPlayer.dispose();
   }
}
