/// note_provider.dart — State management for notes.
library;

import 'package:flutter/material.dart';

import '../core/exceptions/auth_exception.dart';
import '../models/note.dart';
import '../services/note_service.dart';

class NoteProvider extends ChangeNotifier {
  bool _isLoading = false;
  List<Note> _notes = [];
  String? _error;

  bool get isLoading => _isLoading;
  List<Note> get notes => _notes;
  String? get error => _error;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _error = message;
    notifyListeners();
  }

  Future<void> fetchNotes(String courseId) async {
    _setLoading(true);
    _setError(null);
    try {
      final fetchedNotes = await NoteService.getNotesByCourse(courseId);
      _notes = fetchedNotes;
    } on AuthException catch (e) {
      _setError(e.message);
      _notes = [];
    } catch (e) {
      _setError('Failed to load notes.');
      _notes = [];
    } finally {
      _setLoading(false);
    }
  }
}
