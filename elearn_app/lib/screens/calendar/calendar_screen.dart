import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/course_provider.dart';
import '../../providers/exam_provider.dart';
import '../../features/live_class/presentation/controllers/live_class_controller.dart';
import '../../features/live_class/presentation/screens/live_class_detail_screen.dart';
import '../../theme/app_theme.dart';
import '../../widgets/dashboard/app_bottom_navigation.dart';
import '../../widgets/calendar/calendar_widgets.dart';
import '../../widgets/calendar/calendar_card.dart';
import '../../widgets/calendar/calendar_event_card.dart';
import '../../widgets/calendar/upcoming_exam_card.dart';
import '../../widgets/calendar/calendar_states.dart';
import '../exams/exam_taking_screen.dart';
import '../courses/course_list_screen.dart';
import '../messages/message_screen.dart';
import '../profile/profile_screen.dart';

/// The premium redesigned Calendar / Class Schedule screen.
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _selectedDate;
  late DateTime _displayedMonth;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _selectedDate = DateTime(today.year, today.month, today.day);
    _displayedMonth = DateTime(today.year, today.month, 1);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    // 1. Fetch live classes
    context.read<LiveClassController>().load();

    // 2. Fetch courses and exams for the first course
    context.read<CourseProvider>().fetchCourses().then((_) {
      if (!mounted) return;
      final courses = context.read<CourseProvider>().courses;
      if (courses.isNotEmpty) {
        context.read<ExamProvider>().fetchExams(courses.first.id);
      }
    });
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour == 0 ? 12 : (dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour);
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  String _getCourseTitle(String courseId, List<dynamic> courses) {
    final match = courses.where((c) => c.id == courseId);
    return match.isNotEmpty ? match.first.title : 'General';
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _formatDateLabel(DateTime date) {
    final today = DateTime.now();
    final tomorrow = today.add(const Duration(days: 1));
    if (_isSameDay(date, today)) {
      return 'Today, ${date.day} ${_getMonthName(date.month)}';
    } else if (_isSameDay(date, tomorrow)) {
      return 'Tomorrow, ${date.day} ${_getMonthName(date.month)}';
    }

    final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final weekdayStr = weekdays[date.weekday - 1];
    return '$weekdayStr, ${date.day} ${_getMonthName(date.month)}';
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final courseState = context.watch<CourseProvider>();
    final liveClassState = context.watch<LiveClassController>();
    final examState = context.watch<ExamProvider>();

    final isLoading = liveClassState.isLoading || courseState.isLoading;
    final error = liveClassState.error ?? courseState.error;

    // Filter events for selected date
    final dailyClasses = liveClassState.classes.where((c) {
      return _isSameDay(c.scheduledStartTime, _selectedDate);
    }).toList();

    // Map unique date events for indicator dots
    final eventDates = liveClassState.classes
        .map((c) => DateTime(c.scheduledStartTime.year, c.scheduledStartTime.month, c.scheduledStartTime.day))
        .toSet();

    // Offline / fallback verification
    final hasDataCache = liveClassState.classes.isNotEmpty || courseState.courses.isNotEmpty;
    final isOffline = error != null && hasDataCache;
    final isFullError = error != null && !hasDataCache;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isFullError) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF0F1117) : const Color(0xFFF7F8FC),
        body: SafeArea(
          child: CalendarErrorState(
            title: 'Unable to load your schedule',
            description: error,
            onRetry: _loadData,
          ),
        ),
      );
    }

    if (isLoading && !hasDataCache) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF0F1117) : const Color(0xFFF7F8FC),
        body: const SafeArea(
          child: CalendarLoadingSkeleton(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1117) : const Color(0xFFF7F8FC),
      bottomNavigationBar: SafeArea(
        child: AppBottomNavigation(
          currentIndex: 2, // Calendar index
          onTap: (index) {
            if (index == 2) return;
            if (index == 0) {
              Navigator.pop(context);
              return;
            }
            if (index == 1) {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CourseListScreen()),
              );
              return;
            }
            if (index == 3) {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MessageScreen()),
              );
              return;
            }
            if (index == 4) {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
              return;
            }
          },
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isTablet = constraints.maxWidth >= 700;

            if (isTablet) {
              return _buildTabletLayout(
                context,
                eventDates,
                dailyClasses,
                examState,
                courseState,
                isOffline,
              );
            }

            return _buildMobileLayout(
              context,
              eventDates,
              dailyClasses,
              examState,
              courseState,
              isOffline,
            );
          },
        ),
      ),
    );
  }

  /// Mobile-first single column vertical scrollable layout.
  Widget _buildMobileLayout(
    BuildContext context,
    Set<DateTime> eventDates,
    List<dynamic> dailyClasses,
    ExamProvider examState,
    CourseProvider courseState,
    bool isOffline,
  ) {
    final upcomingExam = examState.exams.isNotEmpty ? examState.exams.first : null;

    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppColors.primary,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // 1. Header
          const SliverToBoxAdapter(
            child: CalendarScreenHeader(),
          ),

          // 2. Offline banner alert if active
          if (isOffline)
            SliverToBoxAdapter(
              child: OfflineBanner(
                message: "You're offline. Showing your saved schedule.",
                onRetry: _loadData,
              ),
            ),

          // 3. Main month calendar card container
          SliverToBoxAdapter(
            child: MonthCalendarCard(
              displayedMonth: _displayedMonth,
              selectedDate: _selectedDate,
              eventDates: eventDates,
              onMonthChanged: (newMonth) {
                setState(() {
                  _displayedMonth = newMonth;
                });
              },
              onDateSelected: (newDate) {
                setState(() {
                  _selectedDate = newDate;
                  // Ensure display month matches selected date
                  if (newDate.year != _displayedMonth.year || newDate.month != _displayedMonth.month) {
                    _displayedMonth = DateTime(newDate.year, newDate.month, 1);
                  }
                });
              },
            ),
          ),

          // 4. Selected Day & Today action header
          SliverToBoxAdapter(
            child: SelectedDateHeader(
              dateLabel: _formatDateLabel(_selectedDate),
              onTodayTap: () {
                final today = DateTime.now();
                setState(() {
                  _selectedDate = DateTime(today.year, today.month, today.day);
                  _displayedMonth = DateTime(today.year, today.month, 1);
                });
              },
            ),
          ),

          // 5. Daily agenda list / Empty Day card
          if (dailyClasses.isEmpty)
            SliverToBoxAdapter(
              child: CalendarEmptyState(
                title: 'No classes scheduled',
                description: 'You have no classes or exams planned for this day.',
                icon: Icons.event_busy_rounded,
                actionText: 'Explore Courses',
                onActionTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CourseListScreen()),
                  );
                },
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = dailyClasses[index];
                    final startTimeStr = _formatTime(item.scheduledStartTime);
                    final endTimeStr = _formatTime(item.scheduledEndTime);
                    final courseTitle = _getCourseTitle(item.courseId, courseState.courses);
                    final colorScheme = EventColorScheme.fromSubjectAndStatus(courseTitle, 'class');

                    return CalendarEventCard(
                      title: item.title,
                      subtitle: item.description,
                      startTime: startTimeStr,
                      endTime: endTimeStr,
                      instructorName: item.facultyName,
                      isLive: item.status == 'live',
                      subject: courseTitle,
                      colorScheme: colorScheme,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => LiveClassDetailScreen(liveClass: item),
                          ),
                        );
                      },
                    );
                  },
                  childCount: dailyClasses.length,
                ),
              ),
            ),

          // 6. Upcoming test banner card
          if (upcomingExam != null)
            SliverToBoxAdapter(
              child: UpcomingExamCard(
                title: upcomingExam.title,
                dateLabel: 'Tomorrow, 09:00 AM', // Fallback display time matching HomeScreen
                onViewDetails: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ExamTakingScreen(exam: upcomingExam),
                    ),
                  );
                },
              ),
            ),

          // Padding so content is not blocked by floating bottom navigation
          const SliverToBoxAdapter(
            child: SizedBox(height: 120),
          ),
        ],
      ),
    );
  }

  /// Responsive two-column Tablet layout.
  Widget _buildTabletLayout(
    BuildContext context,
    Set<DateTime> eventDates,
    List<dynamic> dailyClasses,
    ExamProvider examState,
    CourseProvider courseState,
    bool isOffline,
  ) {
    final upcomingExam = examState.exams.isNotEmpty ? examState.exams.first : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Header
        const CalendarScreenHeader(),

        // Offline Banner
        if (isOffline)
          OfflineBanner(
            message: "You're offline. Showing your saved schedule.",
            onRetry: _loadData,
          ),

        // Split 2-column view
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column: Calendar Card
              Expanded(
                flex: 5,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      MonthCalendarCard(
                        displayedMonth: _displayedMonth,
                        selectedDate: _selectedDate,
                        eventDates: eventDates,
                        onMonthChanged: (newMonth) {
                          setState(() {
                            _displayedMonth = newMonth;
                          });
                        },
                        onDateSelected: (newDate) {
                          setState(() {
                            _selectedDate = newDate;
                            if (newDate.year != _displayedMonth.year || newDate.month != _displayedMonth.month) {
                              _displayedMonth = DateTime(newDate.year, newDate.month, 1);
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Right Column: Agenda List & Upcoming Exam Card
              Expanded(
                flex: 6,
                child: RefreshIndicator(
                  onRefresh: _loadData,
                  color: AppColors.primary,
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      // Header showing current selection
                      SliverToBoxAdapter(
                        child: SelectedDateHeader(
                          dateLabel: _formatDateLabel(_selectedDate),
                          onTodayTap: () {
                            final today = DateTime.now();
                            setState(() {
                              _selectedDate = DateTime(today.year, today.month, today.day);
                              _displayedMonth = DateTime(today.year, today.month, 1);
                            });
                          },
                        ),
                      ),

                      // List
                      if (dailyClasses.isEmpty)
                        SliverToBoxAdapter(
                          child: CalendarEmptyState(
                            title: 'No classes scheduled',
                            description: 'You have no classes or exams planned for this day.',
                            icon: Icons.event_busy_rounded,
                            actionText: 'Explore Courses',
                            onActionTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const CourseListScreen()),
                              );
                            },
                          ),
                        )
                      else
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final item = dailyClasses[index];
                                final startTimeStr = _formatTime(item.scheduledStartTime);
                                final endTimeStr = _formatTime(item.scheduledEndTime);
                                final courseTitle = _getCourseTitle(item.courseId, courseState.courses);
                                final colorScheme = EventColorScheme.fromSubjectAndStatus(courseTitle, 'class');

                                return CalendarEventCard(
                                  title: item.title,
                                  subtitle: item.description,
                                  startTime: startTimeStr,
                                  endTime: endTimeStr,
                                  instructorName: item.facultyName,
                                  isLive: item.status == 'live',
                                  subject: courseTitle,
                                  colorScheme: colorScheme,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => LiveClassDetailScreen(liveClass: item),
                                      ),
                                    );
                                  },
                                );
                              },
                              childCount: dailyClasses.length,
                            ),
                          ),
                        ),

                      // Upcoming Exam Banner Card
                      if (upcomingExam != null)
                        SliverToBoxAdapter(
                          child: UpcomingExamCard(
                            title: upcomingExam.title,
                            dateLabel: 'Tomorrow, 09:00 AM',
                            onViewDetails: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ExamTakingScreen(exam: upcomingExam),
                                ),
                              );
                            },
                          ),
                        ),

                      const SliverToBoxAdapter(
                        child: SizedBox(height: 120),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
