import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../../../../models/course.dart';

/// DashboardCourseSection — "Your Courses" section with filter chips
/// and a list of DashboardCourseCard.
class DashboardCourseSection extends StatelessWidget {
  final List<Course> courses;
  final String activeFilter;
  final ValueChanged<String> onFilterChanged;
  final ValueChanged<Course> onManage;
  final VoidCallback onViewAll;
  final bool isLoading;

  const DashboardCourseSection({
    super.key,
    required this.courses,
    required this.activeFilter,
    required this.onFilterChanged,
    required this.onManage,
    required this.onViewAll,
    this.isLoading = false,
  });

  static const _filters = ['All', 'Courses', 'Uploads', 'Scheduled'];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : AppColors.navy;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header ──────────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
          child: Row(
            children: [
              Text('Your Courses',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: titleColor)),
              const Spacer(),
              GestureDetector(
                onTap: onViewAll,
                child: Row(
                  children: [
                    Text('View All',
                        style: TextStyle(
                            fontSize: 13,
                            color: primaryColor,
                            fontWeight: FontWeight.w600)),
                    Icon(Icons.chevron_right_rounded,
                        size: 16, color: primaryColor),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ── Filter chips ────────────────────────────────────────────────────
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            itemCount: _filters.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final f = _filters[i];
              final isActive = f == activeFilter;
              final chipBgColor = isActive
                  ? primaryColor
                  : (isDark ? const Color(0xFF181B23) : Colors.white);
              final chipBorderColor = isActive
                  ? primaryColor
                  : (isDark ? const Color(0xFF303542) : AppColors.border);
              final chipTextColor = isActive
                  ? Theme.of(context).colorScheme.onPrimary
                  : (isDark ? Colors.white : AppColors.navy);

              return GestureDetector(
                onTap: () => onFilterChanged(f),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: chipBgColor,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    border: Border.all(
                      color: chipBorderColor,
                    ),
                  ),
                  child: Text(
                    f,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: chipTextColor,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 8),

        // ── Course list ─────────────────────────────────────────────────────
        if (isLoading)
          _CourseSkeleton()
        else if (courses.isEmpty)
          _EmptyCourses(filter: activeFilter)
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: courses.take(5).length, // max 5 on dashboard
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) => DashboardCourseCard(
              key: ValueKey(courses[i].id),
              course: courses[i],
              index: i,
              onManage: () => onManage(courses[i]),
            ),
          ),
      ],
    );
  }
}

// ── DashboardCourseCard ────────────────────────────────────────────────────────

class DashboardCourseCard extends StatelessWidget {
  final Course course;
  final int index;
  final VoidCallback onManage;

  const DashboardCourseCard({
    super.key,
    required this.course,
    required this.index,
    required this.onManage,
  });

  static const _gradients = [
    LinearGradient(colors: [Color(0xFF6C45D8), Color(0xFF9B6DFF)]),
    LinearGradient(colors: [Color(0xFF2AA7F2), Color(0xFF47BFFF)]),
    LinearGradient(colors: [Color(0xFF2DCB82), Color(0xFF3DE8A0)]),
    LinearGradient(colors: [Color(0xFFFF963F), Color(0xFFFFBA80)]),
  ];

  @override
  Widget build(BuildContext context) {
    final gradient = _gradients[index % _gradients.length];
    final isFree = course.isFree;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBgColor = isDark ? const Color(0xFF181B23) : Colors.white;
    final borderColor = isDark ? const Color(0xFF303542) : AppColors.border;
    final titleColor = isDark ? Colors.white : AppColors.navy;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Semantics(
      label: '${course.title}, ${isFree ? "Free" : "Paid"} course',
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardBgColor,
          borderRadius: BorderRadius.circular(AppRadius.medium),
          border: Border.all(color: borderColor),
          boxShadow: isDark ? null : AppTheme.miniShadow,
        ),
        child: Row(
          children: [
            // Thumbnail / gradient placeholder
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: course.thumbnailUrl == null ? gradient : null,
                borderRadius: BorderRadius.circular(10),
              ),
              clipBehavior: Clip.antiAlias,
              child: course.thumbnailUrl != null
                  ? Image.network(
                      course.thumbnailUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => DecoratedBox(
                        decoration: BoxDecoration(gradient: gradient),
                        child: const Icon(Icons.school_rounded,
                            color: Colors.white, size: 28),
                      ),
                    )
                  : const Icon(Icons.school_rounded,
                      color: Colors.white, size: 28),
            ),

            const SizedBox(width: 12),

            // Title + meta
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.title,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: titleColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isFree
                              ? (isDark
                                  ? AppColors.success.withValues(alpha: 0.15)
                                  : AppColors.greenSoft)
                              : (isDark
                                  ? primaryColor.withValues(alpha: 0.15)
                                  : AppColors.primarySoft),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          isFree
                              ? 'Free'
                              : '₹${course.price.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: isFree ? AppColors.success : primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(Icons.calendar_today_outlined,
                          size: 11, color: AppColors.textSecondary),
                      const SizedBox(width: 3),
                      Text(
                        _formatDate(course.updatedAt),
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Manage button
            SizedBox(
              height: 34,
              child: OutlinedButton(
                onPressed: onManage,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  side: BorderSide(color: primaryColor),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  textStyle: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.bold),
                ),
                child: Text('Manage',
                    style: TextStyle(color: primaryColor, fontSize: 12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return '$diff days ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

// ── Skeleton loading ───────────────────────────────────────────────────────────

class _CourseSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final skeletonColor = isDark ? const Color(0xFF222631) : AppColors.border;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: List.generate(
            3,
            (_) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    height: 80,
                    decoration: BoxDecoration(
                      color: skeletonColor,
                      borderRadius: BorderRadius.circular(AppRadius.medium),
                    ),
                  ),
                )),
      ),
    );
  }
}

// ── Empty state ────────────────────────────────────────────────────────────────

class _EmptyCourses extends StatelessWidget {
  final String filter;
  const _EmptyCourses({required this.filter});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDark ? const Color(0xFF303542) : AppColors.border;

    final messages = {
      'Courses': 'No paid courses yet.',
      'Uploads': 'No free courses yet.',
      'Scheduled': 'No recently added courses.',
      'All': 'No courses yet. Create your first course!',
    };
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.school_outlined, size: 44, color: iconColor),
            const SizedBox(height: 12),
            Text(
              messages[filter] ?? 'No courses yet.',
              textAlign: TextAlign.center,
              style:
                  const TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
