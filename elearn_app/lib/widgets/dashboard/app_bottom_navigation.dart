import 'package:flutter/material.dart';

class AppBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    final items = [
      _NavItem(
          icon: Icons.home_outlined,
          activeIcon: Icons.home_rounded,
          label: 'Home'),
      _NavItem(
          icon: Icons.school_outlined,
          activeIcon: Icons.school_rounded,
          label: 'Courses'),
      _NavItem(
          icon: Icons.calendar_month_outlined,
          activeIcon: Icons.calendar_month_rounded,
          label: 'Calendar'),
      _NavItem(
          icon: Icons.chat_bubble_outline_rounded,
          activeIcon: Icons.chat_bubble_rounded,
          label: 'Messages'),
      _NavItem(
          icon: Icons.person_outline_rounded,
          activeIcon: Icons.person_rounded,
          label: 'Profile'),
    ];

    final activeColor = theme.colorScheme.primary;
    final inactiveColor =
        isDark ? const Color(0xFFADB4C4) : const Color(0xFF8E95A5);

    return Container(
      height: 72.0,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF181B23) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark
                ? const Color(0xFF303542)
                : const Color(0xFFE9EBF2).withValues(alpha: 0.8),
            width: 1.0,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          final isActive = currentIndex == index;
          final item = items[index];
          final color = isActive ? activeColor : inactiveColor;

          return Expanded(
            child: Semantics(
              label: '${item.label} Tab',
              selected: isActive,
              button: true,
              child: InkWell(
                onTap: () => onTap(index),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isActive ? item.activeIcon : item.icon,
                      color: color,
                      size: 24,
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 12.0,
                        fontWeight:
                            isActive ? FontWeight.bold : FontWeight.w500,
                        fontFamily: 'Plus Jakarta Sans',
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
