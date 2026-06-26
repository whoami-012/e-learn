import 'package:flutter/foundation.dart';
import '../models/exam.dart';
import '../services/exam_service.dart';

class ExamProvider extends ChangeNotifier {
  final ExamService _examService = ExamService();

  List<Exam> _exams = [];
  List<Question> _questions = [];
  List<Attempt> _myAttempts = [];
  bool _isLoading = false;
  String? _error;

  List<Exam> get exams => _exams;
  List<Question> get questions => _questions;
  List<Attempt> get myAttempts => _myAttempts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // EXAMS
  Future<void> fetchExams(String courseId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _exams = await _examService.getExamsByCourse(courseId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createExam(String courseId, String title, int durationMinutes) async {
    try {
      final newExam = await _examService.createExam(courseId, title, durationMinutes);
      _exams.add(newExam);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }

  Future<void> updateExam(String examId, String title, int durationMinutes) async {
    try {
      final updatedExam = await _examService.updateExam(examId, title, durationMinutes);
      final index = _exams.indexWhere((e) => e.id == examId);
      if (index != -1) {
        _exams[index] = updatedExam;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }

  Future<void> deleteExam(String examId) async {
    try {
      await _examService.deleteExam(examId);
      _exams.removeWhere((e) => e.id == examId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }

  // QUESTIONS
  Future<void> fetchQuestions(String examId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _questions = await _examService.getQuestionsByExam(examId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addQuestion(
      String examId, String text, Map<String, String> options, String correctAnswer) async {
    try {
      final newQ = await _examService.addQuestion(examId, text, options, correctAnswer);
      _questions.add(newQ);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }

  Future<void> deleteQuestion(String questionId) async {
    try {
      await _examService.deleteQuestion(questionId);
      _questions.removeWhere((q) => q.id == questionId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }

  // ATTEMPTS
  Future<Attempt> submitAttempt(String examId, Map<String, String> answers) async {
    try {
      final attempt = await _examService.submitAttempt(examId, answers);
      _myAttempts.insert(0, attempt); // add to top
      notifyListeners();
      return attempt;
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }

  Future<void> fetchMyAttempts(String examId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _myAttempts = await _examService.getMyAttempts(examId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
