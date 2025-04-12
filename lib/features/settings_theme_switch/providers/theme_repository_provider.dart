import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:github_browser/features/settings_theme_switch/repositories/theme_repository.dart';

final themeRepositoryProvider = Provider<ThemeRepository>((ref) {
  return ThemeRepository();
});
