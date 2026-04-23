/// course_service.dart — HTTP service for the /courses API.
library;

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../core/constants/app_constants.dart';
import '../core/exceptions/auth_exception.dart';
import '../core/storage/token_storage.dart';
import '../models/course.dart'; // Course, CourseCreate, CourseUpdate
import '../models/lesson.dart';


class CourseService {
  static const _headers = {'Content-Type': 'application/json'};

  // ── Response handler ────────────────────────────────────────────────────────

  static Map<String, dynamic> _handleResponse(http.Response response) {
    Map<String, dynamic> body = {};
    try {
      if (response.body.isNotEmpty) {
        body = jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (_) {
      // Body is not JSON
    }

    switch (response.statusCode) {
      case 200:
      case 201:
        return body;
      case 401:
        throw const InvalidCredentialsException();
      case 403:
        final msg = body['detail'] ?? 'Only faculty can create courses.';
        throw ServerException(403, msg is String ? msg : 'Permission denied.');
      case 404:
        throw const ServerException(404, 'Course not found.');
      case 422:
        final errors = body['detail'];
        String msg = 'Invalid request data';
        if (errors is List && errors.isNotEmpty) {
          msg = errors.first['msg'] ?? 'Validation error';
        } else if (errors is String) {
          msg = errors;
        }
        throw ServerException(422, msg);
      default:
        final msg = body['detail'] ?? 'Unexpected server error (Status: ${response.statusCode}).';
        throw ServerException(
          response.statusCode,
          msg is String ? msg : 'Server error.',
        );
    }
  }

  // ── GET /courses/ ───────────────────────────────────────────────────────────

  static Future<List<Course>> getCourses() async {
    try {
      final response = await http.get(
        Uri.parse(AppConstants.coursesEndpoint),
        headers: _headers,
      );
      final body = jsonDecode(response.body);
      final list = body as List<dynamic>;
      return list.map((e) => Course.fromJson(e as Map<String, dynamic>)).toList();
    } on AuthException {
      rethrow;
    } on SocketException {
      throw const NetworkException();
    } on http.ClientException {
      throw const NetworkException();
    }
  }

  // ── GET /courses/{id} ───────────────────────────────────────────────────────

  static Future<Course> getCourseById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.coursesEndpoint}/$id'),
        headers: _headers,
      );
      final data = _handleResponse(response);
      return Course.fromJson(data);
    } on AuthException {
      rethrow;
    } on SocketException {
      throw const NetworkException();
    } on http.ClientException {
      throw const NetworkException();
    }
  }

  // ── GET /courses/{id}/lessons ────────────────────────────────────────────────

  static Future<List<Lesson>> getLessonsForCourse(String courseId) async {
    final token = await TokenStorage.getAccessToken();
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.coursesEndpoint}/$courseId/lessons/youtube'),
        headers: {
          ..._headers,
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body is List) {
          return body.map((e) => Lesson.fromJson(e as Map<String, dynamic>)).toList();
        } else if (body is Map && body.containsKey('lessons')) {
          // In case backend wraps it in a map like {"lessons": [...]}
          final list = body['lessons'] as List;
          return list.map((e) => Lesson.fromJson(e as Map<String, dynamic>)).toList();
        }
        throw const ServerException(500, 'Unexpected response format for lessons.');
      } else {
        _handleResponse(response); // This will throw based on status code
        return []; // Never reached
      }
    } on AuthException {
      rethrow;
    } on SocketException {
      throw const NetworkException();
    } on http.ClientException {
      throw const NetworkException();
    }
  }

  // ── POST /courses/ (faculty only) ───────────────────────────────────────────

  static Future<Course> createCourse(CourseCreate data) async {
    final token = await TokenStorage.getAccessToken();
    if (token == null) throw const InvalidCredentialsException();

    try {
      final response = await http.post(
        Uri.parse(AppConstants.coursesEndpoint),
        headers: {
          ..._headers,
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data.toJson()),
      );
      final body = _handleResponse(response);
      return Course.fromJson(body);
    } on AuthException {
      rethrow;
    } on SocketException {
      throw const NetworkException();
    } on http.ClientException {
      throw const NetworkException();
    }
  }

  // ── PATCH /courses/{id} (faculty/admin only) ─────────────────────────────────

  static Future<Course> updateCourse(String id, CourseUpdate data) async {
    final token = await TokenStorage.getAccessToken();
    if (token == null) throw const InvalidCredentialsException();

    try {
      final response = await http.patch(
        Uri.parse('${AppConstants.coursesEndpoint}/$id'),
        headers: {
          ..._headers,
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data.toJson()),
      );
      final body = _handleResponse(response);
      return Course.fromJson(body);
    } on AuthException {
      rethrow;
    } on SocketException {
      throw const NetworkException();
    } on http.ClientException {
      throw const NetworkException();
    }
  }
}
