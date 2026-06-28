class LiveClass {
  final String id;
  final String courseId;
  final String facultyId;
  final String? facultyName;
  final String title;
  final String? description;
  final DateTime scheduledStartTime;
  final DateTime scheduledEndTime;
  final int durationMinutes;
  final String status;
  final DateTime? startedAt;
  final DateTime? endedAt;

  const LiveClass(
      {required this.id,
      required this.courseId,
      required this.facultyId,
      this.facultyName,
      required this.title,
      this.description,
      required this.scheduledStartTime,
      required this.scheduledEndTime,
      required this.durationMinutes,
      required this.status,
      this.startedAt,
      this.endedAt});

  factory LiveClass.fromJson(Map<String, dynamic> json) => LiveClass(
        id: json['id'] as String,
        courseId: json['course_id'] as String,
        facultyId: json['faculty_id'] as String,
        facultyName: json['faculty_name'] as String?,
        title: json['title'] as String,
        description: json['description'] as String?,
        scheduledStartTime:
            DateTime.parse(json['scheduled_start_time'] as String).toLocal(),
        scheduledEndTime:
            DateTime.parse(json['scheduled_end_time'] as String).toLocal(),
        durationMinutes: json['duration_minutes'] as int,
        status: json['status'] as String,
        startedAt: json['started_at'] == null
            ? null
            : DateTime.parse(json['started_at'] as String).toLocal(),
        endedAt: json['ended_at'] == null
            ? null
            : DateTime.parse(json['ended_at'] as String).toLocal(),
      );
}

class AgoraJoinCredentials {
  final String liveClassId;
  final String appId;
  final String channelName;
  final String token;
  final int uid;
  final String role;
  final DateTime tokenExpiresAt;
  final String title;
  final String facultyName;

  const AgoraJoinCredentials(
      {required this.liveClassId,
      required this.appId,
      required this.channelName,
      required this.token,
      required this.uid,
      required this.role,
      required this.tokenExpiresAt,
      required this.title,
      required this.facultyName});

  bool get isBroadcaster => role == 'broadcaster';

  factory AgoraJoinCredentials.fromJson(Map<String, dynamic> json) {
    final info = json['class'] as Map<String, dynamic>;
    return AgoraJoinCredentials(
        liveClassId: json['liveClassId'] as String,
        appId: json['appId'] as String,
        channelName: json['channelName'] as String,
        token: json['token'] as String,
        uid: json['uid'] as int,
        role: json['role'] as String,
        tokenExpiresAt: DateTime.parse(json['tokenExpiresAt'] as String),
        title: info['title'] as String,
        facultyName: info['facultyName'] as String);
  }
}

class LiveClassAttendance {
  final String studentId;
  final String? studentName;
  final DateTime joinedAt;
  final DateTime? leftAt;
  final int durationSeconds;
  final String status;
  const LiveClassAttendance(
      {required this.studentId,
      this.studentName,
      required this.joinedAt,
      this.leftAt,
      required this.durationSeconds,
      required this.status});
  factory LiveClassAttendance.fromJson(Map<String, dynamic> json) =>
      LiveClassAttendance(
          studentId: json['student_id'] as String,
          studentName: json['student_name'] as String?,
          joinedAt: DateTime.parse(json['joined_at'] as String).toLocal(),
          leftAt: json['left_at'] == null
              ? null
              : DateTime.parse(json['left_at'] as String).toLocal(),
          durationSeconds: json['duration_seconds'] as int,
          status: json['attendance_status'] as String);
}
