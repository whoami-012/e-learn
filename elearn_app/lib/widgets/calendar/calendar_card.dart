import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Data class representing a cell in the calendar grid.
class CalendarDayCell {
  final DateTime date;
  final bool isCurrentMonth;
  final bool isToday;

  const CalendarDayCell({
    required this.date,
    required this.isCurrentMonth,
    required this.isToday,
  });
}

/// A premium, rounded white card containing month calendar grid components.
class MonthCalendarCard extends StatelessWidget {
  final DateTime displayedMonth;
  final DateTime selectedDate;
  final Set<DateTime> eventDates;
  final ValueChanged<DateTime> onMonthChanged;
  final ValueChanged<DateTime> onDateSelected;

  const MonthCalendarCard({
    super.key,
    required this.displayedMonth,
    required this.selectedDate,
    required this.eventDates,
    required this.onMonthChanged,
    required this.onDateSelected,
  });

  List<CalendarDayCell> _generateCalendarCells() {
    final year = displayedMonth.year;
    final month = displayedMonth.month;

    // First day of displayed month
    final firstDay = DateTime(year, month, 1);
    // Sunday-start offset (0 for Sunday, 1 for Monday, ..., 6 for Saturday)
    final offset = firstDay.weekday % 7;

    final daysInMonth = DateTime(year, month + 1, 0).day;
    final prevMonthDays = DateTime(year, month, 0).day;

    final List<CalendarDayCell> cells = [];
    final today = DateTime.now();

    // 1. Previous month days (fillers)
    for (int i = offset - 1; i >= 0; i--) {
      final day = prevMonthDays - i;
      final prevMonth = month == 1 ? 12 : month - 1;
      final prevYear = month == 1 ? year - 1 : year;
      final date = DateTime(prevYear, prevMonth, day);
      cells.add(CalendarDayCell(
        date: date,
        isCurrentMonth: false,
        isToday: date.year == today.year && date.month == today.month && date.day == today.day,
      ));
    }

    // 2. Current month days
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(year, month, day);
      cells.add(CalendarDayCell(
        date: date,
        isCurrentMonth: true,
        isToday: date.year == today.year && date.month == today.month && date.day == today.day,
      ));
    }

    // 3. Next month days (fillers to complete 42 cells grid = 6 rows)
    final remainingCells = 42 - cells.length;
    for (int day = 1; day <= remainingCells; day++) {
      final nextMonth = month == 12 ? 1 : month + 1;
      final nextYear = month == 12 ? year + 1 : year;
      final date = DateTime(nextYear, nextMonth, day);
      cells.add(CalendarDayCell(
        date: date,
        isCurrentMonth: false,
        isToday: date.year == today.year && date.month == today.month && date.day == today.day,
      ));
    }

    return cells;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _hasEvent(DateTime date) {
    return eventDates.any((d) => _isSameDay(d, date));
  }

