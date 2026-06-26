import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class TeacherHeader extends StatelessWidget {
  final String userName;
  final VoidCallback onNotificationTap;
  final VoidCallback onProfileTap;

  const TeacherHeader({
    super.key,
    required this.userName,
    required this.onNotificationTap,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ── Greeting & Avatar ──────────────────────────────────────────
          Expanded(
            child: Row(
              children: [
                GestureDetector(
                  onTap: onProfileTap,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: AppTheme.avatarGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      userName.isNotEmpty ? userName[0].toUpperCase() : 'T',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm + 4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Hello, $userName 👋',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Text(
                        'Good Morning',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Action Icons ───────────────────────────────────────────────
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Language Switcher
              _HeaderActionButton(
                icon: Icons.public_rounded,
                label: 'EN',
                onTap: () {},
              ),
              const SizedBox(width: AppSpacing.sm),
              // Notifications
              Stack(
                children: [
                  _HeaderActionButton(
                    icon: Icons.notifications_none_rounded,
                    onTap: onNotificationTap,
                  ),
                  Positioned(
                    top: 2,
                    right: 2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.background, width: 1.5),
                      ),
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
}

class _HeaderActionButton extends StatelessWidget {
  final IconData icon;
  final String? label;
  final VoidCallback onTap;

  const _HeaderActionButton({
    required this.icon,
    this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: label != null ? 12 : 10, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(color: AppColors.border),
          boxShadow: AppTheme.miniShadow,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppColors.textSecondary),
            if (label != null) ...[
              const SizedBox(width: 4),
              Text(
                label!,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
