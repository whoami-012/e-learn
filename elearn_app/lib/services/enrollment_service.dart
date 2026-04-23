/// enrollment_service.dart — HTTP service for the /enrollments API.
library;

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../core/constants/app_constants.dart';
import '../core/exceptions/auth_exception.dart';
import '../core/storage/token_storage.dart';
import '../models/enrollment.dart';

class EnrollmentService {
  static const _headers = {'Content-Type': 'application/json'};

  static Map<String, dynamic> _handleResponse(http.Response response) {
    var body = <String, dynamic>{};
    if (response.body.isNotEmpty) {
      body = jsonDecode(response.body) as Map<String, dynamic>;
    }

    switch (response.statusCode) {
      case 200:
      case 201:
        return body;
      case 401:
        throw const InvalidCredentialsException();
      case 403:
        throw ServerException(403, 'Permission denied.');
      case 404:
        throw ServerException(404, 'Resource not found.');
      case 409: // Conflict, user already enrolled
        throw ServerException(409, 'Already enrolled.');
      case 422:
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

  // ── GET /enrollments/check/{course_id} ───────────────────────────────────────

  static Future<EnrollmentStatus> checkEnrollment(String courseId) async {
    final token = await TokenStorage.getAccessToken();
    if (token == null) {
      // If not logged in, not enrolled. Or throw exception based on flow.
      return const EnrollmentStatus(isEnrolled: false);
    }

    try {
      final response = await http.get(
        Uri.parse('${AppConstants.enrollmentsEndpoint}/check/$courseId'),
        headers: {
          ..._headers,
          'Authorization': 'Bearer $token',
        },
      );
      final data = _handleResponse(response);
      return EnrollmentStatus.fromJson(data);
    } on AuthException {
      rethrow;
    } on SocketException {
      throw const NetworkException();
    } on http.ClientException {
      throw const NetworkException();
    }
  }

  // ── POST /enrollments/{course_id} ───────────────────────────────────────────

  static Future<EnrollmentStatus> enroll(String courseId) async {
    final token = await TokenStorage.getAccessToken();
    if (token == null) throw const InvalidCredentialsException();

    try {
      final response = await http.post(
        Uri.parse('${AppConstants.enrollmentsEndpoint}/$courseId'),
        headers: {
          ..._headers,
          'Authorization': 'Bearer $token',
        },
      );
      final body = _handleResponse(response);
      return EnrollmentStatus.fromJson(body);
    } on AuthException {
      rethrow;
    } on SocketException {
      throw const NetworkException();
    } on http.ClientException {
      throw const NetworkException();
    }
  }
}
