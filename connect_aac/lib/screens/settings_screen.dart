// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:connect_aac/providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Use Consumer to listen to SettingsProvider changes
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        // Show loading indicator if settings are being loaded initially
        if (settingsProvider.isLoading) {
          return Scaffold( // Provide Scaffold even during loading
             appBar: AppBar(title: const Text('설정')),
             body: const Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold( // Or use AppScaffold if you have one
          // AppBar is often handled by the root scaffold (e.g., in HomeScreen)
          // appBar: AppBar(title: const Text('설정')),
          body: ListView(
            padding: const EdgeInsets.symmetric(vertical: 8.0), // Add vertical padding
            children: [
              // --- Display Settings ---
              _buildSettingsSectionTitle(context, '디스플레이'),
              ListTile(
                leading: const Icon(Icons.brightness_6_outlined),
                title: const Text('테마 설정'),
                trailing: DropdownButton<ThemeMode>(
                  value: settingsProvider.themeMode,
                   underline: Container(), // Remove default underline
                   // style: Theme.of(context).textTheme.bodyMedium, // Apply theme style
                  items: const [
                    DropdownMenuItem(
                      value: ThemeMode.system,
                      child: Text('시스템 설정'),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.light,
                      child: Text('라이트 모드'),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.dark,
                      child: Text('다크 모드'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      // Call provider method to change theme and save
                      settingsProvider.setThemeMode(value);
                    }
                  },
                ),
              ),
               _buildSliderSetting(
                  context: context,
                  title: '글자 크기',
                  icon: Icons.format_size,
                  value: settingsProvider.textSize,
                  min: 12.0,
                  max: 24.0, // Adjust range as needed
                  divisions: 6, // Number of steps
                  label: settingsProvider.textSize.toStringAsFixed(0), // Display value on slider
                  onChanged: (value) => settingsProvider.setTextSize(value),
              ),
               _buildSliderSetting(
                  context: context,
                  title: '아이콘 크기',
                  icon: Icons.widgets_outlined,
                  value: settingsProvider.iconSize,
                  min: 18.0,
                  max: 36.0, // Adjust range
                  divisions: 6,
                  label: settingsProvider.iconSize.toStringAsFixed(0),
                  onChanged: (value) => settingsProvider.setIconSize(value),
              ),

              const Divider(),

              // --- TTS Settings ---
               _buildSettingsSectionTitle(context, '음성 출력 (TTS)'),
              SwitchListTile(
                 title: const Text('음성 출력 사용'),
                 value: settingsProvider.ttsEnabled,
                 onChanged: (bool value) {
                    settingsProvider.setTtsEnabled(value);
                 },
                 secondary: const Icon(Icons.volume_up_outlined),
              ),
               ListTile(
                    leading: const Icon(Icons.record_voice_over_outlined),
                    title: const Text('음성 종류'),
                    subtitle: Text(settingsProvider.voiceType), // Display current voice
                     trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                     enabled: settingsProvider.ttsEnabled, // Disable if TTS is off
                     onTap: settingsProvider.ttsEnabled ? () {
                         // TODO: Navigate/Show dialog to select voice
                         // This would likely involve fetching available voices from API
                         // using settingsProvider._apiService.getTTSVoices()
                         print('Select voice - (Not Implemented)');
                           ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('음성 선택 기능은 아직 구현되지 않았습니다.')),
                           );
                     } : null,
                 ),
                  _buildSliderSetting(
                     context: context,
                     title: '말하기 속도',
                     icon: Icons.speed_outlined,
                     value: settingsProvider.speechRate,
                     min: 0.5,
                     max: 2.0, // Standard range for speech rate
                     divisions: 15, // More steps for finer control
                     label: settingsProvider.speechRate.toStringAsFixed(1), // Show one decimal place
                      enabled: settingsProvider.ttsEnabled,
                     onChanged: settingsProvider.ttsEnabled
                        ? (value) => settingsProvider.setSpeechRate(value)
                        : null,
                 ),

              // --- Add more sections as needed (e.g., Account, Data Management) ---
              const Divider(),
               _buildSettingsSectionTitle(context, '계정'),
                ListTile(
                  leading: const Icon(Icons.person_outline),
                   title: const Text('프로필 수정'),
                   trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                   onTap: () {
                      // TODO: Navigate to profile editing screen
                       print('Navigate to Profile Edit - (Not Implemented)');
                       ScaffoldMessenger.of(context).showSnackBar(
                           const SnackBar(content: Text('프로필 수정 기능은 아직 구현되지 않았습니다.')),
                       );
                   },
               ),
                ListTile(
                   leading: const Icon(Icons.lock_outline),
                   title: const Text('비밀번호 변경'),
                   trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                   onTap: () {
                        // TODO: Navigate to password change screen
                         print('Navigate to Password Change - (Not Implemented)');
                          ScaffoldMessenger.of(context).showSnackBar(
                           const SnackBar(content: Text('비밀번호 변경 기능은 아직 구현되지 않았습니다.')),
                       );
                   },
               ),


            ],
          ),
        );
      },
    );
  }

  // Helper to build section titles
  Widget _buildSettingsSectionTitle(BuildContext context, String title) {
     return Padding(
       padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
       child: Text(
         title,
         style: Theme.of(context).textTheme.titleSmall?.copyWith(
           color: Theme.of(context).colorScheme.primary,
           fontWeight: FontWeight.bold,
         ),
       ),
     );
  }

  // Helper to build slider settings consistently
 Widget _buildSliderSetting({
    required BuildContext context,
    required String title,
    required IconData icon,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String label,
    required ValueChanged<double>? onChanged,
    bool enabled = true, // Optional enabled flag
 }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: SliderTheme( // Customize slider appearance
         data: SliderTheme.of(context).copyWith(
           // Customize colors, track height, thumb shape etc. if needed
           activeTrackColor: enabled ? Theme.of(context).colorScheme.primary : Colors.grey.shade400,
           inactiveTrackColor: enabled ? Theme.of(context).colorScheme.primary.withOpacity(0.3) : Colors.grey.shade300,
            thumbColor: enabled ? Theme.of(context).colorScheme.primary : Colors.grey.shade500,
            overlayColor: enabled ? Theme.of(context).colorScheme.primary.withOpacity(0.2) : Colors.transparent,
            valueIndicatorColor: Theme.of(context).colorScheme.primary,
             valueIndicatorTextStyle: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
         ),
        child: Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          label: label, // Shows value when dragging
          onChanged: enabled ? onChanged : null, // Disable slider if needed
        ),
      ),
      // trailing: Text(label, style: Theme.of(context).textTheme.bodyMedium), // Show value next to slider
    );
 }
}
