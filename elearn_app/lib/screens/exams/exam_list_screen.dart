import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/exam_provider.dart';
import '../../theme/app_theme.dart';
import 'exam_taking_screen.dart';

class ExamListScreen extends StatefulWidget {
  final String courseId;
  final String courseTitle;

  const ExamListScreen({super.key, required this.courseId, required this.courseTitle});

  @override
  State<ExamListScreen> createState() => _ExamListScreenState();
}

class _ExamListScreenState extends State<ExamListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExamProvider>().fetchExams(widget.courseId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Exams: ${widget.courseTitle}'),
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: const Border(bottom: BorderSide(color: AppColors.border)),
      ),
      body: Consumer<ExamProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            );
          }

          if (provider.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
                    const SizedBox(height: AppSpacing.md),
                    Text(provider.error!, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: AppSpacing.md),
                    ElevatedButton(
                      onPressed: () => provider.fetchExams(widget.courseId),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (provider.exams.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.assignment_turned_in_rounded, size: 52, color: AppColors.textSecondary),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'No exams scheduled',
                      style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    const Text(
                      'No exams or quizzes are available for this course right now.',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: provider.exams.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final exam = provider.exams[index];
              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                  side: const BorderSide(color: AppColors.border),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.primarySoft,
                          borderRadius: BorderRadius.circular(AppRadius.small),
                        ),
                        child: const Icon(Icons.assignment_rounded, color: AppColors.primary, size: 22),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              exam.title,
                              style: textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Duration: ${exam.durationMinutes} mins',
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ExamTakingScreen(exam: exam),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.small)),
                        ),
                        child: const Text('Take Exam', style: TextStyle(fontSize: 13, color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
