import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../models/exam.dart';
import '../../providers/exam_provider.dart';
import '../../theme/app_theme.dart';
import 'exam_result_screen.dart';

class ExamTakingScreen extends StatefulWidget {
  final Exam exam;

  const ExamTakingScreen({super.key, required this.exam});

  @override
  State<ExamTakingScreen> createState() => _ExamTakingScreenState();
}

class _ExamTakingScreenState extends State<ExamTakingScreen> {
  final Map<String, String> _answers = {};
  bool _isSubmitting = false;
  Timer? _timer;
  int _remainingSeconds = 0;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.exam.durationMinutes * 60;
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExamProvider>().fetchQuestions(widget.exam.id);
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        _timer?.cancel();
        _submitExam(); // Auto submit when time is up
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final m = (seconds / 60).floor().toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> _submitExam() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);
    _timer?.cancel();

    try {
      final attempt = await context.read<ExamProvider>().submitAttempt(widget.exam.id, _answers);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ExamResultScreen(attempt: attempt)),
      );
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Submission failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.exam.title),
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: const Border(bottom: BorderSide(color: AppColors.border)),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.pastelPink,
                borderRadius: BorderRadius.circular(AppRadius.pill),
                border: Border.all(color: AppColors.error.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.timer_outlined, color: AppColors.error, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    _formatTime(_remainingSeconds),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.error),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
      body: Consumer<ExamProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.questions.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            );
          }

          if (provider.error != null && provider.questions.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
                  const SizedBox(height: AppSpacing.md),
                  Text(provider.error!, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: AppSpacing.md),
                  ElevatedButton(
                    onPressed: () => provider.fetchQuestions(widget.exam.id),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (provider.questions.isEmpty) {
            return const Center(child: Text('This exam has no questions yet.', style: TextStyle(color: AppColors.textSecondary)));
          }

          final questions = provider.questions;

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: questions.length,
                  itemBuilder: (context, index) {
                    final q = questions[index];
                    return Card(
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: AppSpacing.md),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.medium),
                        side: const BorderSide(color: AppColors.border),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Question ${index + 1} of ${questions.length}',
                              style: textTheme.bodySmall?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              q.questionText,
                              style: textTheme.titleSmall?.copyWith(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            ...q.options.entries.map((entry) {
                              final isSelected = _answers[q.id] == entry.key;
                              return Container(
                                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.primarySoft.withOpacity(0.4) : AppColors.surfaceMuted,
                                  borderRadius: BorderRadius.circular(AppRadius.medium),
                                  border: Border.all(
                                    color: isSelected ? AppColors.primary : AppColors.border,
                                    width: isSelected ? 1.5 : 1,
                                  ),
                                ),
                                child: RadioListTile<String>(
                                  title: Text(
                                    entry.value,
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      fontSize: 14,
                                    ),
                                  ),
                                  value: entry.key,
                                  groupValue: _answers[q.id],
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() => _answers[q.id] = val);
                                    }
                                  },
                                  activeColor: AppColors.primary,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  border: Border(top: BorderSide(color: AppColors.border)),
                ),
                child: SafeArea(
                  top: false,
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitExam,
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('Submit Exam'),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
