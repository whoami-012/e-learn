/// app_constants.dart — Central place for all app-level constants.
library;

class AppConstants {
  AppConstants._(); // prevent instantiation

  // ── Server base URL ──────────────────────────────────────────────────────────
  /// Deployed backend server (AWS EC2).
  static const String serverBase = 'http://13.203.201.60';

  /// Base URL of the FastAPI backend.
  static const String baseUrl = '$serverBase/api/v1';

  // ── Auth endpoints ──────────────────────────────────────────────────────────
  static const String loginEndpoint = '$baseUrl/auth/login';
  static const String registerEndpoint = '$baseUrl/auth/register';
  static const String refreshEndpoint = '$baseUrl/auth/refresh';
  static const String meEndpoint = '$baseUrl/auth/me';

  // ── Course endpoints ───────────────────────────────────────────────────
  static const String coursesEndpoint = '$baseUrl/courses';

  // ── Enrollment endpoints ───────────────────────────────────────────────
  static const String enrollmentsEndpoint = '$baseUrl/enrollments';
  static const String liveClassesEndpoint = '$baseUrl/live-classes';

  // ── Notes endpoints ────────────────────────────────────────────────────
  static const String notesEndpoint = '$baseUrl/notes';

  // ── Upload endpoints ────────────────────────────────────────────────
  static const String uploadThumbnailEndpoint = '$baseUrl/upload/thumbnail';

  // ── Messages endpoints ───────────────────────────────────────────────
  static const String messagesContactsEndpoint = '$baseUrl/messages/contacts';
  static const String messagesConversationsEndpoint = '$baseUrl/messages/conversations';
  static const String messagesUnreadEndpoint = '$baseUrl/messages/unread-count';
  static const String messagesAttachmentEndpoint = '$baseUrl/messages/attachments';

  static String get wsUrl {
    final base = serverBase.replaceFirst('https://', 'wss://').replaceFirst('http://', 'ws://');
    return '$base/api/v1/messages/ws';
  }

  // ── Secure storage keys ─────────────────────────────────────────────────────
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String darkThemeKey = 'dark_theme_enabled';
}
