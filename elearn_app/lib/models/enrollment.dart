/// enrollment.dart — Dart model for enrollment status.
library;

class EnrollmentStatus {
  final bool isEnrolled;

  const EnrollmentStatus({
    required this.isEnrolled,
  });

  factory EnrollmentStatus.fromJson(Map<String, dynamic> json) =>
      EnrollmentStatus(
        isEnrolled: json['is_enrolled'] as bool? ?? false,
      );
}
