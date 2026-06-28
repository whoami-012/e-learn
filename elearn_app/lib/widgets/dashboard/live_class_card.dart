import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'upcoming_live_class_card.dart';

class LiveClassCard extends StatelessWidget {
  final String title;
  final String time;
  final String instructorName;
  final String imageUrl;
  final Color backgroundColor;
  final VoidCallback onTap;
  final bool isLive;

  const LiveClassCard({
    super.key,
    required this.title,
    required this.time,
    required this.instructorName,
    required this.imageUrl,
    required this.backgroundColor,
    required this.onTap,
    this.isLive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Area
            Container(
              height: 140.0,
              width: double.infinity,
              color: backgroundColor,
              child: Stack(
                children: [
                  // Decorative icons
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Opacity(
                      opacity: 0.12,
                      child: Icon(
                        Icons.science_outlined,
                        size: 70,
                        color: AppColors.navy,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 8,
                    bottom: 8,
                    child: Opacity(
                      opacity: 0.12,
                      child: Icon(
                        Icons.menu_book_rounded,
                        size: 50,
                        color: AppColors.navy,
                      ),
                    ),
                  ),

                  // Instructor image
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: FractionallySizedBox(
                      heightFactor: 0.85,
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.person_rounded,
                          size: 64,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),

                  // Live badge
                  if (isLive)
                    const Positioned(
                      left: 12,
                      top: 12,
                      child: LiveBadge(),
                    ),
                ],
              ),
            ),

            // Content Area
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.navy,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6.0),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        size: 13,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4.0),
                      Expanded(
                        child: Text(
                          time,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(
                              Icons.person_outline_rounded,
                              size: 13,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4.0),
                            Expanded(
                              child: Text(
                                instructorName,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Circular arrow button
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.border,
                            width: 1.0,
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.arrow_forward_rounded,
                            color: AppColors.primary,
                            size: 16,
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
