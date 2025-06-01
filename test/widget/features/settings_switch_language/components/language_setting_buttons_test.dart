import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:github_browser/features/settings_lang_switch/components/language_setting_buttons.dart';
import 'package:github_browser/features/settings_lang_switch/entities/langs.dart';
import 'package:github_browser/features/settings_lang_switch/entities/language.dart';
import 'package:github_browser/features/settings_lang_switch/providers/language_repositry_provider.dart';
import 'package:github_browser/features/settings_lang_switch/repositories/language_repository.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([LanguageRepository])
import 'language_setting_buttons_test.mocks.dart';

void main() {
  late MockLanguageRepository mockRepository;

  setUp(() {
    mockRepository = MockLanguageRepository();
    when(mockRepository.loadLang()).thenAnswer((_) async => Language.japanese);
  });

  group("LanguageSettingbuttons", () {
    testWidgets('各言語のボタンが表示されること', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [languageRepositoryProvider.overrideWith((_) => mockRepository)],
          child: const MaterialApp(
            home: Scaffold(body: Column(children: [LanguageSettingsButtons()])),
          ),
        ),
      );

      expect(find.text('日本語'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
    });

    testWidgets('日本語がデフォルトで選択されていること', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [languageRepositoryProvider.overrideWith((_) => mockRepository)],
          child: const MaterialApp(
            home: Scaffold(body: Column(children: [LanguageSettingsButtons()])),
          ),
        ),
      );

      final languageRadios = tester.widgetList<Radio<Language>>(find.byType(Radio<Language>));
      final jaRadio = languageRadios.firstWhere((radio) => radio.value == Language.japanese);

      expect(jaRadio.groupValue, equals(Language.japanese));
    });

    testWidgets('ListViewに正しい言語数が含まれていること', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [languageRepositoryProvider.overrideWith((_) => mockRepository)],
          child: const MaterialApp(
            home: Scaffold(body: Column(children: [LanguageSettingsButtons()])),
          ),
        ),
      );

      final listTileCount = tester.widgetList(find.byType(ListTile)).length;
      expect(listTileCount, equals(Langs.values.length));
    });

    testWidgets('ListViewはコンテナ制約でスクロール可能でなければならないこと', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [languageRepositoryProvider.overrideWith((_) => mockRepository)],
          child: const MaterialApp(
            home: Scaffold(
              body: SizedBox(height: 100, child: Column(children: [LanguageSettingsButtons()])),
            ),
          ),
        ),
      );

      expect(find.byType(ListView), findsOneWidget);

      final listView = find.byType(ListView);
      await tester.drag(listView, const Offset(0, -200));
      await tester.pump();
    });

    testWidgets('ボタンをタップした際に言語が切り替わること', (WidgetTester tester) async {
      when(mockRepository.saveLang(any)).thenAnswer((_) async {});

      await tester.pumpWidget(
        ProviderScope(
          overrides: [languageRepositoryProvider.overrideWith((_) => mockRepository)],
          child: const MaterialApp(
            home: Scaffold(body: Column(children: [LanguageSettingsButtons()])),
          ),
        ),
      );

      final initialRadios = tester.widgetList<Radio<Language>>(find.byType(Radio<Language>));
      final initialJaRadio = initialRadios.firstWhere((radio) => radio.value == Language.japanese);
      expect(initialJaRadio.groupValue, equals(Language.japanese));

      await tester.tap(find.text('English'));
      await tester.pump();

      final updatedRadios = tester.widgetList<Radio<Language>>(find.byType(Radio<Language>));
      final updatedEnRadio = updatedRadios.firstWhere((radio) => radio.value == Language.english);

      expect(updatedEnRadio.value, Language.english);
    });

    testWidgets('Radioボタンが正しく表示されること', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [languageRepositoryProvider.overrideWith((_) => mockRepository)],
          child: const MaterialApp(
            home: Scaffold(body: Column(children: [LanguageSettingsButtons()])),
          ),
        ),
      );

      expect(find.byType(Radio<Language>), findsNWidgets(Langs.values.length));
    });

    testWidgets('Radioボタンをタップして言語変更が動作すること', (WidgetTester tester) async {
      when(mockRepository.saveLang(any)).thenAnswer((_) async {});

      await tester.pumpWidget(
        ProviderScope(
          overrides: [languageRepositoryProvider.overrideWith((_) => mockRepository)],
          child: const MaterialApp(
            home: Scaffold(body: Column(children: [LanguageSettingsButtons()])),
          ),
        ),
      );

      final englishRadio = find.byWidgetPredicate(
        (widget) => widget is Radio<Language> && widget.value == Language.english,
      );

      await tester.tap(englishRadio);
      await tester.pump();

      verify(mockRepository.saveLang(Language.english)).called(1);
    });

    testWidgets('初期状態で正しい言語が選択されていること', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [languageRepositoryProvider.overrideWith((_) => mockRepository)],
          child: const MaterialApp(
            home: Scaffold(body: Column(children: [LanguageSettingsButtons()])),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final radios = tester.widgetList<Radio<Language>>(find.byType(Radio<Language>));
      final selectedRadios = radios.where((radio) => radio.groupValue == radio.value);

      expect(selectedRadios.length, equals(1));
      expect(selectedRadios.first.value, equals(Language.japanese));
    });
  });
}
