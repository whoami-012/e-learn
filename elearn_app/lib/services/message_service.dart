import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../core/constants/app_constants.dart';
import '../core/exceptions/auth_exception.dart';
import '../core/network/http_client.dart';
import '../core/storage/token_storage.dart';

class MessageService {
  MessageService._();

  static Map<String, dynamic> _handleResponse(http.Response response) {
    Map<String, dynamic> body = {};
    try {
      if (response.body.isNotEmpty) {
        body = jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (_) {}

    switch (response.statusCode) {
      case 200:
      case 201:
        return body;
      case 204:
        return {};
      case 401:
        throw const InvalidCredentialsException();
      case 403:
        throw ServerException(403, (body['detail'] as String?) ?? 'Permission denied.');
      case 404:
        throw ServerException(404, (body['detail'] as String?) ?? 'Not found.');
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
        throw ServerException(
          response.statusCode,
          (body['detail'] as String?) ?? 'Request failed.',
        );
    }
  }

  // ── Contacts ───────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> getContacts({
    String? search,
    String? role,
    String? courseId,
  }) async {
    final queryParams = <String, String>{};
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (role != null && role.isNotEmpty) queryParams['role'] = role;
    if (courseId != null && courseId.isNotEmpty) queryParams['course_id'] = courseId;

    final uri = Uri.parse(AppConstants.messagesContactsEndpoint).replace(queryParameters: queryParams);
    try {
      final response = await ApiClient.get(uri, withAuth: true);
      return _handleResponse(response);
    } on SocketException {
      throw const NetworkException();
    }
  }

  // ── Conversations ──────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> listConversations({
    String filter = 'all',
    String? search,
    String? cursor,
  }) async {
    final queryParams = <String, String>{'filter': filter};
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (cursor != null && cursor.isNotEmpty) queryParams['cursor'] = cursor;

    final uri = Uri.parse(AppConstants.messagesConversationsEndpoint).replace(queryParameters: queryParams);
    try {
      final response = await ApiClient.get(uri, withAuth: true);
      return _handleResponse(response);
    } on SocketException {
      throw const NetworkException();
    }
  }

  static Future<Map<String, dynamic>> startConversation(String receiverId) async {
    final uri = Uri.parse(AppConstants.messagesConversationsEndpoint);
    try {
      final response = await ApiClient.post(
        uri,
        withAuth: true,
        body: {'receiver_id': receiverId},
      );
      return _handleResponse(response);
    } on SocketException {
      throw const NetworkException();
    }
  }

  static Future<Map<String, dynamic>> getConversation(String conversationId) async {
    final uri = Uri.parse('${AppConstants.messagesConversationsEndpoint}/$conversationId');
    try {
      final response = await ApiClient.get(uri, withAuth: true);
      return _handleResponse(response);
    } on SocketException {
      throw const NetworkException();
    }
  }

  // ── Messages ───────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> listMessages(
    String conversationId, {
    String? cursor,
    int limit = 30,
  }) async {
    final queryParams = <String, String>{'limit': limit.toString()};
    if (cursor != null && cursor.isNotEmpty) queryParams['cursor'] = cursor;

    final uri = Uri.parse('${AppConstants.messagesConversationsEndpoint}/$conversationId/messages')
        .replace(queryParameters: queryParams);
    try {
      final response = await ApiClient.get(uri, withAuth: true);
      return _handleResponse(response);
    } on SocketException {
      throw const NetworkException();
    }
  }

  static Future<Map<String, dynamic>> sendMessage(
    String conversationId,
    String content,
    String clientMessageId,
  ) async {
    final uri = Uri.parse('${AppConstants.messagesConversationsEndpoint}/$conversationId/messages');
    try {
      final response = await ApiClient.post(
        uri,
        withAuth: true,
        body: {
          'content': content,
          'client_message_id': clientMessageId,
        },
      );
      return _handleResponse(response);
    } on SocketException {
      throw const NetworkException();
    }
  }

  static Future<Map<String, dynamic>> sendMessageUpload({
    required String conversationId,
    required File file,
    String? content,
    required String clientMessageId,
  }) async {
    final token = await TokenStorage.getAccessToken();
    if (token == null) throw const InvalidCredentialsException();

    try {
      final uri = Uri.parse('${AppConstants.messagesConversationsEndpoint}/$conversationId/messages/upload');
      final request = http.MultipartRequest('POST', uri);

      request.headers['Authorization'] = 'Bearer $token';
      if (AppConstants.serverBase.contains('ngrok')) {
        request.headers['ngrok-skip-browser-warning'] = 'true';
      }

      request.files.add(await http.MultipartFile.fromPath(
        'file',
        file.path,
        contentType: MediaType.parse(_mimeType(file.path)),
      ));

      if (content != null && content.isNotEmpty) {
        request.fields['content'] = content;
      }
      request.fields['client_message_id'] = clientMessageId;

      final streamed = await request.send();
      final responseBody = await streamed.stream.bytesToString();

      Map<String, dynamic> body = {};
      try {
        if (responseBody.isNotEmpty) {
          body = jsonDecode(responseBody) as Map<String, dynamic>;
        }
      } catch (_) {}

      switch (streamed.statusCode) {
        case 200:
        case 201:
          return body;
        case 401:
          throw const InvalidCredentialsException();
        default:
          throw ServerException(
            streamed.statusCode,
            (body['detail'] as String?) ?? 'Upload failed.',
          );
      }
    } on SocketException {
      throw const NetworkException();
    }
  }

  static Future<void> markRead(String conversationId, String lastReadMessageId) async {
    final uri = Uri.parse('${AppConstants.messagesConversationsEndpoint}/$conversationId/read');
    try {
      final response = await ApiClient.post(
        uri,
        withAuth: true,
        body: {'last_read_message_id': lastReadMessageId},
      );
      _handleResponse(response);
    } on SocketException {
      throw const NetworkException();
    }
  }

  static Future<int> getUnreadCount() async {
    final uri = Uri.parse(AppConstants.messagesUnreadEndpoint);
    try {
      final response = await ApiClient.get(uri, withAuth: true);
      final body = _handleResponse(response);
      return body['unread_count'] as int? ?? 0;
    } on SocketException {
      throw const NetworkException();
    }
  }

  // ── Downloads / Attachment bytes ───────────────────────────────────────────

  static Future<http.Response> downloadAttachment(String attachmentId) async {
    final uri = Uri.parse('${AppConstants.messagesAttachmentEndpoint}/$attachmentId');
    try {
      return await ApiClient.get(uri, withAuth: true);
    } on SocketException {
      throw const NetworkException();
    }
  }

  // ── Helper ─────────────────────────────────────────────────────────────────

  static String _mimeType(String path) {
    final ext = path.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'xls':
        return 'application/vnd.ms-excel';
      case 'xlsx':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      case 'txt':
        return 'text/plain';
      case 'zip':
        return 'application/zip';
      default:
        return 'application/octet-stream';
    }
  }
}
