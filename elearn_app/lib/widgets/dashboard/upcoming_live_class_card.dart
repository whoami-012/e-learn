import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class LiveBadge extends StatelessWidget {
  const LiveBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.live,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6.0),
          const Text(
            'Live',
            style: TextStyle(
              color: AppColors.navy,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class StudentAvatarStack extends StatelessWidget {
  final List<String> avatarUrls;
  final int additionalCount;

  const StudentAvatarStack({
    super.key,
    required this.avatarUrls,
    required this.additionalCount,
  });

  @override
  Widget build(BuildContext context) {
    const double avatarSize = 28.0;
    const double overlapOffset = 18.0;

    final double totalWidth = (avatarUrls.length * overlapOffset) + avatarSize;

    return SizedBox(
      height: avatarSize,
      width: totalWidth,
      child: Stack(
        children: [
          for (int i = 0; i < avatarUrls.length; i++)
            Positioned(
              left: i * overlapOffset,
              child: Container(
                width: avatarSize,
                height: avatarSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2.0),
                  color: AppColors.primarySoft,
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.network(
                  avatarUrls[i],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Center(
                    child: Text(
                      'S${i + 1}',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          Positioned(
            left: avatarUrls.length * overlapOffset,
            child: Container(
              width: avatarSize,
              height: avatarSize,
              decoration: BoxDecoration(
                color: const Color(0xFFFFFFFF),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2.0),
              ),
              alignment: Alignment.center,
              child: Text(
                '+$additionalCount',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.navy,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class UpcomingLiveClassCard extends StatelessWidget {
  final String title;
  final String instructorName;
  final String? instructorImageUrl;
  final String timeRemaining;
  final VoidCallback onJoinTap;

  const UpcomingLiveClassCard({
    super.key,
    required this.title,
    required this.instructorName,
    this.instructorImageUrl,
    required this.timeRemaining,
    required this.onJoinTap,
  });

  @override
  Widget build(BuildContext context) {
    // Default high-quality transparent cartoon student/teacher illustration
    final imgUrl = instructorImageUrl ?? 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&q=80&w=200';

    return Container(
      width: double.infinity,
      height: 310,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFE4D8FF),
            Color(0xFFD8CFFF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28.0),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background subtle math-related vector curves (decorative elements)
          Positioned(
            right: -20,
            top: -20,
            child: Opacity(
              opacity: 0.08,
              child: Icon(
                Icons.calculate_outlined,
                size: 180,
                color: AppColors.primaryDark,
              ),
            ),
          ),
          Positioned(
            left: -10,
            bottom: -10,
            child: Opacity(
              opacity: 0.08,
              child: Icon(
                Icons.functions_rounded,
                size: 120,
                color: AppColors.primaryDark,
              ),
            ),
          ),

          // Instructor Image aligned on the right side
          Positioned(
            right: 0,
            bottom: 0,
            top: 20,
            width: MediaQuery.of(context).size.width * 0.42,
            child: Align(
              alignment: Alignment.bottomRight,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(28.0),
                ),
                child: Image.network(
                  imgUrl,
                  fit: BoxFit.contain,
                  alignment: Alignment.bottomCenter,
                  errorBuilder: (context, error, stackTrace) => Container(
                    margin: const EdgeInsets.only(bottom: 24, right: 24),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(16.0),
                    child: const Icon(
                      Icons.person_rounded,
                      size: 64,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Content Layer (Left Side)
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top elements: Live Badge
                const Row(
                  children: [
                    LiveBadge(),
                  ],
                ),

                // Title info
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: AppColors.navy,
                          height: 1.2,
                        ),
                        children: [
                          TextSpan(text: '$title\n'),
                          const TextSpan(
                            text: 'starting soon',
                            style: TextStyle(
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12.0),
                    // Countdown/Time row
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time_filled_rounded,
                          color: AppColors.navy,
                          size: 16,
                        ),
                        const SizedBox(width: 6.0),
                        Text(
                          timeRemaining,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.navy,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Bottom row: Avatars stack and Join Class button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Avatar stack
                    const StudentAvatarStack(
                      avatarUrls: [
                        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=100',
                        'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?auto=format&fit=crop&q=80&w=100',
                        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&q=80&w=100',
                      ],
                      additionalCount: 24,
                    ),

                    // Join Button
                    ElevatedButton(
                      onPressed: onJoinTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.orange,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        elevation: 4.0,
                        shadowColor: AppColors.orange.withValues(alpha: 0.4),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Join class',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 8.0),
                          Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
