import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/course_provider.dart';
import '../../services/course_service.dart';
import '../../services/enrollment_service.dart';
import '../../models/course.dart';
import '../../models/lesson.dart';
import '../courses/course_detail_screen.dart';
import '../courses/course_list_screen.dart';
import 'profile_screen.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  bool _isLoading = true;
  List<Course> _enrolledCourses = [];
  Map<String, List<Lesson>> _courseLessons = {};

  @override
  void initState() {
    super.initState();
    _loadProgressData();
  }

  Future<void> _loadProgressData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final courseProvider = context.read<CourseProvider>();
      await courseProvider.fetchCourses();
      
      if (!mounted) return;
      
      final allCourses = courseProvider.courses;
      final enrolledList = <Course>[];
      
      // Check enrollment in parallel
      final enrollmentChecks = await Future.wait(
        allCourses.map((course) async {
          try {
            final res = await EnrollmentService.checkEnrollment(course.id);
            return MapEntry(course, res.isEnrolled);
          } catch (_) {
            return MapEntry(course, false);
          }
        })
      );

      for (final entry in enrollmentChecks) {
        if (entry.value) {
          enrolledList.add(entry.key);
        }
      }

      // Fetch lessons for enrolled courses in parallel
      final lessonsMap = <String, List<Lesson>>{};
      await Future.wait(
        enrolledList.map((course) async {
          try {
            final lessons = await CourseService.getLessonsForCourse(course.id);
            lessonsMap[course.id] = lessons;
          } catch (_) {
            lessonsMap[course.id] = [];
          }
        })
      );

      if (mounted) {
        setState(() {
          _enrolledCourses = enrolledList;
          _courseLessons = lessonsMap;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  int _getTotalLessonsCount() {
    int total = 0;
    for (final lessons in _courseLessons.values) {
      total += lessons.length;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalLessons = _getTotalLessonsCount();

    return Scaffold(
      backgroundColor: ProfileColors.pageBackground(isDark),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isTablet = constraints.maxWidth >= 720;
            final double horizontalPadding = isTablet ? 40.0 : 20.0;

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(
                  children: [
                    // ── Progress Header ──
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                        vertical: 16.0,
                      ),
                      child: Row(
                        children: [
                          Semantics(
                            label: 'Back',
                            button: true,
                            child: Container(
                              decoration: BoxDecoration(
                                color: ProfileColors.surface(isDark),
                                borderRadius: BorderRadius.circular(16.0),
                                border: Border.all(
                                  color: ProfileColors.border(isDark),
                                  width: 1.0,
                                ),
                              ),
                              child: IconButton(
                                icon: Icon(
                                  Icons.chevron_left_rounded,
                                  color: ProfileColors.deepNavy(isDark),
                                  size: 28.0,
                                ),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16.0),
                          Text(
                            'My Progress',
                            style: TextStyle(
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Plus Jakarta Sans',
                              color: ProfileColors.deepNavy(isDark),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: _isLoading
                          ? Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  ProfileColors.primaryPurple(isDark),
                                ),
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: _loadProgressData,
                              color: ProfileColors.primaryPurple(isDark),
                              child: ListView(
                                padding: EdgeInsets.symmetric(
                                  horizontal: horizontalPadding,
                                  vertical: 8.0,
                                ),
                                physics: const AlwaysScrollableScrollPhysics(
                                  parent: BouncingScrollPhysics(),
                                ),
                                children: [
                                  // ── Overall Progress Card ──
                                  Container(
                                    padding: const EdgeInsets.all(24.0),
                                    decoration: BoxDecoration(
                                      color: ProfileColors.softLavender(isDark),
                                      borderRadius: BorderRadius.circular(24.0),
                                    ),
                                    child: Row(
                                      children: [
                                        // Circular Progress Chart
                                        Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            SizedBox(
                                              width: 80.0,
                                              height: 80.0,
                                              child: CircularProgressIndicator(
                                                value: 0.0, // 0% progress as confirmed by backend (no completed lessons tracking)
                                                strokeWidth: 8.0,
                                                backgroundColor: ProfileColors.surface(isDark),
                                                valueColor: AlwaysStoppedAnimation<Color>(
                                                  ProfileColors.primaryPurple(isDark),
                                                ),
                                              ),
                                            ),
                                            Text(
                                              '0%',
                                              style: TextStyle(
                                                fontSize: 20.0,
                                                fontWeight: FontWeight.w800,
                                                fontFamily: 'Plus Jakarta Sans',
                                                color: ProfileColors.deepNavy(isDark),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(width: 24.0),
                                        // Text & Stats
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Getting started!',
                                                style: TextStyle(
                                                  fontSize: 18.0,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: 'Plus Jakarta Sans',
                                                  color: ProfileColors.deepNavy(isDark),
                                                ),
                                              ),
                                              const SizedBox(height: 4.0),
                                              Text(
                                                'Complete lessons to boost your progress.',
                                                style: TextStyle(
                                                  fontSize: 13.0,
                                                  fontFamily: 'Plus Jakarta Sans',
                                                  color: ProfileColors.mutedText(isDark),
                                                ),
                                              ),
                                              const SizedBox(height: 12.0),
                                              Row(
                                                children: [
                                                  _buildMiniStat(
                                                    '${_enrolledCourses.length}',
                                                    'Courses',
                                                    isDark,
                                                  ),
                                                  const SizedBox(width: 20.0),
                                                  _buildMiniStat(
                                                    '$totalLessons',
                                                    'Lessons',
                                                    isDark,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 32.0),

                                  // ── Course Progress List ──
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Course Progress',
                                        style: TextStyle(
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Plus Jakarta Sans',
                                          color: ProfileColors.deepNavy(isDark),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12.0),
                                  if (_enrolledCourses.isEmpty)
                                    _buildEmptyCoursesState(context, isDark)
                                  else
                                    ..._enrolledCourses.map((course) {
                                      final lessons = _courseLessons[course.id] ?? [];
                                      return _buildCourseProgressCard(context, course, lessons, isDark);
                                    }),

                                  const SizedBox(height: 32.0),

                                  // ── Weekly Activity Section (Empty state) ──
                                  Text(
                                    'Weekly Activity',
                                    style: TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Plus Jakarta Sans',
                                      color: ProfileColors.deepNavy(isDark),
                                    ),
                                  ),
                                  const SizedBox(height: 12.0),
                                  Container(
                                    padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 16.0),
                                    decoration: BoxDecoration(
                                      color: ProfileColors.surface(isDark),
                                      borderRadius: BorderRadius.circular(20.0),
                                      border: Border.all(
                                        color: ProfileColors.border(isDark),
                                        width: 1.0,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.bar_chart_rounded,
                                          size: 48.0,
                                          color: ProfileColors.mutedText(isDark).withOpacity(0.5),
                                        ),
                                        const SizedBox(height: 12.0),
                                        Text(
                                          'No learning activity',
                                          style: TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Plus Jakarta Sans',
                                            color: ProfileColors.deepNavy(isDark),
                                          ),
                                        ),
                                        const SizedBox(height: 6.0),
                                        Text(
                                          'Track your progress here as you study.',
                                          style: TextStyle(
                                            fontSize: 13.0,
                                            fontFamily: 'Plus Jakarta Sans',
                                            color: ProfileColors.mutedText(isDark),
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 40.0),
                                ],
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMiniStat(String value, String label, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w800,
            fontFamily: 'Plus Jakarta Sans',
            color: ProfileColors.deepNavy(isDark),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.0,
            fontFamily: 'Plus Jakarta Sans',
            color: ProfileColors.mutedText(isDark),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyCoursesState(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: ProfileColors.surface(isDark),
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
          color: ProfileColors.border(isDark),
          width: 1.0,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.school_outlined,
            size: 40.0,
            color: ProfileColors.mutedText(isDark).withOpacity(0.5),
          ),
          const SizedBox(height: 12.0),
          Text(
            'No enrolled courses yet',
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              fontFamily: 'Plus Jakarta Sans',
              color: ProfileColors.deepNavy(isDark),
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            'Browse our catalogs and start your learning journey!',
            style: TextStyle(
              fontSize: 13.0,
              fontFamily: 'Plus Jakarta Sans',
              color: ProfileColors.mutedText(isDark),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CourseListScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ProfileColors.primaryPurple(isDark),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
            child: const Text(
              'Explore Courses',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseProgressCard(
    BuildContext context,
    Course course,
    List<Lesson> lessons,
    bool isDark,
  ) {
    final total = lessons.length;
    // Since lesson progress completion is not tracked in the backend, completed is 0
    final completed = 0;
    final progress = total > 0 ? (completed / total) : 0.0;

    return Semantics(
      label: 'Course Progress for ${course.title}',
      button: true,
      child: Card(
        margin: const EdgeInsets.only(bottom: 16.0),
        color: ProfileColors.surface(isDark),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
          side: BorderSide(
            color: ProfileColors.border(isDark),
            width: 1.0,
          ),
        ),
        elevation: 0,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CourseDetailScreen(courseId: course.id),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20.0),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        course.title,
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Plus Jakarta Sans',
                          color: ProfileColors.deepNavy(isDark),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '0%',
                      style: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Plus Jakarta Sans',
                        color: ProfileColors.primaryPurple(isDark),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12.0),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4.0),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8.0,
                    backgroundColor: ProfileColors.border(isDark),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      ProfileColors.primaryPurple(isDark),
                    ),
                  ),
                ),
                const SizedBox(height: 12.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$completed / $total Lessons',
                      style: TextStyle(
                        fontSize: 13.0,
                        fontFamily: 'Plus Jakarta Sans',
                        color: ProfileColors.mutedText(isDark),
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          'Resume Study',
                          style: TextStyle(
                            fontSize: 13.0,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Plus Jakarta Sans',
                            color: ProfileColors.primaryPurple(isDark),
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: ProfileColors.primaryPurple(isDark),
                          size: 16.0,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
