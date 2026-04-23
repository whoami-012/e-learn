/// course_provider.dart — State management for the courses module.
library;

import 'package:flutter/foundation.dart';
import '../models/course.dart';
import '../models/lesson.dart';
import '../services/course_service.dart';
import '../core/exceptions/auth_exception.dart';

class CourseProvider extends ChangeNotifier {
  List<Course> _courses      = [];
  Course?      _selectedCourse;
  List<Lesson> _lessons       = [];
  bool         _isLoading    = false;
  String?      _error;
  bool         _isCreating   = false;

  // ── Getters ─────────────────────────────────────────────────────────────────

  List<Course> get courses        => _courses;
  Course?      get selectedCourse => _selectedCourse;
  List<Lesson> get lessons        => _lessons;
  bool         get isLoading      => _isLoading;
  bool         get isCreating     => _isCreating;
  String?      get error          => _error;

  // ── Fetch all courses ────────────────────────────────────────────────────────

  Future<void> fetchCourses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _courses = await CourseService.getCourses();
    } on AuthException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Error: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Fetch course by ID ───────────────────────────────────────────────────────

  Future<void> fetchCourseById(String id) async {
    _isLoading = true;
    _error = null;
    _selectedCourse = null;
    notifyListeners();

    try {
      _selectedCourse = await CourseService.getCourseById(id);
    } on AuthException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Error: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Fetch course lessons ─────────────────────────────────────────────────────

  Future<void> fetchLessons(String courseId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _lessons = await CourseService.getLessonsForCourse(courseId);
    } on AuthException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Error: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Create course (faculty only) ─────────────────────────────────────────────

  /// Returns true on success, false on failure.
  Future<bool> createCourse(CourseCreate data) async {
    _isCreating = true;
    _error = null;
    notifyListeners();

    try {
      final created = await CourseService.createCourse(data);
      _courses = [created, ..._courses];
      return true;
    } on AuthException catch (e) {
      _error = e.message;
      return false;
    } catch (e) {
      _error = 'Error: ${e.toString()}';
      return false;
    } finally {
      _isCreating = false;
      notifyListeners();
    }
  }

  // ── Update course (faculty/admin only) ───────────────────────────────────────

  /// Returns true on success, false on failure.
  Future<bool> updateCourse(String courseId, CourseUpdate data) async {
    _isCreating = true; // reuse isCreating flag for submit loading
    _error = null;
    notifyListeners();

    try {
      final updated = await CourseService.updateCourse(courseId, data);
      // Refresh selectedCourse and update list
      _selectedCourse = updated;
      _courses = _courses
          .map((c) => c.id == courseId ? updated : c)
          .toList();
      return true;
    } on AuthException catch (e) {
      _error = e.message;
      return false;
    } catch (e) {
      _error = 'Error: ${e.toString()}';
      return false;
    } finally {
      _isCreating = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
