import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';
import '../../../../features/live_class/data/models/live_class.dart';

/// TodaysScheduleSection — horizontal list of schedule cards showing
/// real LiveClass data from LiveClassController.
class TodaysScheduleSection extends StatelessWidget {
  final List<LiveClass> classes;
  final VoidCallback onViewCalendar;
  final void Function(LiveClass) onManage;
  final void Function(LiveClass) onStartClass;

  const TodaysScheduleSection({
    super.key,
    required this.classes,
    required this.onViewCalendar,
    required this.onManage,
    required this.onStartClass,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    // Show today's and upcoming classes
    final items = classes.where((c) {
      return c.scheduledStartTime
          .isAfter(now.subtract(const Duration(hours: 2)));
    }).toList()
      ..sort((a, b) => a.scheduledStartTime.compareTo(b.scheduledStartTime));

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : AppColors.navy;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section header ─────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
          child: Row(
            children: [
              Text(
                "Today's Schedule",
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: titleColor),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onViewCalendar,
                child: Row(
                  children: [
                    Text('View Calendar',
                        style: TextStyle(
                            fontSize: 13,
                            color: primaryColor,
                            fontWeight: FontWeight.w600)),
                    Icon(Icons.chevron_right_rounded,
                        size: 16, color: primaryColor),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ── Cards ──────────────────────────────────────────────────────────
        if (items.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _EmptySchedule(),
          )
        else
          SizedBox(
            height: 150,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) => ScheduleCard(
                liveClass: items[i],
                onManage: () => onManage(items[i]),
                onStartClass: () => onStartClass(items[i]),
              ),
            ),
          ),
      ],
    );
  }
}

/// ScheduleCard — a single class card in the horizontal schedule list.
class ScheduleCard extends StatelessWidget {
  final LiveClass liveClass;
  final VoidCallback onManage;
  final VoidCallback onStartClass;

  const ScheduleCard({
    super.key,
    required this.liveClass,
    required this.onManage,
    required this.onStartClass,
  });

  static String _fmt(DateTime dt) {
    final h = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final m = dt.minute.toString().padLeft(2, '0');
    final p = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $p';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBgColor = isDark ? const Color(0xFF181B23) : Colors.white;
    final borderColor = isDark ? const Color(0xFF303542) : AppColors.border;
    final titleColor = isDark ? Colors.white : AppColors.navy;
    final primaryColor = Theme.of(context).colorScheme.primary;

    final isLive = liveClass.status == 'live';
    final timeStr =
        '${_fmt(liveClass.scheduledStartTime)} – ${_fmt(liveClass.scheduledEndTime)}';

    return Semantics(
      label: '${liveClass.title}, $timeStr',
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardBgColor,
          borderRadius: BorderRadius.circular(AppRadius.medium),
          border: Border(
            left: BorderSide(
              color: isLive ? AppColors.error : primaryColor,
              width: 3.5,
            ),
            top: BorderSide(color: borderColor),
            right: BorderSide(color: borderColor),
            bottom: BorderSide(color: borderColor),
          ),
          boxShadow: isDark ? null : AppTheme.miniShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time + live badge
            Row(
              children: [
                Text(
                  timeStr,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isLive ? AppColors.error : primaryColor,
                  ),
                ),
                if (isLive) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('LIVE',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 6),
            // Title
            Text(
              liveClass.title,
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w700, color: titleColor),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.people_outline_rounded,
                    size: 12, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  liveClass.facultyName ?? 'Faculty',
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            const Spacer(),
            // Action button
            isLive
                ? SizedBox(
                    height: 30,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onStartClass,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        textStyle: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      child: const Text('Join Live',
                          style: TextStyle(color: Colors.white, fontSize: 12)),
                    ),
                  )
                : SizedBox(
                    height: 30,
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: onManage,
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        side: BorderSide(color: primaryColor),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Start Class',
                              style: TextStyle(
                                  color: primaryColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold)),
                          Icon(Icons.play_arrow_rounded,
                              size: 14, color: primaryColor),
                        ],
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class _EmptySchedule extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBgColor = isDark ? const Color(0xFF181B23) : Colors.white;
    final borderColor = isDark ? const Color(0xFF303542) : AppColors.border;
    final textColor = isDark ? Colors.white : AppColors.navy;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          const Icon(Icons.event_available_rounded,
              color: AppColors.success, size: 32),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('No classes scheduled today',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: textColor,
                        fontSize: 14)),
                const Text('You\'re all clear — enjoy your day!',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
