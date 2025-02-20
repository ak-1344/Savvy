import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/biometric_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          _buildSection(
            context,
            'Appearance',
            [
              _buildThemeSelector(context),
              _buildCurrencySelector(context),
            ],
          ),
          _buildSection(
            context,
            'Security',
            [
              _buildBiometricToggle(context),
              _buildPasswordChange(context),
            ],
          ),
          _buildSection(
            context,
            'Notifications',
            [
              _buildNotificationSettings(context),
              _buildReminderSettings(context),
            ],
          ),
          _buildSection(
            context,
            'Data Management',
            [
              _buildExportData(context),
              _buildClearData(context),
            ],
          ),
          _buildSection(
            context,
            'Account',
            [
              _buildSignOut(context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ),
        ...children,
        const Divider(),
      ],
    );
  }

  Widget _buildThemeSelector(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        return ListTile(
          leading: const Icon(Icons.palette),
          title: const Text('Theme'),
          subtitle: Text(
            settings.themeMode == ThemeMode.system
                ? 'System'
                : settings.themeMode == ThemeMode.light
                    ? 'Light'
                    : 'Dark',
          ),
          onTap: () => _showThemeDialog(context),
        );
      },
    );
  }

  Widget _buildCurrencySelector(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        return ListTile(
          leading: const Icon(Icons.currency_rupee),
          title: const Text('Currency'),
          subtitle: Text(settings.currency),
          onTap: () => _showCurrencyDialog(context),
        );
      },
    );
  }

  Widget _buildBiometricToggle(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        return SwitchListTile(
          secondary: const Icon(Icons.fingerprint),
          title: const Text('Biometric Authentication'),
          subtitle: const Text('Use fingerprint or face ID to unlock'),
          value: settings.biometricEnabled,
          onChanged: (value) async {
            if (value) {
              final authenticated = await BiometricService.authenticate(
                'Enable biometric authentication',
              );
              if (authenticated) {
                settings.setBiometricEnabled(true);
              }
            } else {
              settings.setBiometricEnabled(false);
            }
          },
        );
      },
    );
  }

  Widget _buildPasswordChange(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.lock),
      title: const Text('Change Password'),
      onTap: () => Navigator.pushNamed(context, '/change-password'),
    );
  }

  Widget _buildNotificationSettings(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        return SwitchListTile(
          secondary: const Icon(Icons.notifications),
          title: const Text('Transaction Notifications'),
          subtitle: const Text('Get notified about new transactions'),
          value: settings.notificationsEnabled,
          onChanged: (value) => settings.setNotificationsEnabled(value),
        );
      },
    );
  }

  Widget _buildReminderSettings(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.alarm),
      title: const Text('Reminders'),
      subtitle: const Text('Set up recurring expense reminders'),
      onTap: () => Navigator.pushNamed(context, '/reminders'),
    );
  }

  Widget _buildExportData(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.download),
      title: const Text('Export Data'),
      subtitle: const Text('Download your financial data'),
      onTap: () => _exportData(context),
    );
  }

  Widget _buildClearData(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.delete_forever, color: Colors.red),
      title: const Text(
        'Clear All Data',
        style: TextStyle(color: Colors.red),
      ),
      onTap: () => _confirmClearData(context),
    );
  }

  Widget _buildSignOut(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.logout),
      title: const Text('Sign Out'),
      onTap: () => _confirmSignOut(context),
    );
  }

  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildThemeOption(context, ThemeMode.system, 'System'),
            _buildThemeOption(context, ThemeMode.light, 'Light'),
            _buildThemeOption(context, ThemeMode.dark, 'Dark'),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    ThemeMode mode,
    String label,
  ) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        return RadioListTile<ThemeMode>(
          title: Text(label),
          value: mode,
          groupValue: settings.themeMode,
          onChanged: (value) {
            if (value != null) {
              settings.setThemeMode(value);
              Navigator.pop(context);
            }
          },
        );
      },
    );
  }

  void _showCurrencyDialog(BuildContext context) {
    // Implement currency selection dialog
  }

  Future<void> _exportData(BuildContext context) async {
    // Implement data export
  }

  void _confirmClearData(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data?'),
        content: const Text(
          'This will permanently delete all your financial data. '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              // Implement data clearing
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('CLEAR'),
          ),
        ],
      ),
    );
  }

  void _confirmSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out?'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              context.read<AuthProvider>().signOut();
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text('SIGN OUT'),
          ),
        ],
      ),
    );
  }
} 