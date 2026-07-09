import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../../../../services/auth_service.dart';

/// DashboardHeader — top bar showing avatar, time-based greeting,
/// role subtitle, notification badge, and settings icon.
///
/// All data comes from [UserProfile]; no hardcoding.
class DashboardHeader extends StatelessWidget {
  final UserProfile user;
  final int unreadNotifications;
  final VoidCallback onNotificationTap;
  final VoidCallback onSettingsTap;

  const DashboardHeader({
    super.key,
    required this.user,
    required this.unreadNotifications,
    required this.onNotificationTap,
    required this.onSettingsTap,
  });

  // ── Time-based greeting ────────────────────────────────────────────────────
  static String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  // ── Role label ─────────────────────────────────────────────────────────────
  static String _roleLabel(String role) {
    switch (role.toLowerCase()) {
      case 'faculty':
        return 'Faculty Member';
      case 'admin':
        return 'Administrator';
      default:
        return 'Teacher';
    }
  }

  @override
  Widget build(BuildContext context) {
    final initials = user.name
        .trim()
        .split(' ')
        .take(2)
        .map((w) => w.isNotEmpty ? w[0] : '')
        .join()
        .toUpperCase();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimaryColor = isDark ? Colors.white : AppColors.navy;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          // ── Avatar ──────────────────────────────────────────────────────
          _DashboardAvatar(
            avatarUrl: user.profileImage,
            initials: initials,
          ),
          const SizedBox(width: 12),

          // ── Greeting + name + role ───────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${_greeting()}, ${user.name.split(' ').first}',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: textPrimaryColor,
                    letterSpacing: -0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  _roleLabel(user.role),
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // ── Notification button ──────────────────────────────────────────
          Semantics(
            label: unreadNotifications > 0
                ? '$unreadNotifications unread notifications'
                : 'Notifications',
            button: true,
            child: _IconButton(
              icon: Icons.notifications_outlined,
              onTap: onNotificationTap,
              badge: unreadNotifications > 0,
            ),
          ),
          const SizedBox(width: 8),

          // ── Settings button ──────────────────────────────────────────────
          Semantics(
            label: 'Settings',
            button: true,
            child: _IconButton(
              icon: Icons.settings_outlined,
              onTap: onSettingsTap,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Avatar ────────────────────────────────────────────────────────────────────

class _DashboardAvatar extends StatelessWidget {
  final String? avatarUrl;
  final String initials;

  const _DashboardAvatar({this.avatarUrl, required this.initials});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.18),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipOval(
        child: avatarUrl != null && avatarUrl!.isNotEmpty
            ? Image.network(
                avatarUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    _InitialsFallback(initials: initials),
              )
            : _InitialsFallback(initials: initials),
      ),
    );
  }
}

class _InitialsFallback extends StatelessWidget {
  final String initials;
  const _InitialsFallback({required this.initials});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6C45D8), Color(0xFF4D2FA4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        initials.isNotEmpty ? initials : '?',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}

// ── Icon button with optional badge ──────────────────────────────────────────

class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool badge;

  const _IconButton(
      {required this.icon, required this.onTap, this.badge = false});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF181B23) : Colors.white;
    final borderColor = isDark ? const Color(0xFF303542) : AppColors.border;
    final iconColor = isDark ? Colors.white : AppColors.navy;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
              boxShadow: isDark ? null : AppTheme.miniShadow,
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 20, color: iconColor),
          ),
          if (badge)
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                  border: Border.all(color: bgColor, width: 1.5),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
