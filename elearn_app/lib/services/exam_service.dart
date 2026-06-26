import 'dart:convert';
import '../core/constants/app_constants.dart';
import '../core/exceptions/auth_exception.dart';
import '../core/network/http_client.dart';
import '../models/exam.dart';

class ExamService {
  // EXAMS
  Future<List<Exam>> getExamsByCourse(String courseId) async {
    final url = Uri.parse('${AppConstants.baseUrl}/courses/$courseId/exams');
    final response = await ApiClient.get(url, withAuth: true);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Exam.fromJson(e)).toList();
    } else {
      throw ServerException(response.statusCode, 'Failed to load exams: ${response.body}');
    }
  }

  Future<Exam> createExam(String courseId, String title, int durationMinutes) async {
    final url = Uri.parse('${AppConstants.baseUrl}/courses/$courseId/exams');
    final response = await ApiClient.post(url, withAuth: true, body: {
      'title': title,
      'duration_minutes': durationMinutes,
    });

    if (response.statusCode == 201) {
      return Exam.fromJson(jsonDecode(response.body));
    } else {
      throw ServerException(response.statusCode, 'Failed to create exam: ${response.body}');
    }
  }

  Future<Exam> updateExam(String examId, String title, int durationMinutes) async {
    final url = Uri.parse('${AppConstants.baseUrl}/exams/$examId');
    final response = await ApiClient.patch(url, withAuth: true, body: {
      'title': title,
      'duration_minutes': durationMinutes,
    });

    if (response.statusCode == 200) {
      return Exam.fromJson(jsonDecode(response.body));
    } else {
      throw ServerException(response.statusCode, 'Failed to update exam: ${response.body}');
    }
  }

  Future<void> deleteExam(String examId) async {
    final url = Uri.parse('${AppConstants.baseUrl}/exams/$examId');
    final response = await ApiClient.delete(url, withAuth: true);

    if (response.statusCode != 204) {
      throw ServerException(response.statusCode, 'Failed to delete exam: ${response.body}');
    }
  }

  // QUESTIONS
  Future<List<Question>> getQuestionsByExam(String examId) async {
    final url = Uri.parse('${AppConstants.baseUrl}/exams/$examId/questions');
    final response = await ApiClient.get(url, withAuth: true);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Question.fromJson(e)).toList();
    } else {
      throw ServerException(response.statusCode, 'Failed to load questions: ${response.body}');
    }
  }

  Future<Question> addQuestion(
      String examId, String text, Map<String, String> options, String correctAnswer) async {
    final url = Uri.parse('${AppConstants.baseUrl}/exams/$examId/questions');
    final response = await ApiClient.post(url, withAuth: true, body: {
      'question_text': text,
      'options': options,
      'correct_answer': correctAnswer,
    });

    if (response.statusCode == 201) {
      return Question.fromJson(jsonDecode(response.body));
    } else {
      throw ServerException(response.statusCode, 'Failed to add question: ${response.body}');
    }
  }

  Future<void> deleteQuestion(String questionId) async {
    final url = Uri.parse('${AppConstants.baseUrl}/questions/$questionId');
    final response = await ApiClient.delete(url, withAuth: true);

    if (response.statusCode != 204) {
      throw ServerException(response.statusCode, 'Failed to delete question: ${response.body}');
    }
  }

  // ATTEMPTS
  Future<Attempt> submitAttempt(String examId, Map<String, String> answers) async {
    final url = Uri.parse('${AppConstants.baseUrl}/exams/$examId/attempt');
    final response = await ApiClient.post(url, withAuth: true, body: {'answers': answers});

    if (response.statusCode == 201) {
      return Attempt.fromJson(jsonDecode(response.body));
    } else {
      throw ServerException(response.statusCode, 'Failed to submit attempt: ${response.body}');
    }
  }

  Future<List<Attempt>> getMyAttempts(String examId) async {
    final url = Uri.parse('${AppConstants.baseUrl}/exams/$examId/my-attempt');
    final response = await ApiClient.get(url, withAuth: true);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Attempt.fromJson(e)).toList();
    } else {
      throw ServerException(response.statusCode, 'Failed to load attempts: ${response.body}');
    }
  }

  Future<List<Attempt>> getAllAttempts(String examId) async {
    final url = Uri.parse('${AppConstants.baseUrl}/exams/$examId/attempts');
    final response = await ApiClient.get(url, withAuth: true);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Attempt.fromJson(e)).toList();
    } else {
      throw ServerException(response.statusCode, 'Failed to load all attempts: ${response.body}');
    }
  }
}
