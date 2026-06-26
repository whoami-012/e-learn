/// course_service.dart — HTTP service for the /courses API.
library;

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../core/constants/app_constants.dart';
import '../core/exceptions/auth_exception.dart';
import '../core/network/http_client.dart';
import '../models/course.dart';
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
      final response = await ApiClient.get(
        Uri.parse(AppConstants.coursesEndpoint),
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
      final response = await ApiClient.get(
        Uri.parse('${AppConstants.coursesEndpoint}/$id'),
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
    try {
      final response = await ApiClient.get(
        Uri.parse('${AppConstants.coursesEndpoint}/$courseId/lessons/youtube'),
        withAuth: true,
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

  // ── POST /courses/{courseId}/lessons/youtube (faculty/admin only) ────────────

  static Future<Lesson> createYoutubeLesson({
    required String courseId,
    required String title,
    required String videoId,
    required int orderIndex,
    required bool isPreview,
  }) async {
    try {
      final response = await ApiClient.post(
        Uri.parse('${AppConstants.coursesEndpoint}/$courseId/lessons/youtube'),
        withAuth: true,
        body: {
          'title': title,
          'video_id': videoId,
          'order_index': orderIndex,
          'is_preview': isPreview,
        },
      );
      final body = _handleResponse(response);
      return Lesson.fromJson(body);
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
    try {
      final response = await ApiClient.post(
        Uri.parse(AppConstants.coursesEndpoint),
        withAuth: true,
        body: data.toJson(),
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
    try {
      final response = await ApiClient.patch(
        Uri.parse('${AppConstants.coursesEndpoint}/$id'),
        withAuth: true,
        body: data.toJson(),
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

  // ── DELETE /courses/{id} (faculty/admin only) ────────────────────────────────

  static Future<void> deleteCourse(String id) async {
    try {
      final response = await ApiClient.delete(
        Uri.parse('${AppConstants.coursesEndpoint}/$id'),
        withAuth: true,
      );
      
      if (response.statusCode != 204) {
        _handleResponse(response);
      }
    } on AuthException {
      rethrow;
    } on SocketException {
      throw const NetworkException();
    } on http.ClientException {
      throw const NetworkException();
    }
  }
}

