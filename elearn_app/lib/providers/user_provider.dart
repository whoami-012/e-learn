/// user_provider.dart — Holds the currently authenticated user's profile.
///
/// Loaded after login / app startup. Used across the app to check roles.
library;

import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';

class UserProvider extends ChangeNotifier {
  UserProfile? _user;

  UserProfile? get user    => _user;
  String       get role    => _user?.role ?? 'student';
  bool         get isFaculty => _user?.role == 'faculty';
  bool         get isAdmin   => _user?.role == 'admin';
  bool         get hasUser   => _user != null;

  /// Load user from API and store in provider.
  /// Call after login or on app startup.
  Future<void> loadUser() async {
    try {
      final profile = await AuthService.getMe();
      _user = profile;
      notifyListeners();
    } catch (_) {
      // silently fail — auth gate will handle redirect
    }
  }

  void setUser(UserProfile user) {
    _user = user;
    notifyListeners();
  }

  /// Clear on logout.
  void clearUser() {
    _user = null;
    notifyListeners();
  }
}
