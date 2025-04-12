import 'dart:ui';

enum Langs {
  ja,
  en
}

extension LangsToString on Langs {
  String get name{
    switch(this){
      case Langs.ja: return "日本語";
      case Langs.en: return "English";
    }
  }

  String get code => name.toLowerCase();
  String get fullString => '$this ($code)';
}

extension LangsToLocale on Langs {
  Locale get locale{
    switch(this){
      case Langs.ja: return const Locale('ja', 'JP');
      case Langs.en: return const Locale('en', 'US');
    }
  }
}

Langs? stringToLang(String langStr) {
  return Langs.values.asNameMap()[langStr];
}
