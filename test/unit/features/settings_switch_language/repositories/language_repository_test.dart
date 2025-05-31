import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:github_browser/features/settings_lang_switch/entities/langs.dart';
import 'package:github_browser/features/settings_lang_switch/entities/language.dart';
import 'package:github_browser/features/settings_lang_switch/repositories/language_repository.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'language_repository_test.mocks.dart';

@GenerateMocks([SharedPreferences])
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  late MockSharedPreferences mockSharedPreferences;
  late LanguageRepository languageRepository;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    languageRepository = LanguageRepository(mockSharedPreferences);
  });

  group('LanguageRepository', () {
    test('SharedPreferencesに保存できること', () async {
      when(mockSharedPreferences.setString('selected_language', Language.japanese.code))
        .thenAnswer((_) async => true);

      when(mockSharedPreferences.getString('selected_language'))
        .thenReturn(Language.japanese.code);

      await languageRepository.saveLang(Language.japanese);

      verify(mockSharedPreferences.setString('selected_language', Language.japanese.code)).called(1);

      final savedValue = mockSharedPreferences.getString('selected_language');

      expect(savedValue, Language.japanese.code);
    });

    test('SharedPreferencesから言語をロードできること', () async {
      when(mockSharedPreferences.getString('selected_language'))
        .thenReturn(Language.japanese.code);
      
      final lang = await languageRepository.loadLang();
      
      expect(lang, Language.japanese);
    });

    test('SharedPreferencesでエラーが発生した際にLanguage.japaneseを返すこと', () async {
      when(mockSharedPreferences.getString('selected_language'))
        .thenReturn(null);
      
      final lang = await languageRepository.loadLang();
      
      expect(lang, Language.japanese);
    });

    test('正常に保存できて、ロードできること', () async {
      for (final Langs value in Langs.values) {
        SharedPreferences.setMockInitialValues({});
        
        final Language language = Language.fromCode(value.code);

        when(mockSharedPreferences.setString('selected_language', language.code))
          .thenAnswer((_) async => true);
        when(mockSharedPreferences.getString('selected_language'))
          .thenReturn(language.code);
        
        await languageRepository.saveLang(language);
        
        final loadedMode = await languageRepository.loadLang();
        
        expect(loadedMode, language);
        
        verify(mockSharedPreferences.setString('selected_language', language.code)).called(1);
      }
    });
  });
}
