import 'package:flutter/foundation.dart';
import '../../data/live_class_repository.dart';
import '../../data/models/live_class.dart';

class LiveClassController extends ChangeNotifier {
  final LiveClassRepository repository;
  LiveClassController({LiveClassRepository? repository})
      : repository = repository ?? LiveClassRepository();
  List<LiveClass> classes = const [];
  bool isLoading = false;
  bool isJoining = false;
  String? error;

  Future<void> load({String? status}) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      classes = await repository.list(status: status);
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> create(
      {required String courseId,
      required String title,
      String? description,
      required DateTime startsAt,
      required DateTime endsAt}) async {
    if (isLoading) return false;
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      classes = [
        await repository.create(
            courseId: courseId,
            title: title,
            description: description,
            startsAt: startsAt,
            endsAt: endsAt),
        ...classes
      ];
      return true;
    } catch (e) {
      error = e.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<AgoraJoinCredentials?> join(String id, {bool start = false}) async {
    if (isJoining) return null;
    isJoining = true;
    error = null;
    notifyListeners();
    try {
      return await repository.join(id, start: start);
    } catch (e) {
      error = e.toString();
      return null;
    } finally {
      isJoining = false;
      notifyListeners();
    }
  }
}
