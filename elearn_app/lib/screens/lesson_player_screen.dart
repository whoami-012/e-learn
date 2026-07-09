import 'package:flutter/material.dart';
import '../models/lesson.dart';
import '../widgets/video_player_widget.dart';
import '../theme/app_theme.dart';

class LessonPlayerScreen extends StatefulWidget {
  final List<Lesson> lessons;
  final int initialIndex;
  final bool isEnrolled;

  const LessonPlayerScreen({
    required this.lessons,
    this.initialIndex = 0,
    this.isEnrolled = false,
    super.key,
  });

  @override
  State<LessonPlayerScreen> createState() => _LessonPlayerScreenState();
}

class _LessonPlayerScreenState extends State<LessonPlayerScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onLessonSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentLesson = widget.lessons[_currentIndex];
    final bool isLocked = !widget.isEnrolled && !currentLesson.isPreview;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Course Player"),
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: const Border(bottom: BorderSide(color: AppColors.border)),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Video Player Section
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.medium),
                boxShadow: AppTheme.softShadow,
              ),
              clipBehavior: Clip.antiAlias,
              child: VideoPlayerWidget(
                // ValueKey forces Flutter to fully dispose → recreate the widget
                // (and its controller) when the lesson changes, instead of the
                // didUpdateWidget path which can leave stale WebView references.
                key: ValueKey(currentLesson.videoId),
                videoId: currentLesson.videoId,
                isLocked: isLocked,
              ),
            ),
          ),

          // 2. Lesson Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md + 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: currentLesson.isPreview 
                            ? AppColors.pastelMint 
                            : AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        currentLesson.isPreview ? "FREE PREVIEW" : "LESSON ${currentLesson.orderIndex + 1}",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: currentLesson.isPreview 
                              ? Colors.green.shade700 
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  currentLesson.title,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Pre-recorded session",
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),
          const Divider(),

          // 3. Playlist / Navigation
          Expanded(
            child: Container(
              color: AppColors.surface,
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                itemCount: widget.lessons.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final lesson = widget.lessons[index];
                  final isCurrent = index == _currentIndex;
                  final isLessonLocked = !widget.isEnrolled && !lesson.isPreview;

                  return ListTile(
                    selected: isCurrent,
                    selectedTileColor: AppColors.primarySoft.withValues(alpha: 0.4),
                    onTap: () {
                      if (isLessonLocked) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('This lesson is locked. Enroll in the course to unlock.'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      } else {
                        _onLessonSelected(index);
                      }
                    },
                    leading: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isCurrent ? AppColors.primary : AppColors.surfaceMuted,
                        shape: BoxShape.circle,
                        border: Border.all(color: isCurrent ? AppColors.primary : AppColors.border),
                      ),
                      child: Center(
                        child: Icon(
                          isCurrent ? Icons.play_arrow_rounded : Icons.play_arrow_outlined,
                          size: 18,
                          color: isCurrent ? Colors.white : AppColors.textSecondary,
                        ),
                      ),
                    ),
                    title: Text(
                      lesson.title,
                      style: textTheme.titleSmall?.copyWith(
                        fontSize: 14,
                        fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                        color: isCurrent ? AppColors.primary : AppColors.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      "Lesson ${lesson.orderIndex + 1}",
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    trailing: isLessonLocked 
                        ? const Icon(Icons.lock_rounded, size: 16, color: AppColors.textSecondary)
                        : (lesson.isPreview 
                            ? const Icon(Icons.check_circle_outline, size: 16, color: AppColors.success)
                            : null),
                  );
                },
              ),
            ),
          ),
          
          // 4. Bottom Controls (Previous / Next)
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: AppTheme.softShadow,
              border: const Border(top: BorderSide(color: AppColors.border)),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        onPressed: _currentIndex > 0 
                            ? () => _onLessonSelected(_currentIndex - 1) 
                            : null,
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          side: const BorderSide(color: AppColors.border),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.medium)),
                        ),
                        child: const Text("Previous", style: TextStyle(color: AppColors.textSecondary)),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _currentIndex < widget.lessons.length - 1 
                            ? () => _onLessonSelected(_currentIndex + 1) 
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.medium)),
                        ),
                        child: const Text("Next Lesson", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
