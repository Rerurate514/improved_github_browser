import 'dart:ui';
import 'package:github_browser/core/exceptions/domain_exception.dart';

class Language {
  final String code;
  final String name;
  final Locale locale;
  
  const Language._({
    required this.code,
    required this.name,
    required this.locale,
  });
  
  static const japanese = Language._(
    code: 'ja',
    name: '日本語',
    locale: Locale('ja', 'JP'),
  );
  
  static const english = Language._(
    code: 'en',
    name: 'English',
    locale: Locale('en', 'US'),
  );
  
  static List<Language> get allLanguages => [japanese, english];
  
  static Language fromCode(String code) {
    final lowercaseCode = code.toLowerCase();
    return allLanguages.firstWhere(
      (language) => language.code.toLowerCase() == lowercaseCode,
      orElse: () => throw DomainException('Unsupported language code: $code'),
    );
  }
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Language &&
      code == other.code &&
      name == other.name &&
      locale == other.locale;

  @override
  int get hashCode => Object.hash(code, name, locale);
  
  @override
  String toString() => 'Language($code: $name)';
}

