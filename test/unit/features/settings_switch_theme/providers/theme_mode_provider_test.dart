import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:github_browser/features/settings_theme_switch/providers/theme_mode_provider.dart';
import 'package:github_browser/features/settings_theme_switch/providers/theme_repository_provider.dart';
import 'package:github_browser/features/settings_theme_switch/repositories/theme_repository.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([ThemeRepository])
import 'theme_mode_provider_test.mocks.dart';

void main() {
  late MockThemeRepository mockRepository;
  late ProviderContainer container;

  setUp(() {
    mockRepository = MockThemeRepository();

    when(mockRepository.loadThemeMode()).thenAnswer((_) async => ThemeMode.dark);

    container = ProviderContainer(
      overrides: [themeRepositoryProvider.overrideWithValue(mockRepository)],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group("theme_mode_provider", () {
    test('初期状態はThemeMode.systemであること', () async {
      expect(container.read(themeModeProvider), ThemeMode.system);

      await Future<dynamic>.delayed(Duration.zero);

      verify(mockRepository.loadThemeMode()).called(1);
    });

    test('setThemeModeを呼び出すと、リポジトリが更新され状態が変わること', () async {
      when(mockRepository.saveThemeMode(any)).thenAnswer((_) async {});

      await container.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark);

      verify(mockRepository.saveThemeMode(ThemeMode.dark)).called(1);

      expect(container.read(themeModeProvider), ThemeMode.dark);
    });
  });
}
