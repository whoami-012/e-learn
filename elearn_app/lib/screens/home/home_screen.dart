import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/course_provider.dart';
import '../../models/course.dart';
import '../../services/auth_service.dart';
import '../../core/constants/app_constants.dart';
import '../auth/login_screen.dart';
import '../courses/course_list_screen.dart';
import '../courses/course_detail_screen.dart';
import '../courses/create_course_screen.dart';
import '../admin/admin_dashboard_screen.dart';
import '../../theme/app_theme.dart';

String _fullImageUrl(String? path) {
  if (path == null || path.isEmpty) return '';
  if (path.startsWith('http')) return path;
  return '${AppConstants.serverBase}$path';
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _categoryItems = [
    {
      'icon': Icons.code_rounded,
      'label': 'Development',
      'color': AppColors.blue,
      'bgColor': AppColors.pastelBlue,
    },
    {
      'icon': Icons.security_rounded,
      'label': 'Cybersecurity',
      'color': AppColors.error,
      'bgColor': AppColors.pastelPink,
    },
    {
      'icon': Icons.design_services_rounded,
      'label': 'Design',
      'color': AppColors.primary,
      'bgColor': AppColors.pastelPurple,
    },
    {
      'icon': Icons.business_center_rounded,
      'label': 'Business',
      'color': AppColors.warning,
      'bgColor': AppColors.pastelYellow,
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<UserProvider>();
      if (!provider.hasUser) provider.loadUser();
      context.read<CourseProvider>().fetchCourses();
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

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;
    final courseState = context.watch<CourseProvider>();
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: (user?.role == 'faculty' || user?.role == 'admin')
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreateCourseScreen()),
                );
              },
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.add_circle_outline_rounded, color: Colors.white),
              label: const Text('Add Course', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.medium)),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: () => context.read<CourseProvider>().fetchCourses(),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            // ── 1. Header ─────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: _Header(
                name: user?.name,
                initials: _getInitials(user?.name),
                onLogout: _logout,
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sm)),

            // ── 2. Hero Card / Continue Learning ───────────────────────────
            if (context.watch<UserProvider>().role != 'faculty' && context.watch<UserProvider>().role != 'admin') ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: courseState.isLoading
                      ? const _ShimmerBox(height: 140, borderRadius: AppRadius.large)
                      : _buildHeroSection(courseState.courses),
                ),
              ),
            ],

            // ── 3. Recommended Courses ─────────────────────────────────────
            SliverToBoxAdapter(
              child: _SectionTitle(
                title: 'Recommended For You',
                onSeeAll: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CourseListScreen()),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: SizedBox(
                height: 220,
                child: courseState.isLoading
                    ? _buildRecommendedShimmer()
                    : courseState.courses.isEmpty
                        ? const _EmptyHorizontalCourses()
                        : _buildRecommendedList(courseState.courses, context),
              ),
            ),

            // ── 4. Categories ──────────────────────────────────────────────
            SliverToBoxAdapter(
              child: _SectionTitle(title: 'Browse Categories'),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: AppSpacing.sm + 4,
                    mainAxisSpacing: AppSpacing.sm + 4,
                    childAspectRatio: 2.3,
                  ),
                  itemCount: _categoryItems.length,
                  itemBuilder: (context, i) {
                    final item = _categoryItems[i];
                    return _CategoryChip(
                      icon: item['icon'] as IconData,
                      label: item['label'] as String,
                      color: item['color'] as Color,
                      bgColor: item['bgColor'] as Color,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CourseListScreen(),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // ── 5. Quick Actions ───────────────────────────────────────────
            SliverToBoxAdapter(child: _SectionTitle(title: 'Quick Actions')),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.xl),
                child: Row(
                  children: [
                    Expanded(
                      child: _QuickActionCard(
                        icon: Icons.play_lesson_rounded,
                        label: 'My Courses',
                        color: AppColors.primary,
                        bgColor: AppColors.primarySoft,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CourseListScreen(),
                          ),
                        ),
                      ),
                    ),
                    if (context.watch<UserProvider>().role == 'admin') ...[
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _QuickActionCard(
                          icon: Icons.admin_panel_settings_rounded,
                          label: 'Admin Panel',
                          color: AppColors.secondary,
                          bgColor: AppColors.pastelYellow,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AdminDashboardScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    ] else ...[
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _QuickActionCard(
                          icon: Icons.quiz_rounded,
                          label: 'Exams',
                          color: AppColors.secondary,
                          bgColor: AppColors.pastelYellow,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Access exams from within a course!'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(List<Course> courses) {
    if (courses.isEmpty) {
      return const _ContinueLearningEmpty();
    }
    // We display the first course as a featured/continue learning hero card
    final featuredCourse = courses.first;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.pastelPurple,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: AppColors.primarySoft, width: 1.5),
        boxShadow: AppTheme.miniShadow,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: const Text(
                    'Featured Class',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  featuredCourse.title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Learn from expert instructors',
                  style: TextStyle(
                    color: AppColors.textSecondary.withOpacity(0.9),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CourseDetailScreen(courseId: featuredCourse.id),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.small),
                    ),
                  ),
                  child: const Text(
                    'Resume Learning',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          // Beautiful Progress Ring Representation
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 76,
                height: 76,
                child: CircularProgressIndicator(
                  value: 0.65,
                  strokeWidth: 8,
                  backgroundColor: Colors.white.withOpacity(0.5),
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
              const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '65%',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Done',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedShimmer() {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      itemCount: 3,
      separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.sm),
      itemBuilder: (context, index) =>
          const _ShimmerBox(width: 180, height: 220, borderRadius: AppRadius.medium),
    );
  }

  Widget _buildRecommendedList(List<Course> courses, BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      itemCount: courses.length > 8 ? 8 : courses.length,
      separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.md),
      itemBuilder: (context, i) {
        final course = courses[i];
        return _RecommendedCard(
          course: course,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CourseDetailScreen(courseId: course.id),
            ),
          ),
        );
      },
    );
  }
}

