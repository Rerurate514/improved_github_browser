import 'package:github_browser/features/settings_lang_switch/entities/language.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageRepository {
  static const String _key = 'selected_language';
  final SharedPreferences prefs;
  LanguageRepository(this.prefs);
  
  Future<void> saveLang(Language language) async {
    await prefs.setString(_key, language.code);
  }
  
  Future<Language> loadLang() async {
    final value = prefs.getString(_key);
    return 
      value != null 
      ? Language.fromCode(value)
      : Language.japanese;
  }
}
