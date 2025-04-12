import 'package:flutter_test/flutter_test.dart';
import 'package:github_browser/features/settings_lang_switch/entities/langs.dart';
import 'package:github_browser/features/settings_lang_switch/entities/language.dart';
import 'package:github_browser/features/settings_lang_switch/repositories/language_repository.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';

@GenerateMocks([])
void main() {
  late LanguageRepository languageRepository;

  setUp(() {
    languageRepository = LanguageRepository();
  });

  group('LanguageRepository', () {
    test('SharedPreferencesに保存できること', () async {
      SharedPreferences.setMockInitialValues({});

      await languageRepository.saveLang(Language.japanese);

      final prefs = await SharedPreferences.getInstance();
      final savedValue = prefs.getString('selected_language');

      expect(savedValue, Language.japanese.code);
    });

    test('SharedPreferencesから言語をロードできること', () async {
      SharedPreferences.setMockInitialValues({
        'selected_language': Language.japanese.code
      });
      
      final lang = await languageRepository.loadLang();
      
      expect(lang, Language.japanese);
    });

    test('SharedPreferencesでエラーが発生した際にLanguage.englishを返すこと', () async {
      SharedPreferences.setMockInitialValues({});
      
      final lang = await languageRepository.loadLang();
      
      expect(lang, Language.english);
    });

    test('正常に保存できて、ロードできること', () async {
      for (final Langs value in Langs.values) {
        SharedPreferences.setMockInitialValues({});
        
        final Language language = Language.fromCode(value.code);
        
        await languageRepository.saveLang(language);
        
        final loadedMode = await languageRepository.loadLang();
        
        expect(loadedMode, language);
      }
    });
  });
}