  @override
  Widget build(BuildContext context) {
    final cells = _generateCalendarCells();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF181B23) : Colors.white,
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 22,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(
            color: isDark ? const Color(0xFF303542) : const Color(0xFFE9EBF2).withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Month switcher header
            CalendarMonthHeader(
              displayedMonth: displayedMonth,
              onMonthChanged: onMonthChanged,
            ),
            const SizedBox(height: 16),
            // Weekday labels
            const CalendarWeekdayRow(),
            const SizedBox(height: 10),
            // Grid of 42 dates
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 6,
                crossAxisSpacing: 6,
                childAspectRatio: 1.0,
              ),
              itemCount: 42,
              itemBuilder: (context, index) {
                final cell = cells[index];
                final isSelected = _isSameDay(cell.date, selectedDate);
                final hasEvent = _hasEvent(cell.date);

                return CalendarDateCell(
                  cell: cell,
                  isSelected: isSelected,
                  hasEvent: hasEvent,
                  onTap: () => onDateSelected(cell.date),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Month Navigation controls at the top of the calendar card.
class CalendarMonthHeader extends StatelessWidget {
  final DateTime displayedMonth;
  final ValueChanged<DateTime> onMonthChanged;

  const CalendarMonthHeader({
    super.key,
    required this.displayedMonth,
    required this.onMonthChanged,
  });

  static const _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  @override
  Widget build(BuildContext context) {
    final title = '${_months[displayedMonth.month - 1]} ${displayedMonth.year}';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Prev Month Button
        IconButton(
          onPressed: () {
            final prevMonthDate = DateTime(
              displayedMonth.month == 1 ? displayedMonth.year - 1 : displayedMonth.year,
              displayedMonth.month == 1 ? 12 : displayedMonth.month - 1,
              1,
            );
            onMonthChanged(prevMonthDate);
          },
          icon: Icon(
            Icons.chevron_left_rounded,
            color: isDark ? Colors.white : const Color(0xFF101936),
            size: 26,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
          style: IconButton.styleFrom(
            highlightColor: isDark ? theme.colorScheme.primary.withValues(alpha: 0.2) : AppColors.primarySoft.withValues(alpha: 0.4),
          ),
        ),

        // Month Title Text
        Text(
          title,
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF101936),
            fontFamily: 'Plus Jakarta Sans',
          ),
        ),

        // Next Month Button
        IconButton(
          onPressed: () {
            final nextMonthDate = DateTime(
              displayedMonth.month == 12 ? displayedMonth.year + 1 : displayedMonth.year,
              displayedMonth.month == 12 ? 1 : displayedMonth.month + 1,
              1,
            );
            onMonthChanged(nextMonthDate);
          },
          icon: Icon(
            Icons.chevron_right_rounded,
            color: isDark ? Colors.white : const Color(0xFF101936),
            size: 26,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
          style: IconButton.styleFrom(
            highlightColor: isDark ? theme.colorScheme.primary.withValues(alpha: 0.2) : AppColors.primarySoft.withValues(alpha: 0.4),
          ),
        ),
      ],
    );
  }
}

/// Upper-case weekday row.
class CalendarWeekdayRow extends StatelessWidget {
  const CalendarWeekdayRow({super.key});

  @override
  Widget build(BuildContext context) {
    final days = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: days.map((day) {
        return Expanded(
          child: Center(
            child: Text(
              day,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? const Color(0xFFADB4C4) : const Color(0xFF8E95A5),
                fontFamily: 'Plus Jakarta Sans',
                letterSpacing: 0.5,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// An individual cell in the calendar grid.
class CalendarDateCell extends StatelessWidget {
  final CalendarDayCell cell;
  final bool isSelected;
  final bool hasEvent;
  final VoidCallback onTap;

  const CalendarDateCell({
    super.key,
    required this.cell,
    required this.isSelected,
    required this.hasEvent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool enabled = cell.isCurrentMonth;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    final semanticLabel = '${enabled ? "" : "Outside Month, "}'
        '${MaterialLocalizations.of(context).formatFullDate(cell.date)}'
        '${cell.isToday ? ", Today" : ""}'
        '${isSelected ? ", Selected" : ""}'
        '${hasEvent ? ", contains scheduled events" : ""}. Double tap to select.';

    // Color definitions
    Color textColor;
    if (isSelected) {
      textColor = Colors.white;
    } else if (cell.isToday) {
      textColor = theme.colorScheme.primary;
    } else if (enabled) {
      textColor = isDark ? Colors.white : const Color(0xFF101936);
    } else {
      textColor = isDark ? const Color(0xFFADB4C4).withValues(alpha: 0.4) : const Color(0xFF8E95A5).withValues(alpha: 0.5);
    }

    return Semantics(
      label: semanticLabel,
      selected: isSelected,
      button: true,
      onTap: onTap,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeInOut,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSelected
                ? theme.colorScheme.primary
                : (cell.isToday ? (isDark ? theme.colorScheme.primary.withValues(alpha: 0.25) : AppColors.primarySoft.withValues(alpha: 0.5)) : Colors.transparent),
            border: (cell.isToday && !isSelected)
                ? Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.5), width: 1.5)
                : null,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Day Number
              Text(
                '${cell.date.day}',
                style: TextStyle(
                  fontSize: 15.5,
                  fontWeight: (cell.isToday || isSelected) ? FontWeight.bold : FontWeight.w600,
                  color: textColor,
                  fontFamily: 'Plus Jakarta Sans',
                ),
              ),
              // Event indicator dot
              if (hasEvent)
                Positioned(
                  bottom: 5,
                  child: CalendarEventIndicator(
                    color: isSelected ? Colors.white : theme.colorScheme.primary,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small event indicator dot.
class CalendarEventIndicator extends StatelessWidget {
  final Color color;

  const CalendarEventIndicator({
    super.key,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 5,
      height: 5,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
