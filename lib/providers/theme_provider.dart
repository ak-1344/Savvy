import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ThemeProvider with ChangeNotifier {
  final Box _settingsBox = Hive.box('settings');
  static const String _darkModeKey = 'darkMode';

  bool get isDarkMode => _settingsBox.get(_darkModeKey, defaultValue: false);

  Future<void> toggleTheme() async {
    await _settingsBox.put(_darkModeKey, !isDarkMode);
    notifyListeners();
  }
}
