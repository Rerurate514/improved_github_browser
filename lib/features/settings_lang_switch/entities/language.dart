import 'dart:ui';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:github_browser/core/exceptions/domain_exception.dart';
import 'package:github_browser/features/settings_lang_switch/entities/langs.dart';

@immutable
class Language {
  final String code;
  final String name;
  final Locale locale;
  
  const Language._({
    required this.code,
    required this.name,
    required this.locale,
  });
  
  static final japanese = Language._(
    code: Langs.ja.code,
    name: Langs.ja.name,
    locale: Langs.ja.locale,
  );
  
  static final english = Language._(
    code: Langs.en.code,
    name: Langs.en.name,
    locale: Langs.en.locale,
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
