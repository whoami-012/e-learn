import 'package:flutter/material.dart';
import '../../models/course.dart';
import '../../models/lesson.dart';
import '../../theme/app_theme.dart';

/// 1. Course Hero Card
class CourseHeroCard extends StatelessWidget {
  final Course course;
  final bool isLive;
  final VoidCallback onPlayTap;

  const CourseHeroCard({
    required this.course,
    required this.isLive,
    required this.onPlayTap,
    super.key,
  });

  String _fullImageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    // Base URL path mapping if backend doesn't return full path
    return 'http://13.203.201.60$path';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final imageUrl = _fullImageUrl(course.thumbnailUrl);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      height: 200,
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: colors.outlineVariant, width: 1),
        boxShadow: AppTheme.softShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Image / Placeholder
          imageUrl.isNotEmpty
              ? Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildPlaceholder(),
                )
              : _buildPlaceholder(),

          // Dark Overlay for play button readability
          Container(
            color: Colors.black.withValues(alpha: 0.2),
          ),

          // Play Button
          Center(
            child: InkWell(
              onTap: onPlayTap,
              borderRadius: BorderRadius.circular(AppRadius.pill),
              child: Container(
                height: 56,
                width: 56,
                decoration: BoxDecoration(
                  gradient: AppTheme.playButtonGradient,
                  shape: BoxShape.circle,
                  boxShadow: AppTheme.purpleShadow,
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
          ),

          // Live indicator pill
          if (isLive)
            Positioned(
              top: AppSpacing.md,
              left: AppSpacing.md,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  boxShadow: AppTheme.miniShadow,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.live,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Live',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: colors.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.primaryGradient,
      ),
      child: const Icon(
        Icons.menu_book_rounded,
        size: 64,
        color: Colors.white24,
      ),
    );
  }
}

/// 2. Instructor Card
class CourseInstructorCard extends StatelessWidget {
  final String name;
  final String subtitle;

  const CourseInstructorCard({
    required this.name,
    required this.subtitle,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: colors.outlineVariant, width: 1),
        boxShadow: AppTheme.miniShadow,
      ),
      child: Row(
        children: [
          // Circular Avatar with Initials
          Container(
            height: 48,
            width: 48,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppTheme.avatarGradient,
            ),
            alignment: Alignment.center,
            child: Text(
              name.isNotEmpty ? name.split(' ').map((e) => e[0]).take(2).join().toUpperCase() : 'IN',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: colors.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // Follow button is conditionally hidden/omitted as per guidelines
        ],
      ),
    );
  }
}

/// 3. Metadata Card Grid
class CourseMetadataCard extends StatelessWidget {
  final Course course;

