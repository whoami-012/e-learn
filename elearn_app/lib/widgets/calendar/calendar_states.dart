import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../dashboard/shimmer_skeletons.dart';

/// Shimmer skeleton matching the exact heights and widths of the calendar grid.
class CalendarLoadingSkeleton extends StatelessWidget {
  const CalendarLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header placeholders
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const ShimmerBox(width: 48, height: 48, borderRadius: 24),
                const ShimmerBox(width: 180, height: 28, borderRadius: 6),
                const ShimmerBox(width: 48, height: 48, borderRadius: 24),
              ],
            ),
          ),

          // 2. Large month card placeholder
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
            child: Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF181B23) : Colors.white,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(
                  color: isDark ? const Color(0xFF303542) : const Color(0xFFE9EBF2).withOpacity(0.5),
                ),
              ),
              child: Column(
                children: [
                  // Month switcher shimmer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const ShimmerBox(width: 44, height: 44, borderRadius: 8),
                      const ShimmerBox(width: 120, height: 20, borderRadius: 4),
                      const ShimmerBox(width: 44, height: 44, borderRadius: 8),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Weekday row shimmer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(
                      7,
                      (_) => const ShimmerBox(width: 32, height: 12, borderRadius: 2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Grid cells shimmer
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: 35, // 5 rows is sufficient for placeholder representation
                    itemBuilder: (_, __) => const ShimmerBox(width: 40, height: 40, borderRadius: 20),
                  ),
                ],
              ),
            ),
          ),

          // 3. Selected day heading placeholder
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const ShimmerBox(width: 170, height: 22, borderRadius: 4),
                const ShimmerBox(width: 75, height: 38, borderRadius: 19),
              ],
            ),
          ),

          // 4. Three daily schedule card placeholders
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: List.generate(
                3,
                (_) => Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF181B23) : Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: isDark ? const Color(0xFF303542) : const Color(0xFFE9EBF2).withOpacity(0.5),
                      ),
                    ),
                    child: Row(
                      children: [
                        // Time column block
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ShimmerBox(width: 55, height: 14, borderRadius: 3),
                            SizedBox(height: 6),
                            ShimmerBox(width: 45, height: 12, borderRadius: 3),
                          ],
                        ),
                        const SizedBox(width: 14),
                        // Divider
                        Container(
                          width: 1.5,
                          height: 50,
                          color: isDark ? const Color(0xFF303542) : const Color(0xFFE9EBF2),
                        ),
                        const SizedBox(width: 14),
                        // Icon block
                        const ShimmerBox(width: 58, height: 58, borderRadius: 16),
                        const SizedBox(width: 16),
                        // Information block
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ShimmerBox(width: double.infinity, height: 16, borderRadius: 4),
                              SizedBox(height: 6),
                              ShimmerBox(width: 120, height: 13, borderRadius: 4),
                              SizedBox(height: 6),
                              ShimmerBox(width: 80, height: 10, borderRadius: 4),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A centered empty state shown when no events occur for the day/month.
class CalendarEmptyState extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final String? actionText;
  final VoidCallback? onActionTap;

  const CalendarEmptyState({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    this.actionText,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 32.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(22.0),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF222631) : const Color(0xFFF3EFFF),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 40,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF101936),
              fontFamily: 'Plus Jakarta Sans',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: TextStyle(
              fontSize: 13.5,
              color: isDark ? const Color(0xFFADB4C4) : const Color(0xFF6F7588),
              height: 1.35,
              fontFamily: 'Plus Jakarta Sans',
            ),
            textAlign: TextAlign.center,
          ),
          if (actionText != null && onActionTap != null) ...[
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onActionTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: isDark ? Colors.black : Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                actionText!,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// A full screen block error page.
class CalendarErrorState extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback onRetry;

  const CalendarErrorState({
    super.key,
    required this.title,
    required this.description,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 48.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF3B2525) : const Color(0xFFFFECEC),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                size: 44,
                color: Color(0xFFFF5757),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF101936),
                fontFamily: 'Plus Jakarta Sans',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                fontSize: 13.5,
                color: isDark ? const Color(0xFFADB4C4) : const Color(0xFF6F7588),
                height: 1.4,
                fontFamily: 'Plus Jakarta Sans',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF5757),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Try Again',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Thin warning banner for connection outages where data is cached in memory.
class OfflineBanner extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const OfflineBanner({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final redColor = isDark ? const Color(0xFFFF8E8E) : const Color(0xFFFF5757);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 11.0),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF3B2525) : const Color(0xFFFFECEC),
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: isDark ? const Color(0xFF8B3A3A) : const Color(0xFFFFC5C5)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: redColor,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: redColor,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Plus Jakarta Sans',
                ),
              ),
            ),
            const SizedBox(width: 10),
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                foregroundColor: redColor,
              ),
              child: const Text(
                'Retry',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Plus Jakarta Sans',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
