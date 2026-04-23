/// enrollment_provider.dart — State management for course enrollment.
library;

import 'package:flutter/material.dart';

import '../core/exceptions/auth_exception.dart';
import '../services/enrollment_service.dart';

class EnrollmentProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _isEnrolled = false;
  String? _error;

  bool get isLoading => _isLoading;
  bool get isEnrolled => _isEnrolled;
  String? get error => _error;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _error = message;
    notifyListeners();
  }

  Future<void> checkEnrollment(String courseId) async {
    _setLoading(true);
    _setError(null);
    try {
      final status = await EnrollmentService.checkEnrollment(courseId);
      _isEnrolled = status.isEnrolled;
    } on AuthException catch (e) {
      _setError(e.message);
      _isEnrolled = false;
    } catch (e) {
      _setError('Failed to check enrollment status.');
      _isEnrolled = false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> enroll(String courseId) async {
    _setLoading(true);
    _setError(null);
    try {
      final status = await EnrollmentService.enroll(courseId);
      _isEnrolled = status.isEnrolled;
      return true;
    } on ServerException catch (e) {
      // 409 already enrolled is fine
      if (e.statusCode == 409) {
        _isEnrolled = true;
        return true;
      }
      _setError(e.message);
      return false;
    } on AuthException catch (e) {
      _setError(e.message);
      return false;
    } catch (e) {
      _setError('Failed to enroll.');
      return false;
    } finally {
      _setLoading(false);
    }
  }
}
