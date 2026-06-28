import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class UpcomingTestCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String dateTime;
  final VoidCallback onTap;

  const UpcomingTestCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.dateTime,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 115,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        decoration: BoxDecoration(
          gradient: isDark
              ? const LinearGradient(
                  colors: [
                    Color(0xFF1E293B),
                    Color(0xFF0F172A),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : const LinearGradient(
                  colors: [
                    AppColors.blueSoft,
                    Color(0xFFEDF8FF),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          borderRadius: BorderRadius.circular(22.0),
          border: isDark ? Border.all(color: const Color(0xFF303542)) : null,
        ),
        child: Row(
          children: [
            // Left: circular icon container
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF334155) : Colors.white,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.assignment_outlined,
                  color: isDark ? const Color(0xFF60A5FA) : AppColors.blue,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 16.0),
            // Center: Info
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isDark ? const Color(0xFF60A5FA) : AppColors.blue,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.navy,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    dateTime,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isDark ? const Color(0xFFADB4C4) : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // Right: Chevron
            Icon(
              Icons.chevron_right_rounded,
              color: isDark ? Colors.white : AppColors.navy,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
