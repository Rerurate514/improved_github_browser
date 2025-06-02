import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:github_browser/features/settings_lang_switch/entities/langs.dart';
import 'package:github_browser/features/settings_lang_switch/entities/language.dart';
import 'package:github_browser/features/settings_lang_switch/providers/language_provider.dart';

class LanguageSettingsButtons extends ConsumerStatefulWidget {
  const LanguageSettingsButtons({super.key});

  @override
  LanguageSettingsButtonsState createState() => LanguageSettingsButtonsState();
}

class LanguageSettingsButtonsState extends ConsumerState<LanguageSettingsButtons> {
  void _changeLanguage(Language language) {
    ref.read(languageProvider.notifier).setLanguage(language);
  }

  @override
  Widget build(BuildContext context) {
    final Language selectedLanguage = ref.watch(languageProvider);

    return Expanded(
      child: ListView.builder(
        itemCount: Langs.values.length,
        itemBuilder: (context, index) {
          final language = Language.fromCode(Langs.values[index].code);
          return ListTile(
            title: Text(language.name),
            trailing: Radio<Language>(
              value: language,
              groupValue: selectedLanguage,
              onChanged: (value) => _changeLanguage(value!),
            ),
          );
        },
      ),
    );
  }
}
