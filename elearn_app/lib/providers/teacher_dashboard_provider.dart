import 'package:flutter/material.dart';
import '../models/course.dart';
import '../services/course_service.dart';
import '../widgets/analytics_card.dart';
import '../widgets/category_card.dart';

class TeacherDashboardProvider with ChangeNotifier {
  List<Course> _allCourses = [];
  List<Course> _filteredCourses = [];
  bool _isLoading = false;
  String? _error;
  String _activeCategory = 'All';

  List<Course> get courses => _filteredCourses;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get activeCategory => _activeCategory;

  Future<void> fetchCourses(String? facultyId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final fetchedCourses = await CourseService.getCourses();

      // Filter courses by faculty if ID is provided
      if (facultyId != null) {
        _allCourses =
            fetchedCourses.where((c) => c.facultyId == facultyId).toList();
      } else {
        _allCourses = fetchedCourses;
      }

      // Re-apply the active category filter after a fresh fetch
      _applyFilter(_activeCategory);
    } catch (e) {
      _error = 'Failed to load courses: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Filters the course list by the selected dashboard tab.
  ///
  /// Tab semantics (mapped to existing Course fields):
  ///   All       → every course owned by this teacher
  ///   Courses   → paid courses (!isFree) — content behind a paywall
  ///   Uploads   → free courses (isFree)  — openly published content
  ///   Scheduled → courses added within the last 30 days
  void filterByCategory(String category) {
    _activeCategory = category;
    _applyFilter(category);
    notifyListeners();
  }

  void _applyFilter(String category) {
    switch (category) {
      case 'Courses':
        _filteredCourses = _allCourses.where((c) => !c.isFree).toList();
        break;
      case 'Uploads':
        _filteredCourses = _allCourses.where((c) => c.isFree).toList();
        break;
      case 'Scheduled':
        final cutoff = DateTime.now().subtract(const Duration(days: 30));
        _filteredCourses =
            _allCourses.where((c) => c.createdAt.isAfter(cutoff)).toList();
        break;
      case 'All':
      default:
        _filteredCourses = List.from(_allCourses);
    }
  }

  void searchCourses(String query) {
    if (query.isEmpty) {
      _applyFilter(_activeCategory);
    } else {
      // Search within the currently filtered set
      _filteredCourses = _allCourses
          .where((c) => c.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  // Analytics Calculation
  List<DashboardStat> get stats {
    final activeCourses = _allCourses.length;
    final totalStudents = _allCourses.length * 12;
    final revenue = _allCourses.fold<double>(
        0, (sum, c) => sum + (c.isFree ? 0 : c.price * 10));

    return [
      DashboardStat(
        label: 'Total Students',
        value: totalStudents.toString(),
        change: '+12%',
        icon: Icons.people_outline,
        gradient: const LinearGradient(
            colors: [Color(0xFF3B82F6), Color(0xFF2563EB)]),
        bgColor: const Color(0xFFEFF6FF),
        shadowColor: const Color(0xFF3B82F6),
      ),
      DashboardStat(
        label: 'Active Courses',
        value: activeCourses.toString(),
        change: '+2',
        icon: Icons.menu_book,
        gradient: const LinearGradient(
            colors: [Color(0xFFA855F7), Color(0xFF9333EA)]),
        bgColor: const Color(0xFFF5F3FF),
        shadowColor: const Color(0xFFA855F7),
      ),
      DashboardStat(
        label: 'Revenue',
        value: '₹${revenue.toStringAsFixed(0)}',
        change: '+18%',
        icon: Icons.attach_money,
        gradient: const LinearGradient(
            colors: [Color(0xFF10B981), Color(0xFF059669)]),
        bgColor: const Color(0xFFECFDF5),
        shadowColor: const Color(0xFF10B981),
      ),
      DashboardStat(
        label: 'Engagement',
        value: '94%',
        change: '+5%',
        icon: Icons.trending_up,
        gradient: const LinearGradient(
            colors: [Color(0xFFF59E0B), Color(0xFFD97706)]),
        bgColor: const Color(0xFFFFFBEB),
        shadowColor: const Color(0xFFF59E0B),
      ),
    ];
  }

  // Categories Calculation
  List<DashboardCategory> get categories {
    return [
      DashboardCategory(
          title: 'Development',
          courses: 12,
          icon: Icons.code,
          baseColor: const Color(0xFF3B82F6)),
      DashboardCategory(
          title: 'Cybersecurity',
          courses: 5,
          icon: Icons.security,
          baseColor: const Color(0xFFEF4444)),
      DashboardCategory(
          title: 'Design',
          courses: 8,
          icon: Icons.palette_outlined,
          baseColor: const Color(0xFFA855F7)),
      DashboardCategory(
          title: 'Business',
          courses: 4,
          icon: Icons.work_outline,
          baseColor: const Color(0xFFF97316)),
    ];
  }
}
