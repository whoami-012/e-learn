import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../../../core/constants/app_constants.dart';
import '../../../core/exceptions/auth_exception.dart';
import '../../../core/network/http_client.dart';
import 'models/live_class.dart';

class LiveClassApiService {
  static dynamic _body(http.Response response) {
    dynamic body;
    try {
      body = response.body.isEmpty ? null : jsonDecode(response.body);
    } catch (_) {}
    if (response.statusCode >= 200 && response.statusCode < 300) return body;
    final message = body is Map ? body['detail']?.toString() : null;
    if (response.statusCode == 401) throw const InvalidCredentialsException();
    throw ServerException(
        response.statusCode, message ?? 'Live class request failed.');
  }

  static Future<List<LiveClass>> list({String? status}) async {
    try {
      final uri = Uri.parse(AppConstants.liveClassesEndpoint)
          .replace(queryParameters: status == null ? null : {'status': status});
      final data = _body(await ApiClient.get(uri, withAuth: true)) as List;
      return data
          .map((e) => LiveClass.fromJson(e as Map<String, dynamic>))
          .toList();
    } on SocketException {
      throw const NetworkException();
    }
  }

  static Future<LiveClass> get(String id) async => LiveClass.fromJson(_body(
      await ApiClient.get(Uri.parse('${AppConstants.liveClassesEndpoint}/$id'),
          withAuth: true)) as Map<String, dynamic>);

  static Future<LiveClass> create(
          {required String courseId,
          required String title,
          String? description,
          required DateTime startsAt,
          required DateTime endsAt}) async =>
      LiveClass.fromJson(_body(await ApiClient.post(
          Uri.parse(AppConstants.liveClassesEndpoint),
          withAuth: true,
          body: {
            'course_id': courseId,
            'title': title,
            'description': description,
            'scheduled_start_time': startsAt.toUtc().toIso8601String(),
            'scheduled_end_time': endsAt.toUtc().toIso8601String()
          })) as Map<String, dynamic>);

  static Future<AgoraJoinCredentials> join(String id,
          {bool start = false}) async =>
      AgoraJoinCredentials.fromJson(_body(await ApiClient.post(
          Uri.parse(
              '${AppConstants.liveClassesEndpoint}/$id/${start ? 'start' : 'join'}'),
          withAuth: true)) as Map<String, dynamic>);

  static Future<AgoraJoinCredentials> refreshToken(String id) async =>
      AgoraJoinCredentials.fromJson(_body(await ApiClient.post(
          Uri.parse('${AppConstants.liveClassesEndpoint}/$id/refresh-token'),
          withAuth: true)) as Map<String, dynamic>);

  static Future<void> heartbeat(String id) async => _body(await ApiClient.post(
      Uri.parse('${AppConstants.liveClassesEndpoint}/$id/heartbeat'),
      withAuth: true));
  static Future<void> leave(String id) async => _body(await ApiClient.post(
      Uri.parse('${AppConstants.liveClassesEndpoint}/$id/leave'),
      withAuth: true));
  static Future<LiveClass> end(String id) async =>
      LiveClass.fromJson(_body(await ApiClient.post(
          Uri.parse('${AppConstants.liveClassesEndpoint}/$id/end'),
          withAuth: true)) as Map<String, dynamic>);
  static Future<LiveClass> cancel(String id) async =>
      LiveClass.fromJson(_body(await ApiClient.post(
          Uri.parse('${AppConstants.liveClassesEndpoint}/$id/cancel'),
          withAuth: true)) as Map<String, dynamic>);
  static Future<List<LiveClassAttendance>> attendance(String id) async {
    final data = _body(await ApiClient.get(
        Uri.parse('${AppConstants.liveClassesEndpoint}/$id/attendance'),
        withAuth: true)) as List;
    return data
        .map((e) => LiveClassAttendance.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
