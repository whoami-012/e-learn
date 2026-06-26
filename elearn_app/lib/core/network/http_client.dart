/// http_client.dart — Centralised HTTP helper.
///
/// Adds the `ngrok-skip-browser-warning` header automatically when the
/// base URL points to an ngrok tunnel, bypassing the browser interstitial
/// page that ngrok shows for unauthenticated free-plan users.
library;

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import '../storage/token_storage.dart';

class ApiClient {
  // Singleton
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  /// Base headers sent with every request.
  /// Includes ngrok bypass header when the backend URL is an ngrok tunnel.
  static Map<String, String> get _baseHeaders => {
        'Content-Type': 'application/json',
        // Bypass ngrok browser interstitial for all API calls
        if (AppConstants.serverBase.contains('ngrok'))
          'ngrok-skip-browser-warning': 'true',
      };

  /// Merges [extra] headers on top of base headers (extra takes precedence).
  static Future<Map<String, String>> headers({
    bool withAuth = false,
    Map<String, String> extra = const {},
  }) async {
    final merged = Map<String, String>.from(_baseHeaders)..addAll(extra);
    if (withAuth) {
      final token = await TokenStorage.getAccessToken();
      if (token != null) merged['Authorization'] = 'Bearer $token';
    }
    return merged;
  }

  // ── Convenience wrappers ────────────────────────────────────────────────────

  static Future<http.Response> get(
    Uri url, {
    bool withAuth = false,
    Map<String, String> extra = const {},
  }) async {
    return http.get(url, headers: await headers(withAuth: withAuth, extra: extra));
  }

  static Future<http.Response> post(
    Uri url, {
    bool withAuth = false,
    Map<String, String> extra = const {},
    Object? body,
  }) async {
    return http.post(
      url,
      headers: await headers(withAuth: withAuth, extra: extra),
      body: body != null ? (body is String ? body : jsonEncode(body)) : null,
    );
  }

  static Future<http.Response> patch(
    Uri url, {
    bool withAuth = false,
    Map<String, String> extra = const {},
    Object? body,
  }) async {
    return http.patch(
      url,
      headers: await headers(withAuth: withAuth, extra: extra),
      body: body != null ? (body is String ? body : jsonEncode(body)) : null,
    );
  }

  static Future<http.Response> put(
    Uri url, {
    bool withAuth = false,
    Map<String, String> extra = const {},
    Object? body,
  }) async {
    return http.put(
      url,
      headers: await headers(withAuth: withAuth, extra: extra),
      body: body != null ? (body is String ? body : jsonEncode(body)) : null,
    );
  }

  static Future<http.Response> delete(
    Uri url, {
    bool withAuth = false,
    Map<String, String> extra = const {},
  }) async {
    return http.delete(url, headers: await headers(withAuth: withAuth, extra: extra));
  }
}
