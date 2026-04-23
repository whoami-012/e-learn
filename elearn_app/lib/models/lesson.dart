/// lesson.dart — Dart model mirroring backend YoutubeLessonResponse schema.
library;

class Lesson {
  final String id;
  final String courseId;
  final String title;
  final String videoId;
  final bool isPreview;
  final int orderIndex;

  const Lesson({
    required this.id,
    required this.courseId,
    required this.title,
    required this.videoId,
    required this.isPreview,
    required this.orderIndex,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) => Lesson(
        id:          json['id']          as String,
        courseId:    json['course_id']   as String,
        title:       json['title']       as String,
        videoId:     json['video_id']    as String,
        isPreview:   json['is_preview']  as bool? ?? false,
        orderIndex:  json['order_index'] as int,
      );
}
