import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../../../../features/live_class/data/models/live_class.dart';

/// TodaysOverviewCard — large white card showing:
///  • total courses (from provider)
///  • live/scheduled classes today (from LiveClassController)
///  • unread messages (from MessageProvider)
///  • next class time + title (from LiveClassController)
///
/// Each stat is real backend data; null/empty values show "–".
class TodaysOverviewCard extends StatelessWidget {
  final int courseCount;
  final List<LiveClass> liveClasses;
  final int unreadMessages;
  final VoidCallback? onNextClassTap;

  const TodaysOverviewCard({
    super.key,
    required this.courseCount,
    required this.liveClasses,
    required this.unreadMessages,
    this.onNextClassTap,
  });

  @override
  Widget build(BuildContext context) {
    // derive today's classes
    final now = DateTime.now();
    final todayClasses = liveClasses.where((c) {
      final d = c.scheduledStartTime;
      return d.year == now.year && d.month == now.month && d.day == now.day;
    }).toList()
      ..sort((a, b) => a.scheduledStartTime.compareTo(b.scheduledStartTime));

    final classesToday = todayClasses.length;
    final nextClass = todayClasses
        .where((c) => c.scheduledStartTime.isAfter(now))
        .firstOrNull;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBgColor = isDark ? const Color(0xFF181B23) : Colors.white;
    final borderColor = isDark ? const Color(0xFF303542) : AppColors.border;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: cardBgColor,
          borderRadius: BorderRadius.circular(AppRadius.medium),
          border: Border.all(color: borderColor),
          boxShadow: isDark ? null : AppTheme.softShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Stats row ──────────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _OverviewStat(
                    icon: Icons.calendar_today_rounded,
                    iconBg: AppColors.primarySoft,
                    iconColor: AppColors.primary,
                    value: '$classesToday',
                    label: 'Classes',
                    sub: 'Today',
                  ),
                ),
                _divider(context),
                Expanded(
                  child: _OverviewStat(
                    icon: Icons.assignment_outlined,
                    iconBg: AppColors.greenSoft,
                    iconColor: AppColors.success,
                    value: '$courseCount',
                    label: 'Courses',
                    sub: 'Active',
                  ),
                ),
                _divider(context),
                Expanded(
                  child: _OverviewStat(
                    icon: Icons.chat_bubble_outline_rounded,
                    iconBg: AppColors.blueSoft,
                    iconColor: AppColors.blue,
                    value: unreadMessages > 0 ? '$unreadMessages' : '–',
                    label: 'Messages',
                    sub: 'Unread',
                  ),
                ),
                _divider(context),
                // Next class stat (tappable)
                Expanded(
                  child: GestureDetector(
                    onTap: onNextClassTap,
                    child: _OverviewStat(
                      icon: Icons.access_time_rounded,
                      iconBg: AppColors.yellowSoft,
                      iconColor: AppColors.orange,
                      value: nextClass != null
                          ? _formatTime(nextClass.scheduledStartTime)
                          : '–',
                      label: 'Next Class',
                      sub: nextClass?.title.split(' ').take(2).join(' ') ??
                          'None today',
                      hasChevron: nextClass != null,
                    ),
                  ),
                ),
              ],
            ),

            // ── AI Insight banner ──────────────────────────────────────────
            if (courseCount > 0) ...[
              const SizedBox(height: 14),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.auto_awesome_rounded,
                      size: 16, color: primaryColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Insight: You have $courseCount active course${courseCount > 1 ? 's' : ''} this term. Keep it up!',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded,
                      size: 16, color: AppColors.textSecondary),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _divider(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 1,
      height: 52,
      color: isDark ? const Color(0xFF303542) : AppColors.border,
    );
  }

  static String _formatTime(DateTime dt) {
    final h = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final m = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $period';
  }
}

class _OverviewStat extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String value;
  final String label;
  final String sub;
  final bool hasChevron;

  const _OverviewStat({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.value,
    required this.label,
    required this.sub,
    this.hasChevron = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final valueColor = isDark ? Colors.white : AppColors.navy;
    final finalIconBg = isDark ? iconColor.withValues(alpha: 0.15) : iconBg;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
              color: finalIconBg, borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w800, color: valueColor),
        ),
        Text(label,
            style: const TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600)),
        Text(sub,
            style:
                const TextStyle(fontSize: 10, color: AppColors.textSecondary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
        if (hasChevron)
          Icon(Icons.chevron_right_rounded, size: 12, color: primaryColor),
      ],
    );
  }
}
