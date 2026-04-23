/// note_service.dart — HTTP service for notes APIs.
library;

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../core/constants/app_constants.dart';
import '../core/exceptions/auth_exception.dart';
import '../core/storage/token_storage.dart';
import '../models/note.dart';

class NoteService {
  static const _headers = {'Content-Type': 'application/json'};

  static Map<String, dynamic> _handleResponse(http.Response response) {
    final body = jsonDecode(response.body) as Map<String, dynamic>;

    switch (response.statusCode) {
      case 200:
      case 201:
        return body;
      case 401:
        throw const InvalidCredentialsException();
      case 403:
        throw ServerException(403, body['detail'] ?? 'Permission denied.');
      case 404:
        throw ServerException(404, 'Note not found.');
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

  // ── GET /courses/{course_id}/notes ─────────────────────────────────────

  static Future<List<Note>> getNotesByCourse(String courseId) async {
    final token = await TokenStorage.getAccessToken();
    // Allow fetching notes even if not logged in (to see locked states)
    final headers = Map<String, String>.from(_headers);
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    try {
      final response = await http.get(
        Uri.parse('${AppConstants.notesEndpoint}/courses/$courseId'),
        headers: headers,
      );
      
      final body = jsonDecode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
         final list = body as List<dynamic>;
         return list.map((e) => Note.fromJson(e as Map<String, dynamic>)).toList();
      }
      _handleResponse(response); // Will throw exception
      return [];
    } on AuthException {
      rethrow;
    } on SocketException {
      throw const NetworkException();
    } on http.ClientException {
      throw const NetworkException();
    }
  }

  // ── GET /notes/{note_id} ───────────────────────────────────────────────

  static Future<Note> getNoteById(String noteId) async {
    final token = await TokenStorage.getAccessToken();
    final headers = Map<String, String>.from(_headers);
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    try {
      final response = await http.get(
        Uri.parse('${AppConstants.notesEndpoint}/$noteId'),
        headers: headers,
      );
      final data = _handleResponse(response);
      return Note.fromJson(data);
    } on AuthException {
      rethrow;
    } on SocketException {
      throw const NetworkException();
    } on http.ClientException {
      throw const NetworkException();
    }
  }
}
