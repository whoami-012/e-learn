/// course.dart — Dart models mirroring backend CourseCreate / CourseResponse schemas.
library;

class Course {
  final String id;
  final String title;
  final String description;
  final double price;
  final bool isFree;
  final String? thumbnailUrl;
  final String? facultyId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Course({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.isFree,
    this.thumbnailUrl,
    this.facultyId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Course.fromJson(Map<String, dynamic> json) => Course(
        id:           json['id']            as String,
        title:        json['title']         as String,
        description:  json['description']   as String,
        price:        (json['price'] as num).toDouble(),
        isFree:       json['is_free']       as bool,
        thumbnailUrl: json['thumbnail_url'] as String?,
        facultyId:    json['faculty_id']    as String?,
        createdAt:    DateTime.parse(json['created_at'] as String),
        updatedAt:    DateTime.parse(json['updated_at'] as String),
      );
}


class CourseCreate {
  final String title;
  final String description;
  final double price;
  final bool isFree;
  final String? thumbnailUrl;

  const CourseCreate({
    required this.title,
    required this.description,
    required this.price,
    this.isFree = false,
    this.thumbnailUrl,
  });

  Map<String, dynamic> toJson() => {
        'title':         title,
        'description':   description,
        'price':         price,
        'is_free':       isFree,
        if (thumbnailUrl != null) 'thumbnail_url': thumbnailUrl,
      };
}


class CourseUpdate {
  final String? title;
  final String? description;
  final double? price;
  final bool? isFree;
  final String? thumbnailUrl;

  const CourseUpdate({
    this.title,
    this.description,
    this.price,
    this.isFree,
    this.thumbnailUrl,
  });

  /// Only include fields that are non-null (PATCH semantics)
  Map<String, dynamic> toJson() => {
        if (title != null)        'title':         title,
        if (description != null)  'description':   description,
        if (price != null)        'price':         price,
        if (isFree != null)       'is_free':       isFree,
        if (thumbnailUrl != null) 'thumbnail_url': thumbnailUrl,
      };
}
