// lib/screens/custom_vocabulary_screen.dart
import 'dart:io'; // For File type
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:connect_aac/services/api_service.dart'; // Direct use or via a provider
import 'package:connect_aac/providers/vocabulary_provider.dart'; // To access categories
import 'package:connect_aac/models/category.dart'; // To use Category model

class CustomVocabularyScreen extends StatefulWidget {
  const CustomVocabularyScreen({super.key});

  @override
  State<CustomVocabularyScreen> createState() => _CustomVocabularyScreenState();
}

class _CustomVocabularyScreenState extends State<CustomVocabularyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();
  String? _selectedCategoryId;
  XFile? _imageFile; // From image_picker
  bool _isSubmitting = false; // Renamed from _isLoading for clarity

  final ImagePicker _picker = ImagePicker();

  // --- Image Picking Logic ---
  Future<void> _pickImage(ImageSource source) async {
    // Prevent picking while submitting
    if (_isSubmitting) return;
    try {
      final pickedFile = await _picker.pickImage(
          source: source,
          imageQuality: 80, // Optional: Reduce image quality for upload size
          maxWidth: 1024, // Optional: Resize image
          maxHeight: 1024,
      );
      if (pickedFile != null) {
         setState(() {
           _imageFile = pickedFile;
         });
      }
    } catch (e) {
      print("Image picking failed: $e");
      if (mounted) { // Check if widget is still mounted before showing SnackBar
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('이미지를 가져오는데 실패했습니다: $e')),
         );
      }
    }
  }

  // --- Form Submission Logic ---
  Future<void> _submitCustomWord() async {
    // Validate form fields
    if (!_formKey.currentState!.validate()) {
      return;
    }
    // Category is validated by the DropdownButtonFormField validator

    // Prevent multiple submissions
    if (_isSubmitting) return;

    setState(() { _isSubmitting = true; });

    try {
      // Get ApiService instance (using Provider is recommended)
      final apiService = Provider.of<ApiService>(context, listen: false);

      await apiService.createCustomVocabulary(
        text: _textController.text.trim(), // Trim whitespace
        categoryId: _selectedCategoryId!,
        imageFile: _imageFile, // Pass the XFile object
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('커스텀 단어가 추가되었습니다.'),
              duration: Duration(seconds: 2), // Shorter duration
          ),
        );
        // Clear the form after successful submission
        _formKey.currentState?.reset(); // Resets validation state
        _textController.clear();
        setState(() {
          _selectedCategoryId = null;
          _imageFile = null;
        });
        // Optional: Refresh custom vocabulary list if displayed elsewhere
        // Provider.of<CustomVocabularyProvider>(context, listen: false).fetchCustomVocabulary();
      }
    } catch (e) {
      print("Failed to add custom vocabulary: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('단어 추가 실패: ${e.toString()}')), // Show specific error if possible
        );
      }
    } finally {
       if (mounted) {
          setState(() { _isSubmitting = false; });
       }
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    // Access categories from VocabularyProvider
    // listen: true so the dropdown updates if categories are fetched later
    final categories = Provider.of<VocabularyProvider>(context).categories;
    final isLoadingCategories = Provider.of<VocabularyProvider>(context).isLoadingCategories;

    return Scaffold( // Using Scaffold directly, integrate with AppScaffold if needed
      // AppBar is handled by HomeScreen's BottomNavigationBar setup typically
      // appBar: AppBar(title: const Text('커스텀 단어 추가')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView( // Use ListView for better scrolling on small devices
            children: [
              TextFormField(
                controller: _textController,
                enabled: !_isSubmitting,
                decoration: const InputDecoration(labelText: '단어 텍스트', prefixIcon: Icon(Icons.text_fields)),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '단어 텍스트를 입력하세요.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Category Dropdown
              DropdownButtonFormField<String>(
                value: _selectedCategoryId,
                hint: const Text('카테고리 선택'),
                // Show loading indicator or disable if categories are loading
                disabledHint: isLoadingCategories ? const Text('카테고리 로딩 중...') : null,
                decoration: const InputDecoration(prefixIcon: Icon(Icons.category)),
                items: isLoadingCategories
                    ? [] // Show empty list while loading
                    : categories.map((Category category) {
                        return DropdownMenuItem<String>(
                          value: category.id,
                          child: Text(category.name),
                        );
                      }).toList(),
                onChanged: _isSubmitting ? null : (value) { // Disable while submitting
                  setState(() {
                    _selectedCategoryId = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return '카테고리를 선택하세요.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // --- Image Picker Section ---
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Image Preview Area
                  Expanded(
                    flex: 2, // Give more space to preview
                    child: Container(
                      height: 120, // Fixed height for preview area
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(8),
                           color: Colors.grey.shade200,
                          ),
                      child: _imageFile == null
                          ? const Center(child: Icon(Icons.image_outlined, size: 40, color: Colors.grey))
                          : ClipRRect( // Clip the image preview
                               borderRadius: BorderRadius.circular(8),
                               child: Image.file(
                                File(_imageFile!.path),
                                fit: BoxFit.cover, // Cover the container
                              ),
                          ),
                    ),
                  ),
                   const SizedBox(width: 16),
                   // Image Picker Buttons
                   Expanded( // Let buttons take remaining space
                    flex: 1,
                     child: Column(
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: [
                         ElevatedButton.icon(
                            icon: const Icon(Icons.photo_library, size: 18),
                            label: const Text('갤러리'),
                             style: ElevatedButton.styleFrom(minimumSize: const Size(100, 36)), // Ensure min size
                            onPressed: _isSubmitting ? null : () => _pickImage(ImageSource.gallery),
                          ),
                           const SizedBox(height: 8),
                          ElevatedButton.icon(
                             icon: const Icon(Icons.camera_alt, size: 18),
                             label: const Text('카메라'),
                             style: ElevatedButton.styleFrom(minimumSize: const Size(100, 36)),
                             onPressed: _isSubmitting ? null : () => _pickImage(ImageSource.camera),
                           ),
                            // Optional: Button to remove selected image
                           if (_imageFile != null)
                              TextButton(
                                  onPressed: _isSubmitting ? null : () => setState(() => _imageFile = null),
                                  child: const Text('이미지 제거', style: TextStyle(color: Colors.redAccent)),
                              )
                       ],
                     ),
                   )
                ],
              ),
               const SizedBox(height: 32), // More spacing before submit button
               // Submit Button
               ElevatedButton(
                   style: ElevatedButton.styleFrom(
                       padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                   onPressed: _isSubmitting ? null : _submitCustomWord,
                   child: _isSubmitting
                       ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white))
                       : const Text('커스텀 단어 저장'),
               ),
            ],
          ),
        ),
      ),
    );
  }
}
