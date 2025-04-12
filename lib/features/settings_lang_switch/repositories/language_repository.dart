import 'package:github_browser/features/settings_lang_switch/entities/language.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageRepository {
  static const String _key = 'selected_language';
  
  Future<void> saveLang(Language language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, Language.japanese.code);
  }
  
  Future<Language> loadLang() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_key);
    return 
      value != null 
      ? Language.fromCode(value)
      : Language.english;
  }
}
