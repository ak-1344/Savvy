import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../providers/auth_provider.dart';
import '../models/user.dart';
import '../utils/error_handler.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      if (!mounted) return;

      // Create test account
      await Provider.of<AuthProvider>(context, listen: false)
          .createTestAccount();

      // Check if user is logged in
      final userBox = Hive.box<User>('users');
      final hasUser = userBox.isNotEmpty;

      // Navigate to appropriate screen
      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          hasUser ? '/home' : '/',
        );
      }
    } catch (e) {
      print('Initialization error: $e');
      if (mounted) {
        ErrorHandler.showError(context, e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Initializing...'),
          ],
        ),
      ),
    );
  }
}
