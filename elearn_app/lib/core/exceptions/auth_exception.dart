/// auth_exception.dart — Typed exceptions for auth failures.
///
/// Allows the UI to distinguish between network errors, bad credentials,
/// server errors etc. and show appropriate messages.
library;

/// Base class for all auth-related errors.
class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}

/// Thrown when the server returns 401 — wrong email/password.
class InvalidCredentialsException extends AuthException {
  const InvalidCredentialsException([String? message])
      : super(message ?? 'Invalid email or password. Please try again.');
}

/// Thrown when the account is inactive or deleted (403).
class AccountDisabledException extends AuthException {
  const AccountDisabledException(super.message);
}

/// Thrown on any non-2xx response that isn't specifically handled.
class ServerException extends AuthException {
  final int statusCode;
  const ServerException(this.statusCode, super.message);
}

/// Thrown when the device has no internet connection or the server is unreachable.
class NetworkException extends AuthException {
  const NetworkException()
      : super('Network error. Please check your connection.');
}

class GoogleLoginException extends AuthException {
  const GoogleLoginException(super.message);
}

class AppleLoginException extends AuthException {
  const AppleLoginException(super.message);
}