// ── HEADER ─────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final String? name;
  final String initials;
  final VoidCallback onLogout;

  const _Header({
    required this.name,
    required this.initials,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, 52, AppSpacing.md, AppSpacing.md),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(AppRadius.large)),
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, ${name?.split(' ').first ?? 'Learner'} 👋',
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Let's continue learning",
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Notification Action
              InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(AppRadius.small),
                child: Container(
                  height: 42,
                  width: 42,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(AppRadius.small),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(
                    Icons.notifications_outlined,
                    color: AppColors.textPrimary,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              // User Avatar with logout trigger
              GestureDetector(
                onTap: onLogout,
                child: Container(
                  height: 42,
                  width: 42,
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(AppRadius.small),
                    border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // Custom interactive Search action field
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CourseListScreen()),
              );
            },
            borderRadius: BorderRadius.circular(AppRadius.medium),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(AppRadius.medium),
                border: Border.all(color: AppColors.border),
              ),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Row(
                children: [
                  const Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Search courses...',
                    style: TextStyle(color: AppColors.textSecondary.withOpacity(0.8), fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── CONTINUE LEARNING — Empty State ──────────────────────────────────────────

class _ContinueLearningEmpty extends StatelessWidget {
  const _ContinueLearningEmpty();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: AppColors.border),
        boxShadow: AppTheme.miniShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(AppRadius.medium),
            ),
            child: const Icon(Icons.auto_stories_rounded, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Start your learning journey',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  "You haven't enrolled in any courses yet.",
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CourseListScreen()),
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.small),
              ),
            ),
            child: const Text('Browse', style: TextStyle(fontSize: 12, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ── RECOMMENDED COURSE CARD ──────────────────────────────────────────────────

class _RecommendedCard extends StatelessWidget {
  final Course course;
  final VoidCallback onTap;

  const _RecommendedCard({
    required this.course,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 175,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.large),
          boxShadow: AppTheme.softShadow,
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            Container(
              height: 104,
              decoration: const BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppRadius.large),
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: course.thumbnailUrl != null && course.thumbnailUrl!.isNotEmpty
                  ? Image.network(
                      _fullImageUrl(course.thumbnailUrl),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) => const Center(
                        child: Icon(
                          Icons.menu_book_rounded,
                          color: AppColors.primary,
                          size: 36,
                        ),
                      ),
                    )
                  : const Center(
                      child: Icon(
                        Icons.menu_book_rounded,
                        color: AppColors.primary,
                        size: 36,
                      ),
                    ),
            ),
            // Details info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.sm + 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title,
                      style: textTheme.titleSmall?.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: AppColors.warning,
                          size: 14,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '4.8',
                          style: textTheme.bodySmall?.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: course.isFree
                                ? AppColors.pastelMint
                                : AppColors.primarySoft,
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                          ),
                          child: Text(
                            course.isFree
                                ? 'FREE'
                                : '₹${course.price.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: course.isFree
                                  ? Colors.green.shade700
                                  : AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── CATEGORY CHIP ───────────────────────────────────────────────────────────

class _CategoryChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.medium),
          boxShadow: AppTheme.miniShadow,
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const SizedBox(width: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(AppRadius.small),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: AppColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── QUICK ACTION CARD ────────────────────────────────────────────────────────

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.large),
          border: Border.all(color: AppColors.border),
          boxShadow: AppTheme.miniShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm + 2),
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              label,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── SECTION TITLE ────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;

  const _SectionTitle({required this.title, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.lg, AppSpacing.md, AppSpacing.md),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          const Spacer(),
          if (onSeeAll != null)
            GestureDetector(
              onTap: onSeeAll,
              child: const Text(
                'See all',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── EMPTY STATE — No recommended courses ──────────────────────────────────────

class _EmptyHorizontalCourses extends StatelessWidget {
  const _EmptyHorizontalCourses();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.school_outlined, size: 36, color: AppColors.textSecondary),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'No courses available yet',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

// ── SHIMMER BOX ──────────────────────────────────────────────────────────────

class _ShimmerBox extends StatefulWidget {
  final double? width;
  final double height;
  final double borderRadius;

  const _ShimmerBox({this.width, required this.height, this.borderRadius = 8});

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _anim = Tween<double>(
      begin: 0.25,
      end: 0.55,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, child) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(_anim.value),
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
      ),
    );
  }
}
