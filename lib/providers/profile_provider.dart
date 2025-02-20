import 'package:flutter/foundation.dart';
import '../models/user.dart';

class ProfileProvider with ChangeNotifier {
  final User _userProfile;

  ProfileProvider(this._userProfile);

  User get userProfile => _userProfile;

  Future<void> updateProfile({required String name}) async {
    _userProfile.name = name;
    notifyListeners();
  }

  Future<void> updateProfileImage(String path) async {
    _userProfile.imageUrl = path;
    notifyListeners();
  }
}
