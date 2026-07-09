import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/auth/role_route.dart';

// ── Existing providers (no changes to these) ─────────────────────────────────
import '../../../../providers/user_provider.dart';
import '../../../../providers/teacher_dashboard_provider.dart';
import '../../../../providers/message_provider.dart';
import '../../../../features/live_class/presentation/controllers/live_class_controller.dart';

// ── Existing services / auth ──────────────────────────────────────────────────
import '../../../../screens/auth/login_screen.dart';
import '../../../../screens/admin/admin_dashboard_screen.dart';
import '../../../../screens/home/home_screen.dart';

// ── Existing screens (preserved routing) ─────────────────────────────────────
import '../../../../screens/courses/course_detail_screen.dart';
import '../../../../screens/courses/course_list_screen.dart';
import '../../../../screens/courses/create_course_screen.dart';
import '../../../../screens/calendar/calendar_screen.dart';
import '../../../../screens/messages/message_screen.dart';
import '../../../../screens/profile/profile_screen.dart';
import '../../../../features/live_class/presentation/screens/live_class_list_screen.dart';
import '../../../../features/live_class/presentation/screens/live_class_detail_screen.dart';

// ── Existing bottom navigation ────────────────────────────────────────────────
import '../../../../widgets/dashboard/app_bottom_navigation.dart';

// ── Dashboard widgets (new, created for this redesign) ────────────────────────
import '../widgets/dashboard_header.dart';
import '../widgets/dashboard_search_bar.dart';
import '../widgets/dashboard_quick_actions.dart';
import '../widgets/todays_overview_card.dart';
import '../widgets/todays_schedule_section.dart';
import '../widgets/attention_section.dart';
import '../widgets/dashboard_course_section.dart';
import '../widgets/student_performance_card.dart';
import '../widgets/dashboard_states.dart';

/// TeacherFacultyDashboardScreen
///
/// Redesigned dashboard for Teacher and Faculty roles.
/// Preserves ALL existing:
///  • API integrations (TeacherDashboardProvider, LiveClassController, MessageProvider)
///  • Authentication + role logic
///  • Routing callbacks
///  • State management (ChangeNotifier / Provider)
///  • Business logic
///
/// Only the presentation layer is changed.
class TeacherFacultyDashboardScreen extends StatefulWidget {
  const TeacherFacultyDashboardScreen({super.key});

  @override
  State<TeacherFacultyDashboardScreen> createState() =>
      _TeacherFacultyDashboardScreenState();
}

