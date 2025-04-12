import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:github_browser/features/settings_lang_switch/entities/language.dart';
import 'package:github_browser/features/settings_lang_switch/providers/language_repositry_provider.dart';
import 'package:github_browser/features/settings_lang_switch/repositories/language_repository.dart';

final languageProvider = StateNotifierProvider<LangNotifier, Language>((ref) {
  final repository = ref.watch(languageRepositoryProvider);
  return LangNotifier(repository);
});

class LangNotifier extends StateNotifier<Language> {
  final LanguageRepository _repository;
  
  LangNotifier(this._repository) : super(Language.japanese) {
    _loadLanguage();
  }
  
  Future<void> _loadLanguage() async {
    final lang = await _repository.loadLang();
    state = lang;
  }
  
  Future<void> setLanguage(Language lang) async {
    await _repository.saveLang(lang);
    state = lang;
  }
}
