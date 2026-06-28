import 'package:flutter/material.dart';
import '../dashboard/shimmer_skeletons.dart';

/// A skeleton loader widget displaying shimmer cards to match CourseListCard dimensions.
class CourseListSkeleton extends StatelessWidget {
  final int count;

  const CourseListSkeleton({
    super.key,
    this.count = 5,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: count,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 14.0),
          child: Container(
            padding: const EdgeInsets.all(14.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color(0xFFE9EBF2).withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ── 1. Thumbnail Block Shimmer ──
                const ShimmerBox(
                  width: 120,
                  height: 115,
                  borderRadius: 18,
                ),
                const SizedBox(width: 16),

                // ── 2. Information Area Shimmer ──
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title block lines
                      const ShimmerBox(
                        width: double.infinity,
                        height: 16,
                        borderRadius: 4,
                      ),
                      const SizedBox(height: 6),
                      const ShimmerBox(
                        width: 140,
                        height: 16,
                        borderRadius: 4,
                      ),
                      const SizedBox(height: 12),

                      // Metadata Row Shimmer
                      const Row(
                        children: [
                          ShimmerBox(
                            width: 60,
                            height: 12,
                            borderRadius: 4,
                          ),
                          SizedBox(width: 12),
                          ShimmerBox(
                            width: 60,
                            height: 12,
                            borderRadius: 4,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Category Pill Shimmer
                      const ShimmerBox(
                        width: 75,
                        height: 24,
                        borderRadius: 8,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // ── 3. Arrow Action Indicator Shimmer ──
                const ShimmerBox(
                  width: 44,
                  height: 44,
                  borderRadius: 22,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
