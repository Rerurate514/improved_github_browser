import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:github_browser/features/settings_theme_switch/repositories/theme_repository.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'theme_repository_test.mocks.dart';

@GenerateMocks([SharedPreferences])
void main() {
  late MockSharedPreferences mockSharedPreferences;
  late ThemeRepository themeRepository;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    themeRepository = ThemeRepository(mockSharedPreferences);
  });

  group('ThemeRepository', () {
    test('SharedPreferencesに保存できること', () async {
      when(
        mockSharedPreferences.setInt('theme_mode', ThemeMode.dark.index),
      ).thenAnswer((_) async => true);
      when(mockSharedPreferences.getInt('theme_mode')).thenReturn(ThemeMode.dark.index);

      await themeRepository.saveThemeMode(ThemeMode.dark);

      verify(mockSharedPreferences.setInt('theme_mode', ThemeMode.dark.index)).called(1);

      final savedValue = mockSharedPreferences.getInt('theme_mode');
      expect(savedValue, ThemeMode.dark.index);
    });

    test('SharedPreferencesからテーマをロードできること', () async {
      when(mockSharedPreferences.getInt('theme_mode')).thenReturn(ThemeMode.light.index);

      final themeMode = await themeRepository.loadThemeMode();

      expect(themeMode, ThemeMode.light);
      verify(mockSharedPreferences.getInt('theme_mode')).called(1);
    });

    test('SharedPreferencesでエラーが発生した際にlightを返すこと', () async {
      when(mockSharedPreferences.getInt('theme_mode')).thenReturn(null);

      final themeMode = await themeRepository.loadThemeMode();

      expect(themeMode, ThemeMode.light);
      verify(mockSharedPreferences.getInt('theme_mode')).called(1);
    });

    test('正常に保存できて、ロードできること', () async {
      for (final mode in ThemeMode.values) {
        when(mockSharedPreferences.setInt('theme_mode', mode.index)).thenAnswer((_) async => true);
        when(mockSharedPreferences.getInt('theme_mode')).thenReturn(mode.index);

        await themeRepository.saveThemeMode(mode);
        final loadedMode = await themeRepository.loadThemeMode();

        expect(loadedMode, mode);
        verify(mockSharedPreferences.setInt('theme_mode', mode.index)).called(1);
      }
    });
  });
}
