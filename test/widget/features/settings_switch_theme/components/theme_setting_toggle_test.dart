import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:github_browser/core/components/toggle_button.dart';
import 'package:github_browser/features/settings_theme_switch/components/theme_settings_toggle.dart';
import 'package:github_browser/features/settings_theme_switch/providers/theme_repository_provider.dart';
import 'package:github_browser/features/settings_theme_switch/repositories/theme_repository.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:github_browser/l10n/app_localizations.dart';

@GenerateMocks([ThemeRepository])
import 'theme_setting_toggle_test.mocks.dart';

void main() {
  late MockThemeRepository mockRepository;
  late ProviderScope providerScope;

  setUp(() {
    mockRepository = MockThemeRepository();

    when(mockRepository.loadThemeMode()).thenAnswer((_) async => ThemeMode.light);
    when(mockRepository.saveThemeMode(any)).thenAnswer((_) async {});

    providerScope = ProviderScope(
      overrides: [themeRepositoryProvider.overrideWithValue(mockRepository)],
      child: const MaterialApp(
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          AppLocalizations.delegate,
        ],
        supportedLocales: [Locale('ja', ''), Locale('en', '')],
        locale: Locale('ja', ''),
        home: Scaffold(body: ThemeSettingToggle()),
      ),
    );
  });

  group("ThemeSettingToggle", () {
    testWidgets('ThemeSettingToggleが正しく表示されること', (WidgetTester tester) async {
      await tester.pumpWidget(providerScope);

      await tester.pumpAndSettle();

      expect(find.text("ダークモードを有効化"), findsOneWidget);

      expect(find.byType(ToggleButton), findsOneWidget);
    });

    testWidgets('初期状態でライトモードの場合、トグルがオフになっていること', (WidgetTester tester) async {
      when(mockRepository.loadThemeMode()).thenAnswer((_) async => ThemeMode.light);

      await tester.pumpWidget(providerScope);
      await tester.pumpAndSettle();

      final toggleFinder = find.byType(ToggleButton);
      final ToggleButton toggle = tester.widget(toggleFinder);

      expect(toggle.isActive, false);
    });

    testWidgets('初期状態でダークモードの場合、トグルがオンになっていること', (WidgetTester tester) async {
      when(mockRepository.loadThemeMode()).thenAnswer((_) async => ThemeMode.dark);

      await tester.pumpWidget(providerScope);
      await tester.pumpAndSettle();

      final toggleFinder = find.byType(ToggleButton);
      final ToggleButton toggle = tester.widget(toggleFinder);

      expect(toggle.isActive, true);
    });

    testWidgets('トグルをタップするとテーマモードが切り替わること', (WidgetTester tester) async {
      when(mockRepository.loadThemeMode()).thenAnswer((_) async => ThemeMode.light);

      await tester.pumpWidget(providerScope);
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ToggleButton));
      await tester.pumpAndSettle();

      verify(mockRepository.saveThemeMode(ThemeMode.dark)).called(1);

      await tester.tap(find.byType(ToggleButton));
      await tester.pumpAndSettle();

      verify(mockRepository.saveThemeMode(ThemeMode.light)).called(1);
    });
  });
}
