import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class CircularProgressRing extends StatelessWidget {
  final double progress;
  final String text;

  const CircularProgressRing({
    super.key,
    required this.progress,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 54,
          height: 54,
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: 5.5,
            backgroundColor: isDark ? const Color(0xFF3B2D5C) : AppColors.primarySoft,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            strokeCap: StrokeCap.round,
          ),
        ),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.navy,
          ),
        ),
      ],
    );
  }
}

class ContinueLearningCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final int completedLessons;
  final int totalLessons;
  final VoidCallback onResumeTap;

  const ContinueLearningCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.completedLessons,
    required this.totalLessons,
    required this.onResumeTap,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalLessons > 0 ? completedLessons / totalLessons : 0.0;
    final progressPercentage = '${(progress * 100).toInt()}%';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onResumeTap,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF181B23) : AppColors.surface,
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: isDark ? null : AppTheme.softShadow,
          border: isDark ? Border.all(color: const Color(0xFF303542)) : null,
        ),
        child: Row(
          children: [
            // Circular progress ring
            CircularProgressRing(
              progress: progress,
              text: progressPercentage,
            ),
            const SizedBox(width: 16.0),
            // Center content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.navy,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark ? const Color(0xFFADB4C4) : AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(3.0),
                          child: SizedBox(
                            height: 6.0,
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: isDark ? const Color(0xFF3B2D5C) : AppColors.primarySoft,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12.0),
                      Text(
                        '$completedLessons / $totalLessons Lessons',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isDark ? const Color(0xFFADB4C4) : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12.0),
            // Right play button
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onResumeTap,
                borderRadius: BorderRadius.circular(14.0),
                child: Ink(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF3B2D5C) : AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(14.0),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.play_arrow_rounded,
                      color: isDark ? const Color(0xFFB69AF4) : AppColors.primary,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
