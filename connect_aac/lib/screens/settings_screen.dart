//Settings screen
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/favorites_provider.dart';
import '../services/tts_service.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/settings_section.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    final ttsService = TTSService();
    
    return AppScaffold(
      title: '설정',
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // TTS settings
          SettingsSection(
            title: '음성 설정',
            children: [
              ListTile(
                title: const Text('음성 속도'),
                subtitle: Slider(
                  value: settingsProvider.speechRate,
                  min: 0.5,
                  max: 2.0,
                  divisions: 15,
                  label: settingsProvider.speechRate.toStringAsFixed(1),
                  onChanged: (value) {
                    settingsProvider.setSpeechRate(value);
                    ttsService.setSpeechRate(value);
                  },
                ),
                trailing: Text('${settingsProvider.speechRate.toStringAsFixed(1)}x'),
              ),
              ListTile(
                title: const Text('음성 높낮이'),
                subtitle: Slider(
                  value: settingsProvider.speechPitch,
                  min: 0.5,
                  max: 2.0,
                  divisions: 15,
                  label: settingsProvider.speechPitch.toStringAsFixed(1),
                  onChanged: (value) {
                    settingsProvider.setSpeechPitch(value);
                    ttsService.setPitch(value);
                  },
                ),
                trailing: Text(settingsProvider.speechPitch.toStringAsFixed(1)),
              ),
              ListTile(
                title: const Text('AI 응답 자동 읽기'),
                trailing: Switch(
                  value: settingsProvider.autoSpeak,
                  onChanged: (value) {
                    settingsProvider.setAutoSpeak(value);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: ElevatedButton(
                  onPressed: () {
                    ttsService.speak('안녕하세요. 이것은 테스트 음성입니다.');
                  },
                  child: const Text('음성 테스트'),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // UI settings
          SettingsSection(
            title: 'UI 설정',
            children: [
              ListTile(
                title: const Text('테마'),
                trailing: DropdownButton<ThemeMode>(
                  value: settingsProvider.themeMode,
                  onChanged: (ThemeMode? newValue) {
                    if (newValue != null) {
                      settingsProvider.setThemeMode(newValue);
                    }
                  },
                  items: const [
                    DropdownMenuItem(
                      value: ThemeMode.system,
                      child: Text('시스템'),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.light,
                      child: Text('라이트'),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.dark,
                      child: Text('다크'),
                    ),
                  ],
                ),
              ),
              ListTile(
                title: const Text('텍스트 크기'),
                subtitle: Slider(
                  value: settingsProvider.textSize,
                  min: 0.8,
                  max: 1.5,
                  divisions: 7,
                  label: settingsProvider.textSize.toStringAsFixed(1),
                  onChanged: (value) {
                    settingsProvider.setTextSize(value);
                  },
                ),
                trailing: Text('${settingsProvider.textSize.toStringAsFixed(1)}x'),
              ),
              ListTile(
                title: const Text('아이콘 크기'),
                subtitle: Slider(
                  value: settingsProvider.iconSize,
                  min: 0.8,
                  max: 1.5,
                  divisions: 7,
                  label: settingsProvider.iconSize.toStringAsFixed(1),
                  onChanged: (value) {
                    settingsProvider.setIconSize(value);
                  },
                ),
                trailing: Text('${settingsProvider.iconSize.toStringAsFixed(1)}x'),
              ),
              ListTile(
                title: const Text('그리드 열 개수'),
                trailing: DropdownButton<int>(
                  value: settingsProvider.gridColumns,
                  onChanged: (int? newValue) {
                    if (newValue != null) {
                      settingsProvider.setGridColumns(newValue);
                    }
                  },
                  items: const [
                    DropdownMenuItem(
                      value: 2,
                      child: Text('2'),
                    ),
                    DropdownMenuItem(
                      value: 3,
                      child: Text('3'),
                    ),
                    DropdownMenuItem(
                      value: 4,
                      child: Text('4'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Data management
          SettingsSection(
            title: '데이터 관리',
            children: [
              ListTile(
                title: const Text('즐겨찾기 초기화'),
                subtitle: const Text('모든 즐겨찾기를 삭제합니다'),
                trailing: const Icon(Icons.delete_outline),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('즐겨찾기 초기화'),
                      content: const Text('모든 즐겨찾기를 삭제하시겠습니까?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('취소'),
                        ),
                        TextButton(
                          onPressed: () {
                            favoritesProvider.clearFavorites();
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('즐겨찾기가 초기화되었습니다')),
                            );
                          },
                          child: const Text('삭제'),
                        ),
                      ],
                    ),
                  );
                },
              ),
              ListTile(
                title: const Text('모든 설정 초기화'),
                subtitle: const Text('모든 설정을 기본값으로 되돌립니다'),
                trailing: const Icon(Icons.restore),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('설정 초기화'),
                      content: const Text('모든 설정을 기본값으로 되돌리시겠습니까?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('취소'),
                        ),
                        TextButton(
                          onPressed: () {
                            settingsProvider.resetSettings();
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('설정이 초기화되었습니다')),
                            );
                          },
                          child: const Text('초기화'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // About
          SettingsSection(
            title: '정보',
            children: [
              ListTile(
                title: const Text('앱 버전'),
                subtitle: const Text('1.0.0'),
              ),
              ListTile(
                title: const Text('개발자'),
                subtitle: const Text('HandTalk Team'),
              ),
              const AboutListTile(
                icon: Icon(Icons.info_outline),
                applicationName: 'HandTalk AAC',
                applicationVersion: '1.0.0',
                applicationLegalese: '© 2025 HandTalk Team',
                aboutBoxChildren: [
                  SizedBox(height: 16),
                  Text('HandTalk AAC는 중도·중복장애학생 등을 위한 보완대체의사소통 앱입니다.'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}