import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/course_provider.dart';
import '../../theme/app_theme.dart';

class FacultyLessonManagementScreen extends StatefulWidget {
  final String courseId;
  final String courseTitle;

  const FacultyLessonManagementScreen({
    super.key,
    required this.courseId,
    required this.courseTitle,
  });

  @override
  State<FacultyLessonManagementScreen> createState() =>
      _FacultyLessonManagementScreenState();
}

class _FacultyLessonManagementScreenState
    extends State<FacultyLessonManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CourseProvider>().fetchLessons(widget.courseId);
    });
  }

  // ── Extract YouTube Video ID from full URL helper ───────────────────────────
  String _extractVideoId(String input) {
    input = input.trim();
    if (input.isEmpty) return '';

    // Regular expressions for various YouTube URL patterns
    final RegExp regExp1 = RegExp(
      r'^https?:\/\/(?:www\.)?youtube\.com\/watch\?v=([a-zA-Z0-9_-]{11})',
      caseSensitive: false,
    );
    final RegExp regExp2 = RegExp(
      r'^https?:\/\/youtu\.be\/([a-zA-Z0-9_-]{11})',
      caseSensitive: false,
    );
    final RegExp regExp3 = RegExp(
      r'^https?:\/\/(?:www\.)?youtube\.com\/embed\/([a-zA-Z0-9_-]{11})',
      caseSensitive: false,
    );

    final match1 = regExp1.firstMatch(input);
    if (match1 != null && match1.groupCount >= 1) {
      return match1.group(1) ?? '';
    }

    final match2 = regExp2.firstMatch(input);
    if (match2 != null && match2.groupCount >= 1) {
      return match2.group(1) ?? '';
    }

    final match3 = regExp3.firstMatch(input);
    if (match3 != null && match3.groupCount >= 1) {
      return match3.group(1) ?? '';
    }

    return input; // default to raw input if not matching any URL structure
  }

  // ── Show Add Lesson Dialog ──────────────────────────────────────────────────
  void _showAddLessonDialog(int currentLessonsCount) {
    final titleCtrl = TextEditingController();
    final urlOrIdCtrl = TextEditingController();
    final orderCtrl =
        TextEditingController(text: currentLessonsCount.toString());
    bool isPreview = false;
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlg) => AlertDialog(
          title: const Text('Add Recorded Video Class'),
          scrollable: true,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Class/Lesson Title *',
                  hintText: 'e.g. Introduction to Dart',
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: urlOrIdCtrl,
                decoration: const InputDecoration(
                  labelText: 'YouTube URL or Video ID *',
                  hintText: 'e.g. dQw4w9WgXcQ or YouTube link',
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: orderCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Order Index *',
                  hintText: 'e.g. 0, 1, 2...',
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Free Preview Lesson',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary),
                ),
                subtitle: const Text(
                  'Allow non-enrolled users to watch this lesson.',
                  style:
                      TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                value: isPreview,
                onChanged: (val) {
                  setDlg(() {
                    isPreview = val;
                  });
                },
                activeThumbColor: AppColors.primary,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: isSubmitting
                  ? null
                  : () async {
                      final title = titleCtrl.text.trim();
                      final rawUrl = urlOrIdCtrl.text.trim();
                      final orderVal = int.tryParse(orderCtrl.text.trim());

                      if (title.isEmpty || rawUrl.isEmpty || orderVal == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Please fill all required fields correctly.')),
                        );
                        return;
                      }

                      final videoId = _extractVideoId(rawUrl);
                      if (videoId.length != 11) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Invalid YouTube Video ID (must be 11 characters).')),
                        );
                        return;
                      }

                      final courseProvider = context.read<CourseProvider>();
                      final scaffoldMessenger = ScaffoldMessenger.of(context);
                      final navigator = Navigator.of(ctx);

                      setDlg(() => isSubmitting = true);
                      try {
                        final success =
                            await courseProvider.createYoutubeLesson(
                          courseId: widget.courseId,
                          title: title,
                          videoId: videoId,
                          orderIndex: orderVal,
                          isPreview: isPreview,
                        );

                        if (success) {
                          scaffoldMessenger.showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Recorded class added successfully!')),
                          );
                          navigator.pop();
                        } else {
                          final errorMsg =
                              courseProvider.error ?? 'Failed to add class';
                          scaffoldMessenger.showSnackBar(
                            SnackBar(content: Text(errorMsg)),
                          );
                        }
                      } catch (e) {
                        scaffoldMessenger.showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      } finally {
                        if (context.mounted) {
                          setDlg(() => isSubmitting = false);
                        }
                      }
                    },
              child: isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white)),
                    )
                  : const Text('Add Class'),
            ),
          ],
        ),
      ),
    );
  }

  // ── Build ───────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Manage Recorded Classes'),
            Text(
              widget.courseTitle,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.normal,
                  color: AppColors.textSecondary),
            ),
          ],
        ),
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: const Border(bottom: BorderSide(color: AppColors.border)),
      ),
      body: Consumer<CourseProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
                child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.primary)));
          }

          final lessons = provider.lessons;

          if (lessons.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.video_collection_outlined,
                        size: 64, color: AppColors.textSecondary),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'No recorded classes yet.',
                      style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    const Text(
                      'Tap "+ Add Class" to add recorded video content.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.md, AppSpacing.md, 100),
            itemCount: lessons.length,
            itemBuilder: (context, index) {
              final lesson = lessons[index];
              return Card(
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                  side: const BorderSide(color: AppColors.border),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      // Thumbnail container (simulated YouTube thumbnail)
                      Container(
                        width: 90,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceMuted,
                          borderRadius: BorderRadius.circular(AppRadius.small),
                          image: DecorationImage(
                            image: NetworkImage(
                                'https://img.youtube.com/vi/${lesson.videoId}/0.jpg'),
                            fit: BoxFit.cover,
                            onError: (_, __) {},
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.play_arrow_rounded,
                              color: Colors.white, size: 18),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      // Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              lesson.title,
                              style: textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  'Order: ${lesson.orderIndex}',
                                  style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 11),
                                ),
                                if (lesson.isPreview) ...[
                                  const SizedBox(width: AppSpacing.sm),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.pastelMint,
                                      borderRadius: BorderRadius.circular(
                                          AppRadius.small - 4),
                                    ),
                                    child: Text(
                                      'Free Preview',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green.shade800,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'ID: ${lesson.videoId}',
                              style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 10,
                                  fontFamily: 'monospace'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: Consumer<CourseProvider>(
        builder: (context, provider, _) => FloatingActionButton.extended(
          onPressed: () => _showAddLessonDialog(provider.lessons.length),
          backgroundColor: AppColors.primary,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text('Add Class',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.medium)),
        ),
      ),
    );
  }
}
