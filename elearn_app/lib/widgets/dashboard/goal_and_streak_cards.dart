import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class WeeklyGoalCard extends StatelessWidget {
  final int completed;
  final int target;

  const WeeklyGoalCard({
    super.key,
    required this.completed,
    required this.target,
  });

  @override
  Widget build(BuildContext context) {
    final progress = target > 0 ? completed / target : 0.0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16.0),
      height: 150,
      decoration: BoxDecoration(
        gradient: isDark
            ? const LinearGradient(
                colors: [
                  Color(0xFF064E3B),
                  Color(0xFF022C22),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : const LinearGradient(
                colors: [
                  AppColors.greenSoft,
                  Color(0xFFF2FDF9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(22.0),
        border: isDark ? Border.all(color: const Color(0xFF303542)) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF047857) : Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Icon(
                  Icons.track_changes_rounded,
                  color: isDark ? Colors.white : AppColors.success,
                  size: 20,
                ),
              ),
              const SizedBox(width: 8.0),
              Text(
                'Weekly Goal',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? const Color(0xFFADB4C4) : AppColors.textSecondary,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$completed / $target',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? const Color(0xFF34D399) : AppColors.success,
                ),
              ),
              const SizedBox(height: 2.0),
              Text(
                'Lessons completed',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isDark ? const Color(0xFFADB4C4) : AppColors.textSecondary,
                ),
              ),
            ],
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(3.0),
            child: SizedBox(
              height: 5.0,
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: isDark ? const Color(0xFF065F46) : Colors.white.withOpacity(0.6),
                valueColor: AlwaysStoppedAnimation<Color>(
                  isDark ? const Color(0xFF34D399) : AppColors.success,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LearningStreakCard extends StatelessWidget {
  final int streakDays;

  const LearningStreakCard({
    super.key,
    required this.streakDays,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16.0),
      height: 150,
      decoration: BoxDecoration(
        gradient: isDark
            ? const LinearGradient(
                colors: [
                  Color(0xFF7C2D12),
                  Color(0xFF451A03),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : const LinearGradient(
                colors: [
                  AppColors.orangeSoft,
                  Color(0xFFFFF8F2),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(22.0),
        border: isDark ? Border.all(color: const Color(0xFF303542)) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFFC2410C) : Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Icon(
                  Icons.local_fire_department_rounded,
                  color: isDark ? Colors.white : AppColors.orange,
                  size: 20,
                ),
              ),
              const SizedBox(width: 8.0),
              Text(
                'Streak',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? const Color(0xFFADB4C4) : AppColors.textSecondary,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$streakDays Days',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? const Color(0xFFFB923C) : AppColors.orange,
                ),
              ),
              const SizedBox(height: 2.0),
              Text(
                'Keep it up!',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isDark ? const Color(0xFFADB4C4) : AppColors.textSecondary,
                ),
              ),
            ],
          ),
          // Subtle decoration spacer/element to mirror goal card structure
          const SizedBox(height: 5.0),
        ],
      ),
    );
  }
}
