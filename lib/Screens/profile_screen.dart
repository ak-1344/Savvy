import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../multiprovider/providers/theme_provider.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>(); // Corrected way to watch the provider

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: ListView(
        children: [
          _buildHeader(context),
          _buildOption(context, 'Edit Profile', Icons.person_outline, () {
            // TODO: Implement edit profile functionality
          }),
          _buildOption(context, 'Manage Accounts', Icons.account_balance_wallet_outlined, () {
            // TODO: Implement manage accounts functionality
          }),
          _buildOption(context, 'Notifications', Icons.notifications_none, () {
            // TODO: Implement notifications settings
          }),
          _buildDarkModeSwitch(context, themeProvider), // Dark mode switch
          _buildOption(context, 'Help & Support', Icons.help_outline, () {
            // TODO: Implement help & support functionality
          }),
          _buildOption(context, 'Logout', Icons.exit_to_app, () {
            // TODO: Implement logout functionality
          }),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: AssetImage('assets/profile_picture.png'), // Default profile picture
          ),
          SizedBox(height: 16),
          Text(
            'John Doe',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Text(
            'john.doe@example.com',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildOption(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildDarkModeSwitch(BuildContext context, ThemeProvider themeProvider) {
    return SwitchListTile(
      title: Text('Dark Mode'),
      value: themeProvider.isDarkMode,
      onChanged: (value) {
        themeProvider.toggleTheme();
      },
    );
  }
}
