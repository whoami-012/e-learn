import 'live_class_api_service.dart';
import 'models/live_class.dart';

class LiveClassRepository {
  Future<List<LiveClass>> list({String? status}) =>
      LiveClassApiService.list(status: status);
  Future<LiveClass> get(String id) => LiveClassApiService.get(id);
  Future<LiveClass> create(
          {required String courseId,
          required String title,
          String? description,
          required DateTime startsAt,
          required DateTime endsAt}) =>
      LiveClassApiService.create(
          courseId: courseId,
          title: title,
          description: description,
          startsAt: startsAt,
          endsAt: endsAt);
  Future<AgoraJoinCredentials> join(String id, {bool start = false}) =>
      LiveClassApiService.join(id, start: start);
  Future<AgoraJoinCredentials> refreshToken(String id) =>
      LiveClassApiService.refreshToken(id);
  Future<void> heartbeat(String id) => LiveClassApiService.heartbeat(id);
  Future<void> leave(String id) => LiveClassApiService.leave(id);
  Future<LiveClass> end(String id) => LiveClassApiService.end(id);
  Future<LiveClass> cancel(String id) => LiveClassApiService.cancel(id);
  Future<List<LiveClassAttendance>> attendance(String id) =>
      LiveClassApiService.attendance(id);
}
