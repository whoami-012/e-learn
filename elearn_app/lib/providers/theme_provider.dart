import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../core/constants/app_constants.dart';

class ThemeProvider extends ChangeNotifier {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  bool _isDarkMode;
  bool _isLoaded = false;

  ThemeProvider({bool initialDarkMode = false, bool loadPreference = true})
      : _isDarkMode = initialDarkMode {
    if (loadPreference) _load();
  }

  bool get isDarkMode => _isDarkMode;
  bool get isLoaded => _isLoaded;
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  Future<void> _load() async {
    try {
      _isDarkMode =
          await _storage.read(key: AppConstants.darkThemeKey) == 'true';
    } catch (_) {
      // Keep the default theme if preference storage is unavailable.
    } finally {
      _isLoaded = true;
      notifyListeners();
    }
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    try {
      await _storage.write(
        key: AppConstants.darkThemeKey,
        value: _isDarkMode.toString(),
      );
    } catch (_) {
      // The in-memory toggle remains usable even if persistence fails.
    }
  }
}
