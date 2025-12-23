import 'package:shared_preferences/shared_preferences.dart';

class Prefs {
  static const _keyThemeDark = 'isDarkTheme';
  static const _keyLastViewed = 'lastViewedRecipeId';
  static const _keyFavorites = 'favoriteRecipeIds'; 

  static const _keyIsLogin = 'isLoggedIn';
  static const _keyUserId = 'userId';
  static const _keyUsername = 'username';
  static const _keyFullname = 'fullname';
  static const _keyAvatar = 'avatar';

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

  static Future<bool> isLoggedIn() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getBool(_keyIsLogin) ?? false;
  }

  static Future<Map<String, String>> getUserSession() async {
    final sp = await SharedPreferences.getInstance();
    return {
      'id': sp.getString(_keyUserId) ?? '',
      'username': sp.getString(_keyUsername) ?? 'Guest',
      'fullname': sp.getString(_keyFullname) ?? 'Pengguna',
      'avatar': sp.getString(_keyAvatar) ?? '',
    };
  }

  static Future<void> saveUserSession(String id, String username, String fullname, String avatar) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_keyIsLogin, true);
    await sp.setString(_keyUserId, id);
    await sp.setString(_keyUsername, username);
    await sp.setString(_keyFullname, fullname);
    await sp.setString(_keyAvatar, avatar);
  }

  static Future<void> clearSession() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_keyIsLogin);
    await sp.remove(_keyUserId);
    await sp.remove(_keyUsername);
    await sp.remove(_keyFullname);
    await sp.remove(_keyAvatar);
  }
}