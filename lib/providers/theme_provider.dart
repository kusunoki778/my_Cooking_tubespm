import 'package:flutter/material.dart';
import 'package:my_resep/utils/shared_prefs.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDark = false;

  bool get isDark => _isDark;

  ThemeProvider() {
    _loadTheme();
  }

  void _loadTheme() async {
    _isDark = await Prefs.isDarkTheme();
    notifyListeners();
  }

  void toggleTheme() async {
    _isDark = !_isDark;
    await Prefs.setDarkTheme(_isDark);
    notifyListeners();
  }
}