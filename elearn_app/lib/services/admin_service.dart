import 'dart:convert';
import '../core/constants/app_constants.dart';
import '../core/exceptions/auth_exception.dart';
import '../core/network/http_client.dart';
import 'auth_service.dart'; // For UserProfile

class AdminService {
  Future<List<UserProfile>> listUsers({int skip = 0, int limit = 50}) async {
    final url = Uri.parse('${AppConstants.baseUrl}/users?skip=$skip&limit=$limit');
    final response = await ApiClient.get(url, withAuth: true);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => UserProfile.fromJson(e)).toList();
    } else {
      throw ServerException(response.statusCode, 'Failed to load users: ${response.body}');
    }
  }

  Future<UserProfile> updateUserRole(String userId, String role) async {
    final url = Uri.parse('${AppConstants.baseUrl}/users/$userId/role?role=$role');
    final response = await ApiClient.patch(url, withAuth: true);

    if (response.statusCode == 200) {
      return UserProfile.fromJson(jsonDecode(response.body));
    } else {
      throw ServerException(response.statusCode, 'Failed to update role: ${response.body}');
    }
  }

  Future<void> deleteUser(String userId) async {
    final url = Uri.parse('${AppConstants.baseUrl}/users/$userId');
    final response = await ApiClient.delete(url, withAuth: true);

    if (response.statusCode != 204) {
      throw ServerException(response.statusCode, 'Failed to delete user: ${response.body}');
    }
  }
}
