import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/course_provider.dart';
import '../../models/course.dart';
import '../../models/lesson.dart';
import '../../services/enrollment_service.dart';
import '../../services/course_service.dart';
import '../courses/course_list_screen.dart';
import '../courses/course_detail_screen.dart';

class ProfileColors {
  ProfileColors._();

  static Color primaryPurple(bool isDark) => const Color(0xFF6C45D8);
  static Color deepNavy(bool isDark) => isDark ? const Color(0xFFF7F8FC) : const Color(0xFF101936);
  static Color pageBackground(bool isDark) => isDark ? const Color(0xFF0F1117) : const Color(0xFFF7F8FC);
  static Color surface(bool isDark) => isDark ? const Color(0xFF181B23) : const Color(0xFFFFFFFF);
  static Color softLavender(bool isDark) => isDark ? const Color(0xFF2A243F) : const Color(0xFFF0ECFC);
  static Color mutedText(bool isDark) => isDark ? const Color(0xFFADB4C4) : const Color(0xFF6F7588);
  static Color border(bool isDark) => isDark ? const Color(0xFF303542) : const Color(0xFFE9EBF2);
  static Color success(bool isDark) => const Color(0xFF2DCB82);
}

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

  int _getSimulatedCompletedLessons(Course course, int totalLessons) {
    if (totalLessons == 0) return 0;
    final hash = course.title.toLowerCase().hashCode.abs();
    final List<int> percentages = [40, 50, 65, 75, 80, 90];
    final pct = percentages[hash % percentages.length];
    final completed = (totalLessons * pct / 100).round();
    if (completed <= 0) return 1;
    if (completed > totalLessons) return totalLessons;
    return completed;
  }

  int _getTotalCompletedLessonsCount() {
    int totalCompleted = 0;
    for (final course in _enrolledCourses) {
      final lessons = _courseLessons[course.id] ?? [];
      totalCompleted += _getSimulatedCompletedLessons(course, lessons.length);
    }
    return totalCompleted;
  }

  Widget _buildMiniStat(String value, String label, bool isDark) {
    return Column(
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
        const SizedBox(height: 2.0),
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

  Widget _buildVerticalDivider(bool isDark) {
    return Container(
      width: 1.0,
      height: 24.0,
      color: ProfileColors.border(isDark).withValues(alpha: 0.5),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalLessons = _getTotalLessonsCount();
    final totalCompleted = _getTotalCompletedLessonsCount();
    final overallProgress = totalLessons > 0 ? (totalCompleted / totalLessons) : 0.0;
    final overallPercentageText = '${(overallProgress * 100).round()}%';

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
                                icon: const Icon(
                                  Icons.chevron_left_rounded,
                                  size: 28.0,
                                ),
                                color: ProfileColors.deepNavy(isDark),
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
                                    padding: const EdgeInsets.all(20.0),
                                    decoration: BoxDecoration(
                                      color: ProfileColors.softLavender(isDark),
                                      borderRadius: BorderRadius.circular(24.0),
                                    ),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            // Circular Progress Chart
                                            Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                SizedBox(
                                                  width: 80.0,
                                                  height: 80.0,
                                                  child: CircularProgressIndicator(
                                                    value: overallProgress,
                                                    strokeWidth: 8.0,
                                                    backgroundColor: ProfileColors.surface(isDark),
                                                    valueColor: AlwaysStoppedAnimation<Color>(
                                                      ProfileColors.primaryPurple(isDark),
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  overallPercentageText,
                                                  style: TextStyle(
                                                    fontSize: 18.0,
                                                    fontWeight: FontWeight.w800,
                                                    fontFamily: 'Plus Jakarta Sans',
                                                    color: ProfileColors.deepNavy(isDark),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(width: 20.0),
                                            // Text & Celebration Icon
                                            Expanded(
                                              child: Row(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          overallProgress >= 0.7 ? 'Outstanding job!' : 'Great job!',
                                                          style: TextStyle(
                                                            fontSize: 16.0,
                                                            fontWeight: FontWeight.bold,
                                                            fontFamily: 'Plus Jakarta Sans',
                                                            color: ProfileColors.deepNavy(isDark),
                                                          ),
                                                        ),
                                                        const SizedBox(height: 4.0),
                                                        Text(
                                                          'You\'re doing better than 80% of learners.',
                                                          style: TextStyle(
                                                            fontSize: 12.0,
                                                            fontFamily: 'Plus Jakarta Sans',
                                                            color: ProfileColors.mutedText(isDark),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8.0),
                                                  // Celebration icon
                                                  Container(
                                                    padding: const EdgeInsets.all(8.0),
                                                    decoration: BoxDecoration(
                                                      color: ProfileColors.surface(isDark),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: const Icon(
                                                      Icons.emoji_events_rounded,
                                                      color: Colors.amber,
                                                      size: 24.0,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 20.0),
                                        Divider(color: ProfileColors.border(isDark).withValues(alpha: 0.3), height: 1.0),
                                        const SizedBox(height: 16.0),
                                        // Mini Stats Row
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: [
                                            _buildMiniStat(
                                              '${_enrolledCourses.length}',
                                              'Courses',
                                              isDark,
                                            ),
                                            _buildVerticalDivider(isDark),
                                            _buildMiniStat(
                                              '$totalLessons',
                                              'Lessons',
                                              isDark,
                                            ),
                                            _buildVerticalDivider(isDark),
                                            _buildMiniStat(
                                              '${_enrolledCourses.length * 4}h 15m',
                                              'Time Learned',
                                              isDark,
                                            ),
                                            _buildVerticalDivider(isDark),
                                            _buildMiniStat(
                                              '${_enrolledCourses.isNotEmpty ? 1 : 0}',
                                              'Certificates',
                                              isDark,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 28.0),

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

                                  const SizedBox(height: 28.0),

                                  // ── Weekly Activity Section (Gradient Bar Chart) ──
                                  _buildWeeklyActivityChart(isDark),
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

  Widget _buildWeeklyActivityChart(bool isDark) {
    final Map<String, double> dailyHours = {
      'Mon': 5.0,
      'Tue': 6.5,
      'Wed': 3.5,
      'Thu': 6.0,
      'Fri': 8.0,
      'Sat': 5.0,
      'Sun': 7.0,
    };
    final double maxHour = 9.0;

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: ProfileColors.surface(isDark),
        borderRadius: BorderRadius.circular(24.0),
        border: Border.all(
          color: ProfileColors.border(isDark),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Weekly Activity',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Plus Jakarta Sans',
                  color: ProfileColors.deepNavy(isDark),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                decoration: BoxDecoration(
                  color: ProfileColors.pageBackground(isDark),
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(color: ProfileColors.border(isDark)),
                ),
                child: Row(
                  children: [
                    Text(
                      'This Week',
                      style: TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Plus Jakarta Sans',
                        color: ProfileColors.primaryPurple(isDark),
                      ),
                    ),
                    const SizedBox(width: 4.0),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: ProfileColors.primaryPurple(isDark),
                      size: 16.0,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24.0),
          // Chart Area
          SizedBox(
            height: 160.0,
            child: Row(
              children: [
                // Y-Axis Labels
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('9h', style: TextStyle(fontSize: 11.0, color: Colors.grey)),
                    Text('6h', style: TextStyle(fontSize: 11.0, color: Colors.grey)),
                    Text('3h', style: TextStyle(fontSize: 11.0, color: Colors.grey)),
                    Text('0', style: TextStyle(fontSize: 11.0, color: Colors.grey)),
                  ],
                ),
                const SizedBox(width: 12.0),
                // Bars Row
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final chartHeight = constraints.maxHeight;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: dailyHours.entries.map((entry) {
                          final day = entry.key;
                          final hours = entry.value;
                          final barHeight = (hours / maxHour) * (chartHeight - 20.0);

                          return Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // The Bar
                              Container(
                                width: 14.0,
                                height: barHeight,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      ProfileColors.primaryPurple(isDark).withValues(alpha: 0.5),
                                      ProfileColors.primaryPurple(isDark),
                                    ],
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                  ),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              Text(
                                day,
                                style: TextStyle(
                                  fontSize: 11.0,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Plus Jakarta Sans',
                                  color: ProfileColors.mutedText(isDark),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
            color: ProfileColors.mutedText(isDark).withValues(alpha: 0.5),
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
    final completed = _getSimulatedCompletedLessons(course, total);
    final progress = total > 0 ? (completed / total) : 0.0;
    final percentageText = '${(progress * 100).round()}%';

    // Get a unique background color for the left icon placeholder based on course title
    final hash = course.title.toLowerCase().hashCode.abs();
    final List<Color> iconColors = [
      Colors.blue.shade100,
      Colors.green.shade100,
      Colors.purple.shade100,
      Colors.orange.shade100,
      Colors.teal.shade100,
      Colors.red.shade100,
    ];
    final List<Color> iconTextColors = [
      Colors.blue.shade700,
      Colors.green.shade700,
      Colors.purple.shade700,
      Colors.orange.shade700,
      Colors.teal.shade700,
      Colors.red.shade700,
    ];
    final iconBgColor = iconColors[hash % iconColors.length];
    final iconColor = iconTextColors[hash % iconTextColors.length];

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
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Left Icon Container
                Container(
                  width: 48.0,
                  height: 48.0,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.menu_book_rounded,
                      color: iconColor,
                      size: 24.0,
                    ),
                  ),
                ),
                const SizedBox(width: 16.0),
                // Title and Progress info
                Expanded(
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
                            percentageText,
                            style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Plus Jakarta Sans',
                              color: ProfileColors.deepNavy(isDark),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8.0),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4.0),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 6.0,
                          backgroundColor: isDark ? const Color(0xFF232836) : const Color(0xFFF0F2F6),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            ProfileColors.primaryPurple(isDark),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        '$completed / $total Lessons',
                        style: TextStyle(
                          fontSize: 12.0,
                          fontFamily: 'Plus Jakarta Sans',
                          color: ProfileColors.mutedText(isDark),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
