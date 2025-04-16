import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeRepository {
  static const String _key = 'theme_mode';
  
  Future<void> saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, mode.index);
  }
  
  Future<ThemeMode> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getInt(_key);
    return value != null ? ThemeMode.values[value] : ThemeMode.light;
  }
}
