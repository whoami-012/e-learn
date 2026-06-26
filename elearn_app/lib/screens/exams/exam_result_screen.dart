import 'package:flutter/material.dart';
import '../../models/exam.dart';
import '../../theme/app_theme.dart';

class ExamResultScreen extends StatelessWidget {
  final Attempt attempt;

  const ExamResultScreen({super.key, required this.attempt});

  @override
  Widget build(BuildContext context) {
    final bool passed = attempt.percentage >= 50.0;
    final color = passed ? AppColors.success : AppColors.error;
    final bgColor = passed ? AppColors.pastelMint : AppColors.pastelPink;
    final icon = passed ? Icons.emoji_events_rounded : Icons.sentiment_dissatisfied_rounded;
    final message = passed ? 'Congratulations! You passed the exam.' : 'Keep practicing and try again to improve.';
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Exam Result'),
        automaticallyImplyLeading: false, // Force user to use the bottom button
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: const Border(bottom: BorderSide(color: AppColors.border)),
      ),
      body: Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Result Status Icon inside container
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 72, color: color),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Score percentage display
              Text(
                '${attempt.percentage.toStringAsFixed(0)}%',
                style: TextStyle(fontSize: 54, fontWeight: FontWeight.w800, color: color, letterSpacing: -1),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Score: ${attempt.score} of ${attempt.total} Correct Answers',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Status message Card
              Container(
                padding: const EdgeInsets.all(AppSpacing.md + 4),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.large),
                  border: Border.all(color: AppColors.border),
                  boxShadow: AppTheme.miniShadow,
                ),
                child: Column(
                  children: [
                    Text(
                      passed ? 'Exam Passed' : 'Exam Failed',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      message,
                      style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),

              // Return button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Go back to exam list
                  },
                  child: const Text('Back to Course'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
