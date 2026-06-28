import 'package:flutter/material.dart';

class ShimmerBox extends StatefulWidget {
  final double? width;
  final double height;
  final double borderRadius;

  const ShimmerBox({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = 12.0,
  });

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _animation = Tween<double>(
      begin: 0.15,
      end: 0.35,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(_animation.value),
            borderRadius: BorderRadius.circular(widget.borderRadius),
          ),
        );
      },
    );
  }
}

class DashboardHeaderShimmer extends StatelessWidget {
  const DashboardHeaderShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShimmerBox(width: 100, height: 16),
            SizedBox(height: 8),
            ShimmerBox(width: 150, height: 28),
          ],
        ),
        Row(
          children: [
            ShimmerBox(width: 48, height: 48, borderRadius: 24),
            SizedBox(width: 12),
            ShimmerBox(width: 48, height: 48, borderRadius: 24),
            SizedBox(width: 12),
            ShimmerBox(width: 48, height: 48, borderRadius: 24),
          ],
        )
      ],
    );
  }
}

class UpcomingLiveClassShimmer extends StatelessWidget {
  const UpcomingLiveClassShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const ShimmerBox(
      height: 300,
      borderRadius: 24,
    );
  }
}

class TodayClassShimmer extends StatelessWidget {
  const TodayClassShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: ShimmerBox(
            height: 260,
            borderRadius: 20,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: ShimmerBox(
            height: 260,
            borderRadius: 20,
          ),
        ),
      ],
    );
  }
}

class UpcomingTestShimmer extends StatelessWidget {
  const UpcomingTestShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const ShimmerBox(
      height: 115,
      borderRadius: 22,
    );
  }
}

class ContinueLearningShimmer extends StatelessWidget {
  const ContinueLearningShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const ShimmerBox(
      height: 100,
      borderRadius: 22,
    );
  }
}

class GoalStreakShimmer extends StatelessWidget {
  const GoalStreakShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: ShimmerBox(
            height: 150,
            borderRadius: 22,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: ShimmerBox(
            height: 150,
            borderRadius: 22,
          ),
        ),
      ],
    );
  }
}

class FullDashboardShimmer extends StatelessWidget {
  const FullDashboardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      physics: NeverScrollableScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DashboardHeaderShimmer(),
            SizedBox(height: 24),
            UpcomingLiveClassShimmer(),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ShimmerBox(width: 140, height: 22),
                ShimmerBox(width: 60, height: 16),
              ],
            ),
            SizedBox(height: 12),
            TodayClassShimmer(),
            SizedBox(height: 24),
            UpcomingTestShimmer(),
            SizedBox(height: 24),
            ContinueLearningShimmer(),
          ],
        ),
      ),
    );
  }
}
