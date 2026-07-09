import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';

/// DashboardQuickActions — four compact action tiles matching the prototype.
/// Each action only shows when its route/callback is supplied.
class DashboardQuickActions extends StatelessWidget {
  final VoidCallback onLiveClass;
  final VoidCallback onNewCourse;
  final VoidCallback onUpload;

  const DashboardQuickActions({
    super.key,
    required this.onLiveClass,
    required this.onNewCourse,
    required this.onUpload,
  });

  @override
  Widget build(BuildContext context) {
    final actions = [
      _Action(
        id: 'live_class',
        icon: Icons.video_camera_front_rounded,
        label: 'Live Class',
        iconColor: AppColors.orange,
        bgColor: AppColors.orangeSoft,
        onTap: onLiveClass,
      ),
      _Action(
        id: 'new_course',
        icon: Icons.add_circle_outline_rounded,
        label: 'New Course',
        iconColor: AppColors.primary,
        bgColor: AppColors.primarySoft,
        onTap: onNewCourse,
      ),
      _Action(
        id: 'upload',
        icon: Icons.cloud_upload_outlined,
        label: 'Upload',
        iconColor: AppColors.blue,
        bgColor: AppColors.blueSoft,
        onTap: onUpload,
      ),
      _Action(
        id: 'announcement',
        icon: Icons.campaign_outlined,
        label: 'Announce',
        iconColor: const Color(0xFFB44FE8),
        bgColor: const Color(0xFFF5E6FF),
        onTap: null, // no announcement endpoint yet — hidden tap
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: actions
            .map((a) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: _QuickActionCard(action: a),
                  ),
                ))
            .toList(),
      ),
    );
  }
}

class _Action {
  final String id;
  final IconData icon;
  final String label;
  final Color iconColor;
  final Color bgColor;
  final VoidCallback? onTap;

  const _Action({
    required this.id,
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.bgColor,
    required this.onTap,
  });
}

class _QuickActionCard extends StatelessWidget {
  final _Action action;
  const _QuickActionCard({required this.action});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBgColor = isDark ? const Color(0xFF181B23) : Colors.white;
    final borderColor = isDark ? const Color(0xFF303542) : AppColors.border;
    final iconBgColor =
        isDark ? action.iconColor.withValues(alpha: 0.15) : action.bgColor;
    final textColor = action.onTap != null
        ? (isDark ? Colors.white : AppColors.navy)
        : AppColors.textSecondary;

    return Semantics(
      label: action.label,
      button: true,
      child: GestureDetector(
        onTap: action.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
          decoration: BoxDecoration(
            color: cardBgColor,
            borderRadius: BorderRadius.circular(AppRadius.medium),
            border: Border.all(color: borderColor),
            boxShadow: isDark ? null : AppTheme.miniShadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(action.icon, color: action.iconColor, size: 22),
              ),
              const SizedBox(height: 8),
              Text(
                action.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
