import 'package:flutter/foundation.dart';
import '../services/auth_service.dart'; // UserProfile
import '../services/admin_service.dart';

class AdminProvider extends ChangeNotifier {
  final AdminService _adminService = AdminService();

  List<UserProfile> _users = [];
  bool _isLoading = false;
  String? _error;

  List<UserProfile> get users => _users;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchUsers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _users = await _adminService.listUsers();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUserRole(String userId, String newRole) async {
    try {
      final updatedUser = await _adminService.updateUserRole(userId, newRole);
      final index = _users.indexWhere((u) => u.id == userId);
      if (index != -1) {
        _users[index] = updatedUser;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      await _adminService.deleteUser(userId);
      _users.removeWhere((u) => u.id == userId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }
}
