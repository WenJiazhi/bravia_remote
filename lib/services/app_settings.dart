import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  static const String _localeKey = 'locale';

  ThemeMode _themeMode = ThemeMode.light;
  Locale _locale = const Locale('zh');

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final themeValue = prefs.getString(_themeKey) ?? 'light';
    _themeMode = themeValue == 'dark' ? ThemeMode.dark : ThemeMode.light;

    final localeValue = prefs.getString(_localeKey) ?? 'zh';
    _locale = Locale(localeValue);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, mode == ThemeMode.dark ? 'dark' : 'light');
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    await setThemeMode(
        _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
    notifyListeners();
  }

  Future<void> toggleLocale() async {
    await setLocale(
        _locale.languageCode == 'zh' ? const Locale('en') : const Locale('zh'));
  }
}
