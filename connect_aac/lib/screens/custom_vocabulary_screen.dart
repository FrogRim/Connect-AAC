// lib/screens/custom_vocabulary_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../models/category.dart';
import '../models/vocabulary_item.dart';
import '../providers/vocabulary_provider.dart';
import '../services/api_service.dart';
import '../widgets/app_scaffold.dart';

class CustomVocabularyScreen extends StatefulWidget {
  final VocabularyItem? editItem; // 편집할 아이템 (신규 생성 시 null)

  const CustomVocabularyScreen({
    super.key,
    this.editItem,
  });

  @override
  State<CustomVocabularyScreen> createState() => _CustomVocabularyScreenState();
}

class _CustomVocabularyScreenState extends State<CustomVocabularyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController();

  String? _selectedCategoryId;
  File? _imageFile;
  String? _imagePath;
  bool _isLoading = false;
  String? _errorMessage;
  List<Category> _categories = [];

  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadCategories();

    // 편집 모드인 경우 기존 값 설정
    if (widget.editItem != null) {
      _textController.text = widget.editItem!.text;
      _selectedCategoryId = widget.editItem!.categoryId;
      _imagePath = widget.editItem!.imageAsset;
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  // 카테고리 목록 로드
  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final vocabularyProvider =
          Provider.of<VocabularyProvider>(context, listen: false);
      _categories = vocabularyProvider.categories;

      // 아직 카테고리가 로드되지 않은 경우
      if (_categories.isEmpty) {
        _categories = await _apiService.getCategories();
      }

      // 초기 카테고리가 선택되지 않은 경우, 첫 번째 카테고리 선택
      if (_selectedCategoryId == null && _categories.isNotEmpty) {
        _selectedCategoryId = _categories.first.id;
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('카테고리 로드 오류: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = '카테고리를 불러오는 중 오류가 발생했습니다.';
      });
    }
  }

  // 이미지 선택
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  // 카메라로 이미지 촬영
  Future<void> _takePhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  // 이미지 선택 옵션 다이얼로그
  Future<void> _showImageSourceDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('이미지 선택'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('갤러리에서 선택'),
              onTap: () {
                Navigator.pop(context);
                _pickImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('카메라로 촬영'),
              onTap: () {
                Navigator.pop(context);
                _takePhoto();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
        ],
      ),
    );
  }

  // 어휘 저장
  Future<void> _saveCustomVocabulary() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategoryId == null) {
        setState(() {
          _errorMessage = '카테고리를 선택해주세요.';
        });
        return;
      }

      if (_imageFile == null && _imagePath == null) {
        setState(() {
          _errorMessage = '이미지를 선택해주세요.';
        });
        return;
      }

      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        String imagePath = _imagePath ?? '';

        // 이미지 파일이 있는 경우 업로드
        if (_imageFile != null) {
          imagePath = await _apiService.uploadImage(_imageFile!, 'vocabulary');
        }

        // 편집 모드
        if (widget.editItem != null) {
          // API 연동 시 구현
          // await _apiService.updateCustomVocabulary(
          //   widget.editItem!.id,
          //   _textController.text,
          //   _selectedCategoryId!,
          //   imagePath,
          // );

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('어휘가 수정되었습니다.')),
          );
        }
        // 새 어휘 생성 모드
        else {
          // API 연동 시 구현
          // await _apiService.createCustomVocabulary(
          //   _textController.text,
          //   _selectedCategoryId!,
          //   imagePath,
          // );

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('새 어휘가 추가되었습니다.')),
          );
        }

        if (!mounted) return;
        Navigator.pop(context, true); // 성공 결과 반환
      } catch (e) {
        print('어휘 저장 오류: $e');
        setState(() {
          _isLoading = false;
          _errorMessage = '어휘를 저장하는 중 오류가 발생했습니다.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: widget.editItem != null ? '어휘 수정' : '새 어휘 추가',
      body: _isLoading && _categories.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 이미지 선택 영역
                    GestureDetector(
                      onTap: _showImageSourceDialog,
                      child: Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.5),
                          ),
                        ),
                        child: _imageFile != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  _imageFile!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : _imagePath != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      _imagePath!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          const Center(
                                        child: Icon(
                                          Icons.broken_image,
                                          size: 60,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  )
                                : Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.add_photo_alternate,
                                          size: 60,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          '이미지 선택',
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 텍스트 입력 필드
                    TextFormField(
                      controller: _textController,
                      decoration: const InputDecoration(
                        labelText: '텍스트',
                        hintText: '표시될 텍스트를 입력하세요',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '텍스트를 입력해주세요';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // 카테고리 선택 드롭다운
                    DropdownButtonFormField<String>(
                      value: _selectedCategoryId,
                      decoration: const InputDecoration(
                        labelText: '카테고리',
                        border: OutlineInputBorder(),
                      ),
                      items: _categories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category.id,
                          child: Text(category.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategoryId = value;
                        });
                      },
                    ),
                    const SizedBox(height: 24),

                    // 오류 메시지
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    // 저장 버튼
                    ElevatedButton(
                      onPressed: _isLoading ? null : _saveCustomVocabulary,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(widget.editItem != null ? '수정하기' : '추가하기'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
