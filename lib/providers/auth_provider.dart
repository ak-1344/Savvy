import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  final Box<User> _userBox = Hive.box<User>('users');
  final SharedPreferences _prefs;
  User? _currentUser;
  bool _isAuthenticated = false;

  AuthProvider(this._prefs) {
    _init();
  }

  bool get isAuthenticated => _isAuthenticated;
  User? get currentUser => _currentUser;

  void _init() {
    final userId = _prefs.getString('current_user_id');
    if (userId != null) {
      _currentUser = _userBox.get(userId);
      _isAuthenticated = _currentUser != null;
      notifyListeners();
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      // For testing purposes, create a test account if it doesn't exist
      if (email == 'test@example.com' && password == 'test123') {
        if (_userBox.values.isEmpty) {
          await createTestAccount();
        }

        _currentUser = _userBox.values.firstWhere(
          (user) => user.email == email && user.password == password,
        );
        _isAuthenticated = true;
        await _prefs.setString('current_user_id', _currentUser!.id);
        notifyListeners();
        return;
      }

      // Normal login logic
      final user = _userBox.values.firstWhere(
        (user) => user.email == email && user.password == password,
      );
      _currentUser = user;
      _isAuthenticated = true;
      await _prefs.setString('current_user_id', user.id);
      notifyListeners();
    } catch (e) {
      throw Exception('Invalid credentials');
    }
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      // Check if email already exists
      final exists = _userBox.values.any((user) => user.email == email);
      if (exists) {
        throw Exception('Email already registered');
      }

      // Create new user
      final user = User(
        id: const Uuid().v4(),
        name: name,
        email: email,
        password: password,
      );

      await _userBox.put(user.id, user);
      _currentUser = user;
      _isAuthenticated = true;
      await _prefs.setString('current_user_id', user.id);
      notifyListeners();
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  Future<void> signOut() async {
    _currentUser = null;
    _isAuthenticated = false;
    await _prefs.remove('current_user_id');
    notifyListeners();
  }

  Future<void> updateProfile({String? name, String? profilePicture}) async {
    if (_currentUser == null) return;

    final user = _currentUser!;
    if (name != null) user.name = name;
    if (profilePicture != null) user.profilePicture = profilePicture;

    await _userBox.put(user.id, user);
    notifyListeners();
  }

  Future<void> createTestAccount() async {
    final testUser = User(
      id: const Uuid().v4(),
      name: 'Test User',
      email: 'test@example.com',
      password: 'test123',
    );
    await _userBox.put(testUser.id, testUser);
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {
    if (_currentUser == null) throw Exception('Not authenticated');

    if (_currentUser!.password != oldPassword) {
      throw Exception('Invalid current password');
    }

    _currentUser!.password = newPassword;
    await _userBox.put(_currentUser!.id, _currentUser!);
    notifyListeners();
  }
}
