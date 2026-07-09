/// app_constants.dart — Central place for all app-level constants.
library;

class AppConstants {
  AppConstants._(); // prevent instantiation

  // ── Server base URL ──────────────────────────────────────────────────────────
  /// Backend origin selected when the app is built. Do not include a trailing slash.
  static const String serverBase = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://13.203.201.60',
  );

  /// Base URL of the FastAPI backend.
  static const String baseUrl = '$serverBase/api/v1';

  /// Public origin reported to embedded YouTube players for API client
  /// identity. Override for Flutter Web with --dart-define when its public
  /// website origin differs from the API origin.
  static const String youtubeEmbedOrigin = String.fromEnvironment(
    'YOUTUBE_EMBED_ORIGIN',
    defaultValue: serverBase,
  );

  // ── Auth endpoints ──────────────────────────────────────────────────────────
  static const String loginEndpoint = '$baseUrl/auth/login';
  static const String registerEndpoint = '$baseUrl/auth/register';
  static const String refreshEndpoint = '$baseUrl/auth/refresh';
  static const String meEndpoint = '$baseUrl/auth/me';
  static const String changePasswordEndpoint = '$baseUrl/auth/change-password';
  static const String googleLoginEndpoint =
      '$serverBase/api/auth/google-login/';
  static const String appleLoginEndpoint = '$serverBase/api/auth/apple-login/';
  static const String appleServiceId = String.fromEnvironment(
    'APPLE_SERVICE_ID',
    defaultValue: 'com.example.elearnApp',
  );
  static const String appleRedirectUri = String.fromEnvironment(
    'APPLE_REDIRECT_URI',
    defaultValue: '$serverBase/api/auth/apple-callback',
  );

  /// Must match the backend GOOGLE_CLIENT_ID and Firebase Web OAuth client ID.
  static const String googleServerClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
    defaultValue:
        '949329981376-3h45u3mtb8n1j4bpdkn6qdtempj3hkrc.apps.googleusercontent.com',
  );

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
  static const String messagesConversationsEndpoint =
      '$baseUrl/messages/conversations';
  static const String messagesUnreadEndpoint = '$baseUrl/messages/unread-count';
  static const String messagesAttachmentEndpoint =
      '$baseUrl/messages/attachments';

  static String get wsUrl {
    final base = serverBase
        .replaceFirst('https://', 'wss://')
        .replaceFirst('http://', 'ws://');
    return '$base/api/v1/messages/ws';
  }

  // ── Secure storage keys ─────────────────────────────────────────────────────
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String darkThemeKey = 'dark_theme_enabled';
}
