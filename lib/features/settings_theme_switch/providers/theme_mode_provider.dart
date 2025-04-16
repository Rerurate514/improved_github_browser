import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:github_browser/features/settings_theme_switch/providers/theme_repository_provider.dart';
import 'package:github_browser/features/settings_theme_switch/repositories/theme_repository.dart';

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  final repository = ref.watch(themeRepositoryProvider);
  return ThemeModeNotifier(repository);
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final ThemeRepository _repository;
  
  ThemeModeNotifier(this._repository) : super(ThemeMode.system) {
    _loadThemeMode();
  }
  
  Future<void> _loadThemeMode() async {
    final mode = await _repository.loadThemeMode();
    state = mode;
  }
  
  Future<void> setThemeMode(ThemeMode mode) async {
    await _repository.saveThemeMode(mode);
    state = mode;
  }
}
