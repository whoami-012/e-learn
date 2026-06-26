import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class DashboardStat {
  final String label;
  final String value;
  final String change;
  final IconData icon;
  final LinearGradient gradient;
  final Color bgColor;
  final Color shadowColor;

  DashboardStat({
    required this.label,
    required this.value,
    required this.change,
    required this.icon,
    required this.gradient,
    required this.bgColor,
    required this.shadowColor,
  });
}

class AnalyticsCard extends StatelessWidget {
  final DashboardStat stat;

  const AnalyticsCard({super.key, required this.stat});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: AppColors.border),
        boxShadow: AppTheme.miniShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Icon Container
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  gradient: stat.gradient,
                  borderRadius: BorderRadius.circular(AppRadius.small),
                  boxShadow: [
                    BoxShadow(
                      color: stat.shadowColor.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(stat.icon, color: Colors.white, size: 18),
              ),
              // Percentage change chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.pastelMint,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.trending_up_rounded, size: 10, color: Colors.green),
                    const SizedBox(width: 2),
                    Text(
                      stat.change,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                stat.label,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                stat.value,
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
