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
    return Container(
      color: AppTheme.background,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ── Greeting & Avatar ──────────────────────────────────────────
          Row(
            children: [
              GestureDetector(
                onTap: onProfileTap,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF818CF8), Color(0xFFA78BFA)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF818CF8).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.person_rounded, color: Colors.white, size: 24),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, $userName 👋',
                    style: AppTheme.h3.copyWith(fontSize: 16),
                  ),
                  Text(
                    'Good Morning',
                    style: AppTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),

          // ── Action Icons ───────────────────────────────────────────────
          Row(
            children: [
              // Language Switcher
              _HeaderActionButton(
                icon: Icons.public_rounded,
                label: 'EN',
                onTap: () {},
              ),
              const SizedBox(width: 8),
              // Notifications
              Stack(
                children: [
                  _HeaderActionButton(
                    icon: Icons.notifications_none_rounded,
                    onTap: onNotificationTap,
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF87171),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.background, width: 2),
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
      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: label != null ? 12 : 8, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          border: Border.all(color: AppTheme.borderLight),
          boxShadow: AppTheme.miniShadow,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppTheme.textSecondary),
            if (label != null) ...[
              const SizedBox(width: 4),
              Text(
                label!,
                style: AppTheme.labelSmall.copyWith(color: AppTheme.textPrimary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
