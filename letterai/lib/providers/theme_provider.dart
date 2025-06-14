import 'package:flutter/material.dart';
import '../services/settings_service.dart';

class ThemeProvider extends ChangeNotifier {
  final SettingsService _settingsService = SettingsService();
  ThemeMode _themeMode = ThemeMode.system;
  String _currentTheme = 'system';
  
  ThemeMode get themeMode => _themeMode;
  String get currentTheme => _currentTheme;
  
  ThemeProvider() {
    _loadTheme();
  }
  
  Future<void> _loadTheme() async {
    try {
      _currentTheme = await _settingsService.getTheme();
      _themeMode = _getThemeModeFromString(_currentTheme);
      notifyListeners();
    } catch (e) {
      // Default to system theme if there's an error
      _themeMode = ThemeMode.system;
      _currentTheme = 'system';
    }
  }
  
  Future<void> setTheme(String theme) async {
    try {
      await _settingsService.setTheme(theme);
      _currentTheme = theme;
      _themeMode = _getThemeModeFromString(theme);
      notifyListeners();
    } catch (e) {
      // Handle error - could show a snackbar or log error
      debugPrint('Error setting theme: $e');
    }
  }
  
  ThemeMode _getThemeModeFromString(String theme) {
    switch (theme.toLowerCase()) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }
  
  bool get isDarkMode {
    if (_themeMode == ThemeMode.dark) return true;
    if (_themeMode == ThemeMode.light) return false;
    // For system mode, we would need context to check MediaQuery
    // This is a fallback - in practice you'd check the system theme
    return false;
  }
}
