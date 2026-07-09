import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';

/// DashboardLoadingView — shimmer-style skeleton for the full dashboard.
class DashboardLoadingView extends StatefulWidget {
  const DashboardLoadingView({super.key});

  @override
  State<DashboardLoadingView> createState() => _DashboardLoadingViewState();
}

class _DashboardLoadingViewState extends State<DashboardLoadingView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(children: [
              _Bone(width: 48, height: 48, radius: 24, opacity: _anim.value),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(children: [
                _Bone(height: 16, radius: 6, opacity: _anim.value),
                const SizedBox(height: 6),
                _Bone(height: 12, radius: 6, opacity: _anim.value * 0.6),
              ])),
              const SizedBox(width: 12),
              _Bone(width: 40, height: 40, radius: 12, opacity: _anim.value),
              const SizedBox(width: 8),
              _Bone(width: 40, height: 40, radius: 12, opacity: _anim.value),
            ]),
            const SizedBox(height: 16),
            // Search bar
            _Bone(height: 48, radius: 12, opacity: _anim.value),
            const SizedBox(height: 16),
            // Quick actions
            Row(
                children: List.generate(
                    4,
                    (_) => Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: _Bone(
                                height: 80, radius: 12, opacity: _anim.value),
                          ),
                        ))),
            const SizedBox(height: 16),
            // Overview card
            _Bone(height: 110, radius: 14, opacity: _anim.value),
            const SizedBox(height: 16),
            // Schedule section title
            _Bone(width: 140, height: 18, radius: 6, opacity: _anim.value),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                  child: _Bone(height: 140, radius: 14, opacity: _anim.value)),
              const SizedBox(width: 12),
              Expanded(
                  child: _Bone(height: 140, radius: 14, opacity: _anim.value)),
            ]),
            const SizedBox(height: 16),
            // Attention
            _Bone(width: 180, height: 18, radius: 6, opacity: _anim.value),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                  child: _Bone(height: 90, radius: 12, opacity: _anim.value)),
              const SizedBox(width: 12),
              Expanded(
                  child: _Bone(height: 90, radius: 12, opacity: _anim.value)),
              const SizedBox(width: 12),
              Expanded(
                  child: _Bone(height: 90, radius: 12, opacity: _anim.value)),
            ]),
            const SizedBox(height: 16),
            // Courses
            _Bone(width: 120, height: 18, radius: 6, opacity: _anim.value),
            const SizedBox(height: 12),
            ...List.generate(
                3,
                (_) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child:
                          _Bone(height: 76, radius: 14, opacity: _anim.value),
                    )),
          ],
        ),
      ),
    );
  }
}

class _Bone extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;
  final double opacity;

  const _Bone(
      {this.width,
      required this.height,
      required this.radius,
      required this.opacity});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? const Color(0xFF222631) : AppColors.border;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: baseColor.withValues(alpha: opacity),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

/// DashboardErrorView — friendly error with retry button.
class DashboardErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const DashboardErrorView(
      {super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconBgColor =
        isDark ? const Color(0xFF2C1E1E) : const Color(0xFFFFECEC);
    final titleColor = isDark ? Colors.white : AppColors.navy;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.wifi_off_rounded,
                  size: 36, color: AppColors.error),
            ),
            const SizedBox(height: 20),
            Text('Something went wrong',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: titleColor)),
            const SizedBox(height: 8),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: isDark ? Colors.black : Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// DashboardOfflineBanner — compact top banner when offline.
class DashboardOfflineBanner extends StatelessWidget {
  final VoidCallback onRetry;

  const DashboardOfflineBanner({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF2C2414) : const Color(0xFFFFF3CD);
    final borderColor =
        isDark ? const Color(0xFF4A3C1D) : const Color(0xFFFFE083);
    final textColor =
        isDark ? const Color(0xFFFFD580) : const Color(0xFF7A5600);
    final buttonColor =
        isDark ? const Color(0xFFFFD580) : const Color(0xFFB88000);

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Icon(Icons.wifi_off_rounded, size: 16, color: buttonColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'You\'re offline. Showing cached data.',
              style: TextStyle(fontSize: 12, color: textColor),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text('Retry',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: buttonColor)),
          ),
        ],
      ),
    );
  }
}
