import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/course_provider.dart';
import '../../providers/exam_provider.dart';
import '../../features/live_class/presentation/controllers/live_class_controller.dart';
import '../../features/live_class/presentation/screens/live_class_detail_screen.dart';
import '../../features/live_class/presentation/screens/live_class_list_screen.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
import '../courses/course_list_screen.dart';
import '../courses/course_detail_screen.dart';
import '../exams/exam_taking_screen.dart';
import '../calendar/calendar_screen.dart';
import '../messages/message_screen.dart';
import '../profile/profile_screen.dart';

// Reusable Dashboard Widgets
import '../../widgets/dashboard/section_header.dart';
import '../../widgets/dashboard/dashboard_header.dart';
import '../../widgets/dashboard/upcoming_live_class_card.dart';
import '../../widgets/dashboard/live_class_card.dart';
import '../../widgets/dashboard/upcoming_test_card.dart';
import '../../widgets/dashboard/continue_learning_card.dart';
import '../../widgets/dashboard/goal_and_streak_cards.dart';
import '../../widgets/dashboard/app_bottom_navigation.dart';
import '../../widgets/dashboard/shimmer_skeletons.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = context.read<UserProvider>();
      if (!userProvider.hasUser) {
        userProvider.loadUser();
      }

      // Fetch initial data
      context.read<CourseProvider>().fetchCourses().then((_) {
        if (!mounted) return;
        final courses = context.read<CourseProvider>().courses;
        if (courses.isNotEmpty) {
          context.read<ExamProvider>().fetchExams(courses.first.id);
        }
      });

      context.read<LiveClassController>().load();
    });
  }

  Future<void> _logout() async {
    await AuthService.logout();
    if (!mounted) return;
    context.read<UserProvider>().clearUser();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour == 0
        ? 12
        : (dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour);
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  void _onBottomNavTapped(int index) {
    if (index == 0) return;

    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CourseListScreen()),
      ).then((_) {
        if (mounted) {
          setState(() {
            _currentIndex = 0;
          });
        }
      });
      setState(() {
        _currentIndex = index;
      });
      return;
    }

    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CalendarScreen()),
      ).then((_) {
        if (mounted) {
          setState(() {
            _currentIndex = 0;
          });
        }
      });
      setState(() {
        _currentIndex = index;
      });
      return;
    }

    if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const MessageScreen()),
      ).then((_) {
        if (mounted) {
          setState(() {
            _currentIndex = 0;
          });
        }
      });
      setState(() {
        _currentIndex = index;
      });
      return;
    }

    if (index == 4) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ProfileScreen()),
      ).then((_) {
        if (mounted) {
          setState(() {
            _currentIndex = 0;
          });
        }
      });
      setState(() {
        _currentIndex = index;
      });
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;
    final courseState = context.watch<CourseProvider>();
    final liveClassState = context.watch<LiveClassController>();
    final examState = context.watch<ExamProvider>();

    final isLoadingGlobal = user == null || courseState.isLoading;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F1117) : const Color(0xFFF7F8FC),
      bottomNavigationBar: SafeArea(
        child: AppBottomNavigation(
          currentIndex: _currentIndex,
          onTap: _onBottomNavTapped,
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<CourseProvider>().fetchCourses();
          if (!context.mounted) return;
          await context.read<LiveClassController>().load();
          if (!context.mounted) return;
          final courses = context.read<CourseProvider>().courses;
          if (courses.isNotEmpty) {
            await context.read<ExamProvider>().fetchExams(courses.first.id);
          }
        },
        child: SafeArea(
          bottom: false,
          child: isLoadingGlobal
              ? const FullDashboardShimmer()
              : CustomScrollView(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 16.0),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          // ── Compact Error Banner ──
                          if (courseState.error != null ||
                              liveClassState.error != null)
                            Container(
                              margin: const EdgeInsets.only(bottom: 16.0),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 10.0),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFECEC),
                                borderRadius: BorderRadius.circular(12.0),
                                border: Border.all(color: Colors.red.shade200),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline_rounded,
                                      color: Colors.red, size: 20),
                                  const SizedBox(width: 8.0),
                                  Expanded(
                                    child: Text(
                                      courseState.error ??
                                          liveClassState.error ??
                                          'Connection error',
                                      style: const TextStyle(
                                          color: Colors.red, fontSize: 12),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      context
                                          .read<CourseProvider>()
                                          .fetchCourses();
                                      context
                                          .read<LiveClassController>()
                                          .load();
                                    },
                                    child: const Text('Retry',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            ),

                          // ── 1. Header ──
                          DashboardHeader(
                            name: user.name.split(' ').first,
                            initials: _getInitials(user.name),
                            onSearchTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const CourseListScreen()),
                            ),
                            onNotificationsTap: () =>
                                _showNotificationsSheet(context),
                            onAvatarTap: _logout,
                          ),
                          const SizedBox(height: 24.0),

                          // ── 2. Upcoming live-class hero card ──
                          _buildLiveClassHero(liveClassState),
                          const SizedBox(height: 24.0),

                          // ── 3. Today’s classes ──
                          _buildTodayClasses(liveClassState),
                          const SizedBox(height: 24.0),

                          // ── 4. Upcoming test card ──
                          _buildUpcomingTest(examState),
                          const SizedBox(height: 24.0),

                          // ── 5. Continue learning ──
                          _buildContinueLearning(courseState),
                          const SizedBox(height: 24.0),

                          // ── 6. Weekly goal and learning streak ──
                          const Row(
                            children: [
                              Expanded(
                                child: WeeklyGoalCard(
                                  completed: 12,
                                  target: 15,
                                ),
                              ),
                              SizedBox(width: 12.0),
                              Expanded(
                                child: LearningStreakCard(
                                  streakDays: 7,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                              height:
                                  110.0), // Padding so content is not blocked by floating bottom navigation
                        ]),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildLiveClassHero(LiveClassController controller) {
    if (controller.isLoading) {
      return const UpcomingLiveClassShimmer();
    }

    final upcoming = controller.classes
        .where((c) => c.status == 'live' || c.status == 'scheduled')
        .toList();

    if (upcoming.isEmpty) {
      // Empty Hero state
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF181B23) : Colors.white,
          borderRadius: BorderRadius.circular(28.0),
          boxShadow: isDark ? null : AppTheme.softShadow,
          border: isDark ? Border.all(color: const Color(0xFF303542)) : null,
        ),
        child: Column(
          children: [
            const Icon(Icons.school_outlined,
                size: 52, color: AppColors.primary),
            const SizedBox(height: 16.0),
            Text(
              'Ready for your next lecture?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.navy,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              'No upcoming live classes right now. Explore available course lessons to continue your journey.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color:
                    isDark ? const Color(0xFFADB4C4) : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CourseListScreen()),
                );
              },
              child: const Text('Explore Courses'),
            ),
          ],
        ),
      );
    }

    final nextClass = upcoming.first;

    String timeStr = 'Starts soon';
    final diff = nextClass.scheduledStartTime.difference(DateTime.now());
    if (diff.isNegative) {
      timeStr = 'Started';
    } else {
      final hours = diff.inHours.toString().padLeft(2, '0');
      final mins = (diff.inMinutes % 60).toString().padLeft(2, '0');
      timeStr = 'Starts in $hours:$mins';
    }

    return UpcomingLiveClassCard(
      title: nextClass.title,
      instructorName: nextClass.facultyName ?? 'Faculty',
      timeRemaining: timeStr,
      onJoinTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => LiveClassDetailScreen(liveClass: nextClass),
          ),
        );
      },
    );
  }

  Widget _buildTodayClasses(LiveClassController controller) {
    final todayClasses = controller.classes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: "Today's Classes",
          onViewAllTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LiveClassListScreen()),
            );
          },
        ),
        const SizedBox(height: 4.0),
        if (controller.isLoading)
          const TodayClassShimmer()
        else if (todayClasses.isEmpty)
          const SizedBox(
            height: 100,
            child: Center(
              child: Text(
                'No classes scheduled for today.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 360;
              final class1 = todayClasses.first;
              final hasClass2 = todayClasses.length > 1;
              final class2 = hasClass2 ? todayClasses[1] : null;

              final card1 = LiveClassCard(
                title: class1.title,
                time:
                    '${_formatTime(class1.scheduledStartTime)} – ${_formatTime(class1.scheduledEndTime)}',
                instructorName: class1.facultyName ?? 'Faculty',
                imageUrl:
                    'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&q=80&w=200',
                backgroundColor: AppColors.yellowSoft,
                isLive: class1.status == 'live',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LiveClassDetailScreen(liveClass: class1),
                  ),
                ),
              );

              final card2 = class2 != null
                  ? LiveClassCard(
                      title: class2.title,
                      time:
                          '${_formatTime(class2.scheduledStartTime)} – ${_formatTime(class2.scheduledEndTime)}',
                      instructorName: class2.facultyName ?? 'Faculty',
                      imageUrl:
                          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=200',
                      backgroundColor: AppColors.lavenderSoft,
                      isLive: class2.status == 'live',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              LiveClassDetailScreen(liveClass: class2),
                        ),
                      ),
                    )
                  : LiveClassCard(
                      title: 'Physics Revision',
                      time: '02:00 PM – 03:00 PM',
                      instructorName: 'Sarah Jenkins',
                      imageUrl:
                          'https://images.unsplash.com/photo-1580489944761-15a19d654956?auto=format&fit=crop&q=80&w=200',
                      backgroundColor: AppColors.blueSoft,
                      onTap: () {},
                    );

              if (isNarrow) {
                return SizedBox(
                  height: 260,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    children: [
                      SizedBox(width: 180, child: card1),
                      const SizedBox(width: 12),
                      SizedBox(width: 180, child: card2),
                    ],
                  ),
                );
              }

              return Row(
                children: [
                  Expanded(child: card1),
                  const SizedBox(width: 12.0),
                  Expanded(child: card2),
                ],
              );
            },
          ),
      ],
    );
  }

  Widget _buildUpcomingTest(ExamProvider provider) {
    if (provider.isLoading) {
      return const UpcomingTestShimmer();
    }

    if (provider.exams.isEmpty) {
      // Fallback placeholder exam card
      return UpcomingTestCard(
        title: 'UPCOMING TEST',
        subtitle: 'Test Exam – Chapter 2',
        dateTime: 'Tomorrow, 09:00 AM',
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No real exam scheduled currently. Keep learning!'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      );
    }

    final firstExam = provider.exams.first;

    return UpcomingTestCard(
      title: 'UPCOMING TEST',
      subtitle: firstExam.title,
      dateTime: 'Tomorrow, 09:00 AM', // Fallback display time
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ExamTakingScreen(exam: firstExam),
          ),
        );
      },
    );
  }

  void _showNotificationsSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: BoxDecoration(
            color: ProfileColors.surface(isDark),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24.0)),
          ),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24.0),
                  decoration: BoxDecoration(
                    color: ProfileColors.border(isDark),
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Notifications',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Plus Jakarta Sans',
                      color: ProfileColors.deepNavy(isDark),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('All notifications marked as read'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: Text(
                      'Mark all as read',
                      style: TextStyle(
                        color: ProfileColors.primaryPurple(isDark),
                        fontWeight: FontWeight.bold,
                        fontSize: 14.0,
                        fontFamily: 'Plus Jakarta Sans',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildNotificationItem(
                      title: 'Welcome to E-Learn!',
                      body:
                          'Start your learning journey today by exploring our latest courses.',
                      time: 'Just now',
                      icon: Icons.celebration_rounded,
                      iconBgColor: ProfileColors.softLavender(isDark),
                      iconColor: ProfileColors.primaryPurple(isDark),
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12.0),
                    _buildNotificationItem(
                      title: 'New Course Available',
                      body:
                          'We have just added "Advanced Flutter Concepts". Check it out!',
                      time: '2 hours ago',
                      icon: Icons.menu_book_rounded,
                      iconBgColor: const Color(0xFFFFF4EC),
                      iconColor: Colors.orange,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12.0),
                    _buildNotificationItem(
                      title: 'Live Class Reminder',
                      body:
                          'Your live session "Introduction to FastAPI Backend" starts in 30 minutes.',
                      time: '1 day ago',
                      icon: Icons.videocam_rounded,
                      iconBgColor: const Color(0xFFE8F5E9),
                      iconColor: Colors.green,
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNotificationItem({
    required String title,
    required String body,
    required String time,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: ProfileColors.surface(isDark),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: ProfileColors.border(isDark)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20.0),
          ),
          const SizedBox(width: 14.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.0,
                    fontFamily: 'Plus Jakarta Sans',
                    color: ProfileColors.deepNavy(isDark),
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  body,
                  style: TextStyle(
                    fontSize: 12.0,
                    fontFamily: 'Plus Jakarta Sans',
                    color: ProfileColors.mutedText(isDark),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 6.0),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 10.0,
                    fontFamily: 'Plus Jakarta Sans',
                    color:
                        ProfileColors.mutedText(isDark).withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueLearning(CourseProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: "Continue Learning",
          onViewAllTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CourseListScreen()),
            );
          },
        ),
        const SizedBox(height: 4.0),
        if (provider.courses.isEmpty)
          ContinueLearningCard(
            title: 'Start learning',
            subtitle: 'Enroll in a course to begin!',
            completedLessons: 0,
            totalLessons: 10,
            onResumeTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CourseListScreen()),
              );
            },
          )
        else
          ContinueLearningCard(
            title: provider.courses.first.title,
            subtitle: 'Algebra – Linear Equations',
            completedLessons: 18,
            totalLessons: 24,
            onResumeTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      CourseDetailScreen(courseId: provider.courses.first.id),
                ),
              );
            },
          ),
      ],
    );
  }
}
