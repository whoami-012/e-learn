import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class FeaturedActionCard extends StatelessWidget {
  final String title;
  final int lessonsCount;
  final String duration;
  final double progress;
  final VoidCallback onPlayTap;

  const FeaturedActionCard({
    super.key,
    required this.title,
    required this.lessonsCount,
    required this.duration,
    required this.progress,
    required this.onPlayTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFF5F3FF), Color(0xFFFDF2F8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFF3E8FF), width: 1),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFF3E8FF).withOpacity(0.5),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // ── Background Decoration ────────────────────────────────────
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color(0xFFE9D5FF).withOpacity(0.3), const Color(0xFFFBCFE8).withOpacity(0.3)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(120)),
                ),
              ),
            ),

            // ── Content ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Today's Task",
                            style: AppTheme.bodySmall.copyWith(
                              color: const Color(0xFF9333EA),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            title,
                            style: AppTheme.h3.copyWith(fontSize: 18),
                          ),
                        ],
                      ),
                      // Play Button
                      GestureDetector(
                        onTap: onPlayTap,
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFA78BFA), Color(0xFFF472B6)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFD8B4FE).withOpacity(0.4),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 32),
                        ),
                      ),
                    ],
                  ),

                  // Metadata Row
                  Row(
                    children: [
                      _MetaBadge(
                        label: '$lessonsCount',
                        suffix: 'lessons',
                        bgColor: const Color(0xFFF3E8FF),
                        textColor: const Color(0xFF9333EA),
                      ),
                      const SizedBox(width: 16),
                      Row(
                        children: [
                          const Icon(Icons.access_time_rounded, size: 16, color: Color(0xFF9CA3AF)),
                          const SizedBox(width: 6),
                          Text(duration, style: AppTheme.bodySmall),
                        ],
                      ),
                    ],
                  ),

                  // Progress Bar
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Progress', style: AppTheme.labelSmall),
                          Text('${(progress * 100).toInt()}%',
                              style: AppTheme.labelSmall.copyWith(
                                color: const Color(0xFF9333EA),
                              )),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        height: 6,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3E8FF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: progress,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFA78BFA), Color(0xFFF472B6)],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaBadge extends StatelessWidget {
  final String label;
  final String suffix;
  final Color bgColor;
  final Color textColor;

  const _MetaBadge({
    required this.label,
    required this.suffix,
    required this.bgColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textColor),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(suffix, style: AppTheme.bodySmall),
      ],
    );
  }
}
