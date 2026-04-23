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

/// Converts a relative backend path (e.g. '/static/thumbnails/abc.jpg')
/// to a full URL. Leaves already-absolute URLs unchanged.
String _fullImageUrl(String? path) {
  if (path == null || path.isEmpty) return '';
  if (path.startsWith('http')) return path;
  return '${AppConstants.serverBase}$path';
}

// ─────────────────────────────────────────────────────────────────────────────
//  HOME SCREEN
// ─────────────────────────────────────────────────────────────────────────────

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
      'color': Color(0xFF5C6BC0),
    },
    {
      'icon': Icons.security_rounded,
      'label': 'Cybersecurity',
      'color': Color(0xFFE53935),
    },
    {
      'icon': Icons.design_services_rounded,
      'label': 'Design',
      'color': Color(0xFF8E24AA),
    },
    {
      'icon': Icons.business_center_rounded,
      'label': 'Business',
      'color': Color(0xFFF4511E),
    },
  ];

  static const _cardColors = [
    Color(0xFF5C6BC0),
    Color(0xFF26A69A),
    Color(0xFF8E24AA),
    Color(0xFFF4511E),
    Color(0xFF00897B),
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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      floatingActionButton: (user?.role == 'faculty' || user?.role == 'admin')
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreateCourseScreen()),
                );
              },
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Add Course'),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: () => context.read<CourseProvider>().fetchCourses(),
        child: CustomScrollView(
          slivers: [
            // ── 1. Header ─────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: _Header(
                name: user?.name,
                initials: _getInitials(user?.name),
                color: colorScheme.primary,
                onLogout: _logout,
              ),
            ),

            // ── 2. Continue Learning ───────────────────────────────────────
            if (context.watch<UserProvider>().role != 'faculty' && context.watch<UserProvider>().role != 'admin') ...[
              SliverToBoxAdapter(
                child: _SectionTitle(
                  title: 'Continue Learning',
                  onSeeAll: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CourseListScreen()),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: courseState.isLoading
                      ? const _ShimmerBox(height: 130, borderRadius: 16)
                      : const _ContinueLearningEmpty(),
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
                height: 210,
                child: courseState.isLoading
                    ? _buildRecommendedShimmer()
                    : courseState.courses.isEmpty
                    ? const _EmptyHorizontalCourses()
                    : _buildRecommendedList(courseState.courses, context),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 8)),

            // ── 4. Categories ──────────────────────────────────────────────
            SliverToBoxAdapter(
              child: _SectionTitle(title: 'Browse Categories'),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 2.2,
                  ),
                  itemCount: _categoryItems.length,
                  itemBuilder: (context, i) {
                    final item = _categoryItems[i];
                    return _CategoryChip(
                      icon: item['icon'] as IconData,
                      label: item['label'] as String,
                      color: item['color'] as Color,
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

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // ── 5. Quick Actions ───────────────────────────────────────────
            SliverToBoxAdapter(child: _SectionTitle(title: 'Quick Actions')),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                child: Row(
                  children: [
                    Expanded(
                      child: _QuickActionCard(
                        icon: Icons.play_lesson_rounded,
                        label: 'My Courses',
                        color: colorScheme.primary,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CourseListScreen(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _QuickActionCard(
                        icon: Icons.quiz_rounded,
                        label: 'Exams',
                        color: const Color(0xFFF4511E),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Exams coming soon!'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
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

  Widget _buildRecommendedShimmer() {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 3,
      separatorBuilder: (context, index) => const SizedBox(width: 12),
      itemBuilder: (context, index) =>
          const _ShimmerBox(width: 170, height: 210, borderRadius: 16),
    );
  }

  Widget _buildRecommendedList(List<Course> courses, BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: courses.length > 8 ? 8 : courses.length,
      separatorBuilder: (context, index) => const SizedBox(width: 12),
      itemBuilder: (context, i) {
        final course = courses[i];
        return _RecommendedCard(
          course: course,
          color: _cardColors[i % _cardColors.length],
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

// ─────────────────────────────────────────────────────────────────────────────
//  HEADER
// ─────────────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final String? name;
  final String initials;
  final Color color;
  final VoidCallback onLogout;

  const _Header({
    required this.name,
    required this.initials,
    required this.color,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.75)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top row: greeting + avatar ────────────────────────────────
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, ${name?.split(' ').first ?? 'Learner'} 👋',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Let's continue learning",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
              // Notification
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.notifications_outlined,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              // Avatar
              GestureDetector(
                onTap: onLogout,
                child: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    initials,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── Search bar ─────────────────────────────────────────────────
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const SizedBox(width: 14),
                Icon(Icons.search_rounded, color: Colors.grey.shade400),
                const SizedBox(width: 10),
                Text(
                  'Search courses...',
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  CONTINUE LEARNING — Empty State
// ─────────────────────────────────────────────────────────────────────────────

class _ContinueLearningEmpty extends StatelessWidget {
  const _ContinueLearningEmpty();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.auto_stories_rounded, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Start your learning journey',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  "You haven't enrolled in any courses yet.",
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CourseListScreen()),
            ),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              textStyle: const TextStyle(fontSize: 12),
            ),
            child: const Text('Browse'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  RECOMMENDED COURSE CARD (Horizontal)
// ─────────────────────────────────────────────────────────────────────────────

class _RecommendedCard extends StatelessWidget {
  final Course course;
  final Color color;
  final VoidCallback onTap;

  const _RecommendedCard({
    required this.course,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 170,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Thumbnail ────────────────────────────────────────────────
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: course.thumbnailUrl != null
                  ? Image.network(
                      _fullImageUrl(course.thumbnailUrl),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      // Show icon if image fails to load
                      errorBuilder: (context, error, stackTrace) => Center(
                        child: Icon(
                          Icons.menu_book_rounded,
                          color: color,
                          size: 40,
                        ),
                      ),
                      // Show icon while loading
                      loadingBuilder: (_, child, progress) {
                        if (progress == null) return child;
                        return Center(
                          child: Icon(
                            Icons.menu_book_rounded,
                            color: color.withOpacity(0.4),
                            size: 40,
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Icon(
                        Icons.menu_book_rounded,
                        color: color,
                        size: 40,
                      ),
                    ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.star_rounded,
                        color: Colors.amber.shade600,
                        size: 14,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '4.5',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: course.isFree
                              ? Colors.green.shade50
                              : color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
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
                                : color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  CATEGORY CHIP
// ─────────────────────────────────────────────────────────────────────────────

class _CategoryChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 14),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
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

// ─────────────────────────────────────────────────────────────────────────────
//  QUICK ACTION CARD
// ─────────────────────────────────────────────────────────────────────────────

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  SECTION TITLE
// ─────────────────────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;

  const _SectionTitle({required this.title, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          if (onSeeAll != null)
            GestureDetector(
              onTap: onSeeAll,
              child: Text(
                'See all',
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  EMPTY STATE — No recommended courses
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyHorizontalCourses extends StatelessWidget {
  const _EmptyHorizontalCourses();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.school_outlined, size: 36, color: Colors.grey.shade300),
          const SizedBox(height: 8),
          Text(
            'No courses available yet',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  SHIMMER BOX
// ─────────────────────────────────────────────────────────────────────────────

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
