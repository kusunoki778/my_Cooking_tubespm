import 'package:shared_preferences/shared_preferences.dart';

class Prefs {
  static const _keyThemeDark = 'isDarkTheme';
  static const _keyLastViewed = 'lastViewedRecipeId';
  static const _keyFavorites = 'favoriteRecipeIds'; 

  static Future<bool> isDarkTheme() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getBool(_keyThemeDark) ?? false;
  }

  static Future<void> setDarkTheme(bool value) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_keyThemeDark, value);
  }

  static Future<String?> getLastViewedRecipeId() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_keyLastViewed);
  }

  static Future<void> setLastViewedRecipeId(String id) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_keyLastViewed, id);
  }

  static Future<List<String>> getFavorites() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getStringList(_keyFavorites) ?? [];
  }

  static Future<void> setFavorites(List<String> ids) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setStringList(_keyFavorites, ids);
  }
}