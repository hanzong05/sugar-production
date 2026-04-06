import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kThemeKey = 'app_theme_mode';

class ThemeNotifier extends ChangeNotifier {
  ThemeNotifier._internal(this._mode);

  ThemeMode _mode;
  ThemeMode get mode => _mode;

  bool get isDark => _mode == ThemeMode.dark; // ✅ fixed

  /// Load persisted value and return a ready notifier
  static Future<ThemeNotifier> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_kThemeKey);
    final mode = saved == 'dark'
        ? ThemeMode.dark
        : saved == 'light'
        ? ThemeMode.light
        : ThemeMode.system;
    return ThemeNotifier._internal(mode);
  }

  Future<void> setMode(ThemeMode mode) async {
    if (_mode == mode) return;
    _mode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kThemeKey, mode.name);
  }

  // Future<void> toggle(BuildContext context) async {
  //   // If currently following system, resolve actual brightness first
  //   final resolved = _mode == ThemeMode.system
  //       ? (MediaQuery.of(context).platformBrightness == Brightness.dark
  //             ? ThemeMode.dark
  //             : ThemeMode.light)
  //       : _mode;
  //   await setMode(
  //     resolved == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark,
  //   );
  // }
}
