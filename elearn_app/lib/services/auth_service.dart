/// auth_service.dart — Handles all authentication API calls.
///
/// Responsibilities:
///   - login()   → POST /auth/login  → saves tokens, returns user data
///   - logout()  → clears stored tokens
///   - refresh() → POST /auth/refresh → rotates token pair
///   - getMe()   → GET /auth/me → fetches current user profile
library;

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../core/constants/app_constants.dart';
import '../core/exceptions/auth_exception.dart';
import '../core/network/http_client.dart';
import '../core/storage/token_storage.dart';

// ── Response models ────────────────────────────────────────────────────────────

/// Mirrors the backend TokenResponse schema.
class TokenResponse {
  final String accessToken;
  final String refreshToken;
  final String tokenType;

  const TokenResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
  });

  factory TokenResponse.fromJson(Map<String, dynamic> json) => TokenResponse(
        accessToken:  json['access_token']  as String,
        refreshToken: json['refresh_token'] as String,
        tokenType:    json['token_type']    as String? ?? 'bearer',
      );
}

/// Mirrors the backend UserRead schema returned by GET /auth/me.
class UserProfile {
  final String id;
  final String email;
  final String name;
  final String role;
  final bool isActive;

  const UserProfile({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.isActive,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id:       json['id']        as String,
        email:    json['email']     as String,
        name:     json['name']      as String,
        role:     json['role']      as String,
        isActive: json['is_active'] as bool,
      );
}

// ── Service ────────────────────────────────────────────────────────────────────

class AuthService {
  AuthService._();

  // Base headers are handled by ApiClient (includes ngrok bypass automatically)

  // ── Helper: parse response ─────────────────────────────────────────────────

  /// Decodes the HTTP response body and throws typed exceptions for error codes.
  static Map<String, dynamic> _handleResponse(http.Response response) {
    final contentType = response.headers['content-type'] ?? '';
    Map<String, dynamic> body = const <String, dynamic>{};

    if (response.body.isNotEmpty && contentType.contains('application/json')) {
      try {
        body = jsonDecode(response.body) as Map<String, dynamic>;
      } on FormatException {
        throw ServerException(
          response.statusCode,
          'Invalid JSON response from server.',
        );
      }
    } else if (response.body.isNotEmpty && !contentType.contains('application/json')) {
      throw ServerException(
        response.statusCode,
        response.body,
      );
    }

    switch (response.statusCode) {
      case 200:
      case 201:
        return body;

      case 401:
        throw const InvalidCredentialsException();

      case 403:
        throw AccountDisabledException(
          (body['detail'] as String?) ?? 'Account access denied.',
        );

      case 409:
        throw ServerException(409, (body['detail'] as String?) ?? 'Conflict.');

      case 422:
        // FastAPI validation error — extract first message
        final errors = body['detail'] as List<dynamic>?;
        final msg = errors?.isNotEmpty == true
            ? errors!.first['msg'] as String? ?? 'Validation error'
            : 'Invalid request data';
        throw ServerException(422, msg);

      default:
        throw ServerException(
          response.statusCode,
          (body['detail'] as String?) ?? 'Unexpected server error.',
        );
    }
  }

  // ── login ──────────────────────────────────────────────────────────────────

  /// Authenticates the user with [email] and [password].
  ///
  /// On success: saves tokens securely and returns the [TokenResponse].
  /// On failure: throws [InvalidCredentialsException], [NetworkException], or [ServerException].
  static Future<TokenResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await ApiClient.post(
        Uri.parse(AppConstants.loginEndpoint),
        body: {'email': email, 'password': password},
      );

      final data = _handleResponse(response);
      final tokens = TokenResponse.fromJson(data);

      // Persist tokens securely after successful login
      await TokenStorage.saveTokens(
        accessToken:  tokens.accessToken,
        refreshToken: tokens.refreshToken,
      );

      return tokens;
    } on AuthException {
      rethrow; // let typed exceptions bubble up to UI
    } on SocketException {
      throw const NetworkException();
    } on http.ClientException {
      throw const NetworkException();
    }
  }

  // ── logout ─────────────────────────────────────────────────────────────────

  /// Clears stored tokens from secure storage.
  /// Call this on logout button press.
  static Future<void> logout() => TokenStorage.clearTokens();

  // ── register ───────────────────────────────────────────────────────────────

  /// Registers a new user account.
  ///
  /// Role is assigned server-side as 'student' — not sent by the client.
  /// Returns the created [UserProfile] on success.
  static Future<UserProfile> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await ApiClient.post(
        Uri.parse(AppConstants.registerEndpoint),
        body: {
          'name':     name,
          'email':    email.toLowerCase().trim(),
          'password': password,
        },
      );

      final data = _handleResponse(response);
      return UserProfile.fromJson(data);
    } on AuthException {
      rethrow;
    } on SocketException {
      throw const NetworkException();
    } on http.ClientException {
      throw const NetworkException();
    }
  }

  // ── refresh ────────────────────────────────────────────────────────────────

  /// Uses the stored refresh token to issue a new token pair.
  ///
  /// Call this when an API response returns 401 (access token expired).
  /// Returns the new [TokenResponse] or throws if the refresh token is also expired.
  static Future<TokenResponse> refresh() async {
    final refreshToken = await TokenStorage.getRefreshToken();
    if (refreshToken == null) {
      throw const InvalidCredentialsException();
    }

    try {
      final response = await ApiClient.post(
        Uri.parse(AppConstants.refreshEndpoint),
        body: {'refresh_token': refreshToken},
      );

      final data = _handleResponse(response);
      final tokens = TokenResponse.fromJson(data);

      // Update stored tokens with the new pair
      await TokenStorage.saveTokens(
        accessToken:  tokens.accessToken,
        refreshToken: tokens.refreshToken,
      );

      return tokens;
    } on AuthException {
      rethrow;
    } on SocketException {
      throw const NetworkException();
    }
  }

  // ── getMe ──────────────────────────────────────────────────────────────────

  /// Fetches the current authenticated user's profile.
  ///
  /// Automatically attaches the stored Bearer access token.
  static Future<UserProfile> getMe() async {
    final accessToken = await TokenStorage.getAccessToken();
    if (accessToken == null) {
      throw const InvalidCredentialsException();
    }

    try {
      final response = await ApiClient.get(
        Uri.parse(AppConstants.meEndpoint),
        withAuth: true,
      );

      final data = _handleResponse(response);
      return UserProfile.fromJson(data);
    } on AuthException {
      rethrow;
    } on SocketException {
      throw const NetworkException();
    }
  }
}
