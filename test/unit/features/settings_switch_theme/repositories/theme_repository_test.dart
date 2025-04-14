import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:github_browser/features/settings_theme_switch/repositories/theme_repository.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';

///これはThemeModeをEntityとみなす。
@GenerateMocks([])
void main() {
  late ThemeRepository themeRepository;

  setUp(() {
    themeRepository = ThemeRepository();
  });

  group('ThemeRepository', () {
    test('SharedPreferencesに保存できること', () async {
      SharedPreferences.setMockInitialValues({});

      await themeRepository.saveThemeMode(ThemeMode.dark);

      final prefs = await SharedPreferences.getInstance();
      final savedValue = prefs.getInt('theme_mode');

      expect(savedValue, ThemeMode.dark.index);
    });

    test('SharedPreferencesからテーマをロードできること', () async {
      SharedPreferences.setMockInitialValues({'theme_mode': ThemeMode.light.index});
      
      final themeMode = await themeRepository.loadThemeMode();
      
      expect(themeMode, ThemeMode.light);
    });

    test('SharedPreferencesでエラーが発生した際にlightを返すこと', () async {
      SharedPreferences.setMockInitialValues({});
      
      final themeMode = await themeRepository.loadThemeMode();
      
      expect(themeMode, ThemeMode.light);
    });

    test('正常に保存できて、ロードできること', () async {
      for (final mode in ThemeMode.values) {
        SharedPreferences.setMockInitialValues({});
        
        await themeRepository.saveThemeMode(mode);
        
        final loadedMode = await themeRepository.loadThemeMode();
        
        expect(loadedMode, mode);
      }
    });
  });
}
