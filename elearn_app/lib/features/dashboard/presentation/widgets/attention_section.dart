import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';

/// AttentionSection — horizontal scrolling row of attention cards.
/// Data comes from real provider counts; cards are hidden when count == 0.
class AttentionSection extends StatelessWidget {
  final int courseCount; // proxy for "assignments to review"
  final int unreadMessages; // student questions / messages
  final int liveClassCount; // upcoming deadlines proxy

  final VoidCallback onAssignmentsTap;
  final VoidCallback onMessagesTap;
  final VoidCallback onDeadlinesTap;

  const AttentionSection({
    super.key,
    required this.courseCount,
    required this.unreadMessages,
    required this.liveClassCount,
    required this.onAssignmentsTap,
    required this.onMessagesTap,
    required this.onDeadlinesTap,
  });

  @override
  Widget build(BuildContext context) {
    final cards = <_Attention>[
      if (courseCount > 0)
        _Attention(
          id: 'assignments',
          icon: Icons.assignment_outlined,
          iconBg: AppColors.orangeSoft,
          iconColor: AppColors.orange,
          count: courseCount,
          label: 'Courses\nto Manage',
          onTap: onAssignmentsTap,
        ),
      if (unreadMessages > 0)
        _Attention(
          id: 'messages',
          icon: Icons.chat_bubble_outline_rounded,
          iconBg: AppColors.primarySoft,
          iconColor: AppColors.primary,
          count: unreadMessages,
          label: 'Unread\nMessages',
          onTap: onMessagesTap,
        ),
      if (liveClassCount > 0)
        _Attention(
          id: 'live',
          icon: Icons.access_time_rounded,
          iconBg: AppColors.pastelPink,
          iconColor: AppColors.error,
          count: liveClassCount,
          label: 'Upcoming\nClasses',
          onTap: onDeadlinesTap,
        ),
    ];

    if (cards.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : AppColors.navy;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
          child: Text(
            "Needs Your Attention",
            style: TextStyle(
                fontSize: 17, fontWeight: FontWeight.w800, color: titleColor),
          ),
        ),
        SizedBox(
          height: 104,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: cards.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) => _AttentionCard(attention: cards[i]),
          ),
        ),
      ],
    );
  }
}

class _Attention {
  final String id;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final int count;
  final String label;
  final VoidCallback onTap;

  const _Attention({
    required this.id,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.count,
    required this.label,
    required this.onTap,
  });
}

/// AttentionCard — individual card with count + label + chevron.
class _AttentionCard extends StatelessWidget {
  final _Attention attention;
  const _AttentionCard({required this.attention});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBgColor = isDark ? const Color(0xFF181B23) : Colors.white;
    final borderColor = isDark ? const Color(0xFF303542) : AppColors.border;
    final valueColor = isDark ? Colors.white : AppColors.navy;
    final iconBgColor =
        isDark ? attention.iconColor.withValues(alpha: 0.15) : attention.iconBg;

    return Semantics(
      label: '${attention.count} ${attention.label.replaceAll('\n', ' ')}',
      button: true,
      child: GestureDetector(
        onTap: attention.onTap,
        child: Container(
          width: 140,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cardBgColor,
            borderRadius: BorderRadius.circular(AppRadius.medium),
            border: Border.all(color: borderColor),
            boxShadow: isDark ? null : AppTheme.miniShadow,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(10)),
                child:
                    Icon(attention.icon, color: attention.iconColor, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${attention.count}',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: valueColor),
                    ),
                    Text(
                      attention.label,
                      style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                          height: 1.3),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  size: 16, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
