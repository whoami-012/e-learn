import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Clean modern top header for the Calendar view.
class CalendarScreenHeader extends StatelessWidget {
  final VoidCallback? onActionTap;
  final IconData? actionIcon;

  const CalendarScreenHeader({
    super.key,
    this.onActionTap,
    this.actionIcon,
  });

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.canPop(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Circular back button if not a root navigation tab
          if (canPop)
            GestureDetector(
              onTap: () => Navigator.maybePop(context),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF181B23) : Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: isDark ? const Color(0xFF303542) : const Color(0xFFE9EBF2).withValues(alpha: 0.6),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 16,
                    color: isDark ? Colors.white : const Color(0xFF101936),
                  ),
                ),
              ),
            )
          else
            const SizedBox(width: 48),

          // Center: Title
          Text(
            'Class Calendar',
            style: TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF101936),
              fontFamily: 'Plus Jakarta Sans',
            ),
          ),

          // Right: Calendar action button (e.g. datepicker or info)
          GestureDetector(
            onTap: onActionTap,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF181B23) : Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: isDark ? const Color(0xFF303542) : const Color(0xFFE9EBF2).withValues(alpha: 0.6),
                  width: 1,
                ),
              ),
              child: Center(
                child: Icon(
                  actionIcon ?? Icons.calendar_month_outlined,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Header row for displaying the selected day and the Today toggle button.
class SelectedDateHeader extends StatelessWidget {
  final String dateLabel;
  final VoidCallback onTodayTap;

  const SelectedDateHeader({
    super.key,
    required this.dateLabel,
    required this.onTodayTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Selected date text
          Expanded(
            child: Text(
              dateLabel,
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF101936),
                fontFamily: 'Plus Jakarta Sans',
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Today button
          TodayButton(onTap: onTodayTap),
        ],
      ),
    );
  }
}

/// A pill-shaped Today button.
class TodayButton extends StatelessWidget {
  final VoidCallback onTap;

  const TodayButton({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return Material(
      color: isDark ? theme.colorScheme.primaryContainer : AppColors.primarySoft,
      borderRadius: BorderRadius.circular(99),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(99),
        child: Container(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          alignment: Alignment.center,
          child: Text(
            'Today',
            style: TextStyle(
              color: isDark ? theme.colorScheme.onPrimaryContainer : AppColors.primary,
              fontSize: 13.5,
              fontWeight: FontWeight.bold,
              fontFamily: 'Plus Jakarta Sans',
            ),
          ),
        ),
      ),
    );
  }
}

/// A compact, red "Live" badge for current running events.
class LiveEventBadge extends StatelessWidget {
  const LiveEventBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.5),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF222631) : Colors.white,
        borderRadius: BorderRadius.circular(99),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withValues(alpha: isDark ? 0.2 : 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'Live',
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF101936),
              fontSize: 11,
              fontWeight: FontWeight.bold,
              fontFamily: 'Plus Jakarta Sans',
            ),
          ),
        ],
      ),
    );
  }
}

/// Fixed width time display column for calendar schedule items.
class EventTimeColumn extends StatelessWidget {
  final String startTime;
  final String endTime;

  const EventTimeColumn({
    super.key,
    required this.startTime,
    required this.endTime,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: 75,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            startTime,
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF101936),
              fontFamily: 'Plus Jakarta Sans',
            ),
          ),
          const SizedBox(height: 3),
          Text(
            '– $endTime',
            style: TextStyle(
              fontSize: 12.5,
              color: isDark ? const Color(0xFFADB4C4) : const Color(0xFF8E95A5),
              fontWeight: FontWeight.w500,
              fontFamily: 'Plus Jakarta Sans',
            ),
          ),
        ],
      ),
    );
  }
}

/// Small subject specific avatar container with customized graphics.
class EventSubjectIcon extends StatelessWidget {
  final String subject;
  final Color tintColor;

  const EventSubjectIcon({
    super.key,
    required this.subject,
    required this.tintColor,
  });

  @override
  Widget build(BuildContext context) {
    final lower = subject.toLowerCase();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    IconData icon;

    if (lower.contains('biology')) {
      icon = Icons.biotech_rounded;
    } else if (lower.contains('chemistry')) {
      icon = Icons.science_rounded;
    } else if (lower.contains('physics')) {
      icon = Icons.rocket_launch_rounded;
    } else if (lower.contains('exam') || lower.contains('test')) {
      icon = Icons.assignment_rounded;
    } else {
      icon = Icons.school_rounded;
    }

    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.12) : Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Icon(
          icon,
          color: tintColor,
          size: 26,
        ),
      ),
    );
  }
}
