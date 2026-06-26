import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/user_provider.dart';
import '../providers/teacher_dashboard_provider.dart';
import '../services/auth_service.dart';
import '../widgets/teacher_header.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/ai_assistant_card.dart';
import '../widgets/featured_action_card.dart';
import '../widgets/category_chips.dart';
import '../widgets/course_card.dart';
import '../widgets/analytics_card.dart';
import 'auth/login_screen.dart';
import 'courses/course_detail_screen.dart';
import 'courses/create_course_screen.dart';

class TeacherHomeScreen extends StatefulWidget {
  const TeacherHomeScreen({super.key});

  @override
  State<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends State<TeacherHomeScreen> {
  // Pastel Gradients for Courses (matching redesign)
  static const _courseGradients = [
    LinearGradient(colors: [Color(0xFFA78BFA), Color(0xFFC084FC)]), // Purple
    LinearGradient(colors: [Color(0xFF60A5FA), Color(0xFF818CF8)]), // Blue
    LinearGradient(colors: [Color(0xFF34D399), Color(0xFF10B981)]), // Green
    LinearGradient(colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)]), // Amber
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<UserProvider>().user;
      context.read<TeacherDashboardProvider>().fetchCourses(user?.id);
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

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Consumer<TeacherDashboardProvider>(
          builder: (context, provider, _) {
            // Update stats with redesign styling
            final styledStats = _getStyledStats(provider);

            return RefreshIndicator(
              onRefresh: () => provider.fetchCourses(user?.id),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── 1. Header ─────────────────────────────────────────
                    TeacherHeader(
                      userName: user?.name.split(' ').first ?? 'Sarah',
                      onNotificationTap: () {},
                      onProfileTap: _logout,
                    ),

                    // ── 2. Search Bar ─────────────────────────────────────
                    SearchBarWidget(onChanged: (val) {}),

                    // ── 3. AI Assistant Card ──────────────────────────────
                    const AIAssistantCard(),

                    // ── 4. Featured Action Card ───────────────────────────
                    FeaturedActionCard(
                      title: 'Advanced React Patterns',
                      lessonsCount: 12,
                      duration: '45 min',
                      progress: 0.68,
                      onPlayTap: () {},
                    ),

                    // ── 5. Section: Let's teach ───────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.sm),
                      child: Text(
                        "Let's teach",
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),

                    // ── 6. Category Chips ─────────────────────────────────
                    CategoryChips(
                      categories: const ['All', 'Courses', 'Uploads', 'Scheduled'],
                      onCategorySelected: (category) {},
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    // ── 7. Course List ────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      child: provider.isLoading && provider.courses.isEmpty
                          ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary)))
                          : provider.courses.isEmpty
                              ? _buildEmptyState(provider, user?.id)
                              : Column(
                                  children: provider.courses.asMap().entries.map((entry) {
                                    final index = entry.key;
                                    final course = entry.value;
                                    return CourseCard(
                                      course: course,
                                      students: 1234,
                                      duration: '6 weeks',
                                      gradient: _courseGradients[index % _courseGradients.length],
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => CourseDetailScreen(courseId: course.id),
                                          ),
                                        );
                                      },
                                    );
                                  }).toList(),
                                ),
                    ),

                    // ── 8. Analytics Section ──────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.lg, AppSpacing.md, AppSpacing.sm),
                      child: Text(
                        "Analytics",
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.xxl),
                      child: GridView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: AppSpacing.sm + 4,
                          mainAxisSpacing: AppSpacing.sm + 4,
                          childAspectRatio: 1.25,
                        ),
                        itemCount: styledStats.length,
                        itemBuilder: (context, index) {
                          return AnalyticsCard(stat: styledStats[index]);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateCourseScreen()),
          ).then((_) {
            if (mounted) {
              final user = context.read<UserProvider>().user;
              context.read<TeacherDashboardProvider>().fetchCourses(user?.id);
            }
          });
        },
        backgroundColor: AppColors.primary,
        elevation: 2,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New Course', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.medium)),
      ),
    );
  }

  List<DashboardStat> _getStyledStats(TeacherDashboardProvider provider) {
    // Redesign stats configuration
    final configs = [
      {
        'gradient': const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF2563EB)]),
        'bgColor': const Color(0xFFEFF6FF),
        'shadowColor': const Color(0xFF3B82F6),
      },
      {
        'gradient': const LinearGradient(colors: [Color(0xFFA855F7), Color(0xFF9333EA)]),
        'bgColor': const Color(0xFFF5F3FF),
        'shadowColor': const Color(0xFFA855F7),
      },
      {
        'gradient': const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)]),
        'bgColor': const Color(0xFFECFDF5),
        'shadowColor': const Color(0xFF10B981),
      },
      {
        'gradient': const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFD97706)]),
        'bgColor': const Color(0xFFFFFBEB),
        'shadowColor': const Color(0xFFF59E0B),
      },
    ];

    return provider.stats.asMap().entries.map((entry) {
      final index = entry.key;
      final stat = entry.value;
      final config = configs[index % configs.length];

      return DashboardStat(
        label: stat.label,
        value: stat.value,
        change: stat.change,
        icon: stat.icon,
        gradient: config['gradient'] as LinearGradient,
        bgColor: config['bgColor'] as Color,
        shadowColor: config['shadowColor'] as Color,
      );
    }).toList();
  }

  Widget _buildEmptyState(TeacherDashboardProvider provider, String? userId) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: AppSpacing.xl),
          const Icon(Icons.school_outlined, size: 52, color: AppColors.textSecondary),
          const SizedBox(height: AppSpacing.md),
          Text(
            provider.error ?? 'No courses yet',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextButton(
            onPressed: () => provider.fetchCourses(userId),
            child: const Text('Refresh'),
          ),
        ],
      ),
    );
  }
}