  const CourseMetadataCard({
    required this.course,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // Determine dynamic format date strings from real attributes
    final String createdStr = '${course.createdAt.year}-${course.createdAt.month.toString().padLeft(2, '0')}-${course.createdAt.day.toString().padLeft(2, '0')}';
    final String updatedStr = '${course.updatedAt.year}-${course.updatedAt.month.toString().padLeft(2, '0')}-${course.updatedAt.day.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: colors.outlineVariant, width: 1),
        boxShadow: AppTheme.miniShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Course Metadata',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.2,
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
            children: [
              _buildMetadataItem(
                context,
                Icons.calendar_month_rounded,
                'Created At',
                createdStr,
                isDark ? colors.primary.withValues(alpha: 0.15) : AppColors.blueSoft,
                isDark ? colors.primary : AppColors.blue,
              ),
              _buildMetadataItem(
                context,
                Icons.update_rounded,
                'Updated At',
                updatedStr,
                isDark ? colors.primary.withValues(alpha: 0.15) : AppColors.lavenderSoft,
                isDark ? colors.primary : AppColors.primary,
              ),
              _buildMetadataItem(
                context,
                Icons.wallet_rounded,
                'Access Type',
                course.isFree ? 'Free Access' : 'Premium',
                course.isFree
                    ? (isDark ? colors.error.withValues(alpha: 0.15) : AppColors.greenSoft) // Using success/error theme-aware values
                    : (isDark ? colors.secondary.withValues(alpha: 0.15) : AppColors.orangeSoft),
                course.isFree
                    ? (isDark ? colors.primary : AppColors.success)
                    : (isDark ? colors.secondary : AppColors.orange),
              ),
              _buildMetadataItem(
                context,
                Icons.verified_user_rounded,
                'Level/Class',
                'All Levels',
                isDark ? colors.secondary.withValues(alpha: 0.15) : AppColors.yellowSoft,
                isDark ? colors.secondary : AppColors.orange,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Color bgIconColor,
    Color iconColor,
  ) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: bgIconColor,
            borderRadius: BorderRadius.circular(AppRadius.small),
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 1),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: colors.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 4. Course Progress Card
class CourseProgressCard extends StatelessWidget {
  final int completed;
  final int total;

  const CourseProgressCard({
    required this.completed,
    required this.total,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final double percent = total > 0 ? (completed / total).clamp(0.0, 1.0) : 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: colors.primaryContainer, width: 1),
      ),
      child: Row(
        children: [
          // Circular Progress Indicator Stack
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 56,
                width: 56,
                child: CircularProgressIndicator(
                  value: percent,
                  strokeWidth: 5,
                  backgroundColor: colors.surface,
                  valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
                ),
              ),
              Text(
                '${(percent * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: colors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Course Progress',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: colors.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$completed of $total lessons completed',
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          // Small Trophy Icon/Illustration
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colors.surface,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.emoji_events_rounded,
              color: AppColors.orange,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}

/// 5. Lesson Tile
class LessonTile extends StatelessWidget {
  final Lesson lesson;
  final bool isCompleted;
  final bool isActive;
  final bool isLocked;
  final VoidCallback onTap;

  const LessonTile({
    required this.lesson,
    required this.isCompleted,
    required this.isActive,
    required this.isLocked,
    required this.onTap,
    super.key,
  });

  Color _getThumbnailBg(BuildContext context, int orderIndex) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color baseColor;
    switch (orderIndex % 4) {
      case 0:
        baseColor = AppColors.lavenderSoft;
        break;
      case 1:
        baseColor = AppColors.blueSoft;
        break;
      case 2:
        baseColor = AppColors.greenSoft;
        break;
      case 3:
      default:
        baseColor = AppColors.yellowSoft;
        break;
    }
    return isDark ? baseColor.withValues(alpha: 0.15) : baseColor;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final bgTh = _getThumbnailBg(context, lesson.orderIndex);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? colors.primaryContainer.withValues(alpha: 0.2) : colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(
          color: isActive ? colors.primary : colors.outlineVariant,
          width: isActive ? 1.5 : 1.0,
        ),
        boxShadow: isActive ? AppTheme.miniShadow : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(AppSpacing.sm),
        onTap: onTap,
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: bgTh,
            borderRadius: BorderRadius.circular(AppRadius.small),
          ),
          alignment: Alignment.center,
          child: Icon(
            isLocked
                ? Icons.lock_rounded
                : (isActive ? Icons.pause_rounded : Icons.play_arrow_rounded),
            color: isActive ? colors.primary : colors.onSurfaceVariant,
            size: 24,
          ),
        ),
        title: Row(
          children: [
            Text(
              '${lesson.orderIndex + 1}. ',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isActive ? colors.primary : colors.onSurface,
              ),
            ),
            Expanded(
              child: Text(
                lesson.title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isActive ? colors.primary : colors.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              lesson.isPreview ? 'Free Preview • Pre-recorded' : 'Full Lesson • Pre-recorded',
              style: TextStyle(
                fontSize: 12,
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        trailing: _buildStatusWidget(context),
      ),
    );
  }

  Widget? _buildStatusWidget(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    if (isLocked) {
      return Icon(
        Icons.lock_outline_rounded,
        color: colors.onSurfaceVariant,
        size: 20,
      );
    }
    if (isCompleted) {
      return const Icon(
        Icons.check_circle_rounded,
        color: AppColors.success,
        size: 20,
      );
    }
    if (isActive) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.live.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'ACTIVE',
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.bold,
                color: AppColors.live,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.volume_up_rounded,
            color: colors.primary,
            size: 20,
          ),
        ],
      );
    }
    return Icon(
      Icons.play_circle_outline_rounded,
      color: colors.primary,
      size: 20,
    );
  }
}

/// 6. Review Tile
class ReviewTile extends StatelessWidget {
  final String name;
  final double rating;
  final String date;
  final String text;

  const ReviewTile({
    required this.name,
    required this.rating,
    required this.date,
    required this.text,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 6),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: colors.outlineVariant, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Mock Avatar
              Container(
                height: 36,
                width: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.primaryContainer,
                ),
                alignment: Alignment.center,
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : 'U',
                  style: TextStyle(
                    color: colors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colors.onSurface,
                        fontSize: 13,
                      ),
                    ),
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < rating.floor()
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          color: AppColors.orange,
                          size: 14,
                        );
                      }),
                    ),
                  ],
                ),
              ),
              Text(
                date,
                style: TextStyle(
                  fontSize: 11,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: colors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

/// 7. Class Detail Loading View
class ClassDetailLoadingView extends StatelessWidget {
  const ClassDetailLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
        ),
      ),
    );
  }
}

/// 8. Class Detail Error View
class ClassDetailErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const ClassDetailErrorView({
    required this.error,
    required this.onRetry,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
              const SizedBox(height: AppSpacing.md),
              Text(
                error,
                style: TextStyle(color: colors.onSurface, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              ElevatedButton(
                onPressed: onRetry,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 9. Class Detail Empty View
class ClassDetailEmptyView extends StatelessWidget {
  const ClassDetailEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_rounded, size: 48, color: colors.onSurfaceVariant),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Course details not found.',
              style: TextStyle(color: colors.onSurfaceVariant, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

/// 10. Class Detail Offline Banner
class ClassDetailOfflineBanner extends StatelessWidget {
  const ClassDetailOfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.orange,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: const Row(
        children: [
          Icon(Icons.wifi_off_rounded, color: Colors.white, size: 18),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Offline mode: showing cached details.',
              style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
