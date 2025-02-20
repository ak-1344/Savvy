import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  final SharedPreferences _prefs;

  SettingsProvider(this._prefs) {
    _loadSettings();
  }

  ThemeMode _themeMode = ThemeMode.system;
  String _currency = '₹';
  bool _biometricEnabled = false;
  bool _notificationsEnabled = true;

  ThemeMode get themeMode => _themeMode;
  String get currency => _currency;
  bool get biometricEnabled => _biometricEnabled;
  bool get notificationsEnabled => _notificationsEnabled;

  Future<void> _loadSettings() async {
    _themeMode = ThemeMode.values[_prefs.getInt('theme_mode') ?? 0];
    _currency = _prefs.getString('currency') ?? '₹';
    _biometricEnabled = _prefs.getBool('biometric_enabled') ?? false;
    _notificationsEnabled = _prefs.getBool('notifications_enabled') ?? true;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _prefs.setInt('theme_mode', mode.index);
    notifyListeners();
  }

  Future<void> setCurrency(String currency) async {
    _currency = currency;
    await _prefs.setString('currency', currency);
    notifyListeners();
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    _biometricEnabled = enabled;
    await _prefs.setBool('biometric_enabled', enabled);
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    await _prefs.setBool('notifications_enabled', enabled);
    notifyListeners();
  }
} 