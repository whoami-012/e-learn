class Exam {
  final String id;
  final String courseId;
  final String title;
  final int durationMinutes;
  final DateTime createdAt;

  Exam({
    required this.id,
    required this.courseId,
    required this.title,
    required this.durationMinutes,
    required this.createdAt,
  });

  factory Exam.fromJson(Map<String, dynamic> json) {
    return Exam(
      id: json['id'],
      courseId: json['course_id'],
      title: json['title'],
      durationMinutes: json['duration_minutes'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'course_id': courseId,
      'title': title,
      'duration_minutes': durationMinutes,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class Question {
  final String id;
  final String examId;
  final String questionText;
  final Map<String, String> options;
  final String? correctAnswer;

  Question({
    required this.id,
    required this.examId,
    required this.questionText,
    required this.options,
    this.correctAnswer,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      examId: json['exam_id'],
      questionText: json['question_text'],
      options: Map<String, String>.from(json['options']),
      correctAnswer: json['correct_answer'], // Only present for faculty/admin
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'exam_id': examId,
      'question_text': questionText,
      'options': options,
      if (correctAnswer != null) 'correct_answer': correctAnswer,
    };
  }
}

class Attempt {
  final String id;
  final String examId;
  final String userId;
  final Map<String, String> answers;
  final int score;
  final int total;
  final double percentage;
  final int attemptNumber;
  final DateTime submittedAt;

  Attempt({
    required this.id,
    required this.examId,
    required this.userId,
    required this.answers,
    required this.score,
    required this.total,
    required this.percentage,
    required this.attemptNumber,
    required this.submittedAt,
  });

  factory Attempt.fromJson(Map<String, dynamic> json) {
    return Attempt(
      id: json['id'],
      examId: json['exam_id'],
      userId: json['user_id'],
      answers: Map<String, String>.from(json['answers']),
      score: json['score'],
      total: json['total'],
      percentage: (json['percentage'] as num).toDouble(),
      attemptNumber: json['attempt_number'],
      submittedAt: DateTime.parse(json['submitted_at']),
    );
  }
}
