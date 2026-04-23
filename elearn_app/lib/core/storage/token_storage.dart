/// token_storage.dart — Secure JWT token persistence using flutter_secure_storage.
///
/// Uses Android Keystore / iOS Keychain under the hood.
/// Tokens are never stored in plain SharedPreferences or local files.
library;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

class TokenStorage {
  TokenStorage._();

  static const _storage = FlutterSecureStorage(
    // Android: encrypt with AES, backed by Keystore
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  // ── Write ───────────────────────────────────────────────────────────────────

  /// Persists both tokens received after login / token refresh.
  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _storage.write(key: AppConstants.accessTokenKey,  value: accessToken),
      _storage.write(key: AppConstants.refreshTokenKey, value: refreshToken),
    ]);
  }

  // ── Read ────────────────────────────────────────────────────────────────────

  /// Returns the stored access token, or null if not found.
  static Future<String?> getAccessToken() =>
      _storage.read(key: AppConstants.accessTokenKey);

  /// Returns the stored refresh token, or null if not found.
  static Future<String?> getRefreshToken() =>
      _storage.read(key: AppConstants.refreshTokenKey);

  // ── Delete ──────────────────────────────────────────────────────────────────

  /// Clears both tokens — call on logout.
  static Future<void> clearTokens() async {
    await Future.wait([
      _storage.delete(key: AppConstants.accessTokenKey),
      _storage.delete(key: AppConstants.refreshTokenKey),
    ]);
  }

  /// Returns true if the user has an access token stored (approximate session check).
  static Future<bool> hasSession() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
