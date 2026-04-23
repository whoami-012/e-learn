/// app_constants.dart — Central place for all app-level constants.
library;

class AppConstants {
  AppConstants._(); // prevent instantiation

  /// Base server URL (no path prefix) — used for building static asset URLs.
  static const String serverBase = 'http://10.0.2.2:8000';

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
