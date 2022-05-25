import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

ThemeMode _defaultMode() => ThemeMode.system;

class ThemeSettings extends ChangeNotifier {
  static const _THEME_MODE_KEY = 'themeModeId';

  ThemeMode _themeMode;

  ThemeMode get themeMode => _themeMode;

  ThemeSettings._(this._themeMode);

  static Future<ThemeSettings> createAndLoad() async {
    final preferences = await SharedPreferences.getInstance();

    final themeSettings =
        ThemeSettings._(_loadThemeModePreference(preferences));

    themeSettings.notifyListeners();

    return themeSettings;
  }

  static ThemeMode _loadThemeModePreference(
      final SharedPreferences preferences) {
    final String themeModeId = preferences.getString(_THEME_MODE_KEY);

    return ThemeMode.values.firstWhere((element) => element.name == themeModeId,
        orElse: _defaultMode);
  }

  void registerThemeModePreference(final ThemeMode themeMode) {
    if(_themeMode == themeMode) {
      return;
    }

    _saveThemeModePreference(themeMode);
    _setThemeModePreference(themeMode);
  }

  void _saveThemeModePreference(final ThemeMode themeMode) async {
    _savePreference(_THEME_MODE_KEY, themeMode.name);
  }

  void _setThemeModePreference(final ThemeMode themeMode) {
    this._themeMode = themeMode;
    notifyListeners();
  }

  void _savePreference(final String key, final String value) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(key, value);
  }
}