class _TeacherFacultyDashboardScreenState
    extends State<TeacherFacultyDashboardScreen>
    with AutomaticKeepAliveClientMixin {
  int _navIndex = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Trigger all data fetches after first frame — preserves existing patterns.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<UserProvider>().user;
      // Fetch teacher's courses via existing provider
      context.read<TeacherDashboardProvider>().fetchCourses(user?.id);
      // Load live classes via existing controller
      context.read<LiveClassController>().load();
    });
  }

  // ── Dashboard Data ──────────────────────────────────────────────────────────

  // ── Pull-to-refresh (preserved + extended) ───────────────────────────────────
  Future<void> _refresh() async {
    final user = context.read<UserProvider>().user;
    await Future.wait([
      context.read<TeacherDashboardProvider>().fetchCourses(user?.id),
      context.read<LiveClassController>().load(),
    ]);
  }

  // ── Bottom nav (same logic as HomeScreen) ────────────────────────────────────
  void _onNavTap(int index) {
    if (index == 0) {
      setState(() => _navIndex = 0);
      return;
    }
    final routes = {
      1: () => const CourseListScreen(),
      2: () => const CalendarScreen(),
      3: () => const MessageScreen(),
      4: () => const ProfileScreen(),
    };
    final builder = routes[index];
    if (builder == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => builder()),
    ).then((_) {
      if (mounted) setState(() => _navIndex = 0);
    });
    setState(() => _navIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final user = context.watch<UserProvider>().user;
    final route = resolveHomeRoute(user?.role);
    if (route != AppHomeRoute.faculty) {
      final redirect = switch (route) {
        AppHomeRoute.admin => const AdminDashboardScreen(),
        AppHomeRoute.student => const HomeScreen(),
        AppHomeRoute.login => const LoginScreen(),
        AppHomeRoute.faculty => const TeacherFacultyDashboardScreen(),
      };
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => redirect),
            (_) => false,
          );
        }
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final dashProvider = context.watch<TeacherDashboardProvider>();
    final liveCtrl = context.watch<LiveClassController>();
    final msgProvider = context.watch<MessageProvider>();

    // If user isn't loaded yet, show skeleton
    if (user == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: const SafeArea(child: DashboardLoadingView()),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      bottomNavigationBar: SafeArea(
        child: AppBottomNavigation(
          currentIndex: _navIndex,
          onTap: _onNavTap,
        ),
      ),
      body: RefreshIndicator(
        color: Theme.of(context).colorScheme.primary,
        onRefresh: _refresh,
        child: SafeArea(
          bottom: false,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(
                child: AnimatedOpacity(
                  opacity: 1.0,
                  duration: const Duration(milliseconds: 400),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── 1. Offline banner ──────────────────────────────
                      if (msgProvider.isOffline)
                        DashboardOfflineBanner(onRetry: _refresh),

                      // ── 2. Error banner (courses) ──────────────────────
                      if (dashProvider.error != null &&
                          dashProvider.courses.isEmpty)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                          child: DashboardErrorView(
                            message: dashProvider.error!,
                            onRetry: () => context
                                .read<TeacherDashboardProvider>()
                                .fetchCourses(user.id),
                          ),
                        ),

                      // ── 3. Header ──────────────────────────────────────
                      // [DashboardHeader] uses UserProfile; no hardcoded values.
                      DashboardHeader(
                        user: user,
                        unreadNotifications: msgProvider.totalUnreadCount,
                        onNotificationTap: () =>
                            _showNotificationsSheet(context),
                        onSettingsTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ProfileScreen()),
                        ),
                      ),

                      // ── 4. Search bar ──────────────────────────────────
                      // Wired to TeacherDashboardProvider.searchCourses
                      DashboardSearchBar(
                        onChanged: (q) => context
                            .read<TeacherDashboardProvider>()
                            .searchCourses(q),
                      ),

                      const SizedBox(height: 16),

                      // ── 5. Quick actions ───────────────────────────────
                      // Each callback preserves existing routes.
                      DashboardQuickActions(
                        onLiveClass: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const LiveClassListScreen()),
                        ),
                        onNewCourse: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const CreateCourseScreen()),
                          );
                          if (!context.mounted) return;
                          context
                              .read<TeacherDashboardProvider>()
                              .fetchCourses(user.id);
                        },
                        onUpload: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const CourseListScreen()),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ── 6. Today's Overview card ───────────────────────
                      // Real data: courseCount + liveClasses + unreadMessages
                      TodaysOverviewCard(
                        courseCount: dashProvider.courses.length,
                        liveClasses: liveCtrl.classes,
                        unreadMessages: msgProvider.totalUnreadCount,
                        onNextClassTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const CalendarScreen()),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ── 7. Today's Schedule ────────────────────────────
                      // Real LiveClass data from LiveClassController.
                      if (liveCtrl.isLoading)
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: LinearProgressIndicator(minHeight: 2),
                        )
                      else
                        TodaysScheduleSection(
                          classes: liveCtrl.classes,
                          onViewCalendar: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const CalendarScreen()),
                          ),
                          onManage: (cls) => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  LiveClassDetailScreen(liveClass: cls),
                            ),
                          ),
                          onStartClass: (cls) => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  LiveClassDetailScreen(liveClass: cls),
                            ),
                          ),
                        ),

                      const SizedBox(height: 20),

                      // ── 8. Needs Your Attention ────────────────────────
                      // Uses real data as proxies:
                      //   courses   → assignments to manage
                      //   messages  → unread student messages
                      //   classes   → upcoming live sessions
                      AttentionSection(
                        courseCount: dashProvider.courses.length,
                        unreadMessages: msgProvider.totalUnreadCount,
                        liveClassCount: liveCtrl.classes
                            .where((c) =>
                                c.status == 'live' || c.status == 'scheduled')
                            .length,
                        onAssignmentsTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const CourseListScreen()),
                        ),
                        onMessagesTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const MessageScreen()),
                        ),
                        onDeadlinesTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const LiveClassListScreen()),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ── 9. Your Courses ────────────────────────────────
                      // Uses TeacherDashboardProvider — filtered list.
                      // Filter chips are wired to existing filterByCategory().
                      DashboardCourseSection(
                        courses: dashProvider.courses,
                        activeFilter: dashProvider.activeCategory,
                        isLoading: dashProvider.isLoading,
                        onFilterChanged: (f) => context
                            .read<TeacherDashboardProvider>()
                            .filterByCategory(f),
                        onManage: (course) => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                CourseDetailScreen(courseId: course.id),
                          ),
                        ),
                        onViewAll: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const CourseListScreen()),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ── 10. Student Performance ────────────────────────
                      StudentPerformanceCard(
                        activeCourses: dashProvider.courses.length,
                        totalMessages: msgProvider.totalUnreadCount,
                        liveClassCount: liveCtrl.classes.length,
                      ),

                      // Bottom padding for nav bar
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Notifications bottom sheet (preserved from home_screen) ─────────────────
  void _showNotificationsSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetColor = isDark ? const Color(0xFF181B23) : Colors.white;
    final handleColor =
        isDark ? const Color(0xFF303542) : const Color(0xFFE9EBF2);
    final titleColor = isDark ? Colors.white : const Color(0xFF101936);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.55,
        decoration: BoxDecoration(
          color: sheetColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: handleColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              'Notifications',
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w800, color: titleColor),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  _notifItem(
                      Icons.school_rounded,
                      const Color(0xFFE9E2FF),
                      const Color(0xFF6C45D8),
                      'Dashboard loaded',
                      'Your dashboard data is up to date.',
                      'Just now'),
                  const SizedBox(height: 10),
                  _notifItem(
                      Icons.video_camera_front_rounded,
                      const Color(0xFFFFE6CF),
                      const Color(0xFFFF963F),
                      'Live Class',
                      'Remember to start your scheduled class on time.',
                      '1 hour ago'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _notifItem(IconData icon, Color bg, Color fg, String title,
      String body, String time) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF222631) : Colors.white;
    final borderColor =
        isDark ? const Color(0xFF303542) : const Color(0xFFE9EBF2);
    final titleColor = isDark ? Colors.white : const Color(0xFF101936);
    final displayFg = isDark
        ? (fg == const Color(0xFF6C45D8)
            ? Theme.of(context).colorScheme.primary
            : fg)
        : fg;
    final displayBg = isDark ? displayFg.withValues(alpha: 0.15) : bg;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: displayBg, shape: BoxShape.circle),
            child: Icon(icon, color: displayFg, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: titleColor)),
              const SizedBox(height: 3),
              Text(body,
                  style:
                      const TextStyle(fontSize: 12, color: Color(0xFF6F7588))),
              const SizedBox(height: 4),
              Text(time,
                  style:
                      const TextStyle(fontSize: 10, color: Color(0xFF6F7588))),
            ]),
          ),
        ],
      ),
    );
  }
}
