/// app_constants.dart — Central place for all app-level constants.
library;

class AppConstants {
  AppConstants._(); // prevent instantiation

  // ── Environment toggle ──────────────────────────────────────────────────────
  /// Set to true to use ngrok (real device / public testing).
  /// Set to false to use local Android emulator (10.0.2.2).
  static const bool _useNgrok = true;

  /// Your ngrok public URL — update this every time ngrok restarts.
  /// Example: 'https://abc123.ngrok-free.app'
  static const String _ngrokBase = 'https://unflawed-grandly-hypnotism.ngrok-free.dev';

  /// Local emulator base — 10.0.2.2 maps to host machine localhost.
  static const String _localBase = 'http://10.0.2.2:8000';

  /// Base server URL (no path prefix) — used for building static asset URLs.
  static const String serverBase = _useNgrok ? _ngrokBase : _localBase;

  /// Base URL of the FastAPI backend.
  static const String baseUrl = '$serverBase/api/v1';

  // ── Auth endpoints ──────────────────────────────────────────────────────────
  static const String loginEndpoint    = '$baseUrl/auth/login';
  static const String registerEndpoint = '$baseUrl/auth/register';
  static const String refreshEndpoint  = '$baseUrl/auth/refresh';
  static const String meEndpoint       = '$baseUrl/auth/me';

  // ── Course endpoints ───────────────────────────────────────────────────
  static const String coursesEndpoint = '$baseUrl/courses';

  // ── Enrollment endpoints ───────────────────────────────────────────────
  static const String enrollmentsEndpoint = '$baseUrl/enrollments';

  // ── Notes endpoints ────────────────────────────────────────────────────
  static const String notesEndpoint = '$baseUrl/notes';

  // ── Upload endpoints ────────────────────────────────────────────────
  static const String uploadThumbnailEndpoint = '$baseUrl/upload/thumbnail';

  // ── Secure storage keys ─────────────────────────────────────────────────────
  static const String accessTokenKey  = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
}
