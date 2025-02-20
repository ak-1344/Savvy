import 'package:hive/hive.dart';

class SettingsService {
  final Box _settingsBox = Hive.box('settings');
  static const String _currencyKey = 'defaultCurrency';
  static const String _notificationsKey = 'notificationsEnabled';

  String get defaultCurrency =>
      _settingsBox.get(_currencyKey, defaultValue: 'INR');

  bool get notificationsEnabled =>
      _settingsBox.get(_notificationsKey, defaultValue: true);

  Future<void> setDefaultCurrency(String currency) async {
    await _settingsBox.put(_currencyKey, currency);
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    await _settingsBox.put(_notificationsKey, enabled);
  }

  Future<void> clearSettings() async {
    await _settingsBox.clear();
  }
}
