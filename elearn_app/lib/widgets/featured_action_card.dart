import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class FeaturedActionCard extends StatelessWidget {
  final String title;
  final int lessonsCount;
  final String duration;
  final double progress;
  final VoidCallback onPlayTap;

  const FeaturedActionCard({
    super.key,
    required this.title,
    required this.lessonsCount,
    required this.duration,
    required this.progress,
    required this.onPlayTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Container(
        height: 170,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.pastelPurple, AppColors.surface],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppRadius.medium),
          border: Border.all(color: AppColors.border),
          boxShadow: AppTheme.softShadow,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // ── Background Decoration ────────────────────────────────────
            Positioned(
              bottom: -20,
              right: -20,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primarySoft.withOpacity(0.3), AppColors.pastelPink.withOpacity(0.2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // ── Content ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Today's Task",
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              title,
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      // Play Button
                      GestureDetector(
                        onTap: onPlayTap,
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 28),
                        ),
                      ),
                    ],
                  ),

                  // Metadata Row
                  Row(
                    children: [
                      _MetaBadge(
                        label: '$lessonsCount',
                        suffix: 'lessons',
                        bgColor: AppColors.primarySoft,
                        textColor: AppColors.primary,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Row(
                        children: [
                          const Icon(Icons.access_time_rounded, size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            duration,
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Progress Bar
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Progress', style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold)),
                          Text(
                            '${(progress * 100).toInt()}%',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: double.infinity,
                        height: 6,
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: progress,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: AppTheme.primaryGradient,
                              borderRadius: BorderRadius.circular(AppRadius.pill),
                            ),
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

class _MetaBadge extends StatelessWidget {
  final String label;
  final String suffix;
  final Color bgColor;
  final Color textColor;

  const _MetaBadge({
    required this.label,
    required this.suffix,
    required this.bgColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textColor),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(suffix, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      ],
    );
  }
}
