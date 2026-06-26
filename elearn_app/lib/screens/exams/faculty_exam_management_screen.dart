import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/exam.dart';
import '../../providers/exam_provider.dart';
import '../../theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Exam Management — lists exams for a course, lets faculty create/delete them
// ─────────────────────────────────────────────────────────────────────────────

class FacultyExamManagementScreen extends StatefulWidget {
  final String courseId;
  const FacultyExamManagementScreen({super.key, required this.courseId});

  @override
  State<FacultyExamManagementScreen> createState() =>
      _FacultyExamManagementScreenState();
}

class _FacultyExamManagementScreenState
    extends State<FacultyExamManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExamProvider>().fetchExams(widget.courseId);
    });
  }

  // ── Create exam dialog ──────────────────────────────────────────────────────
  void _showCreateExamDialog() {
    final titleCtrl = TextEditingController();
    final durationCtrl = TextEditingController();
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlg) => AlertDialog(
          title: const Text('Create New Exam'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Exam Title',
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: durationCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Duration (minutes)',
                  suffixText: 'min',
                ),
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
                      final dur = int.tryParse(durationCtrl.text.trim());
                      if (title.isEmpty || dur == null) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          const SnackBar(
                              content: Text('Please fill all fields correctly.')),
                        );
                        return;
                      }
                      setDlg(() => isSubmitting = true);
                      try {
                        await context
                            .read<ExamProvider>()
                            .createExam(widget.courseId, title, dur);
                        if (mounted) Navigator.pop(ctx);
                      } catch (e) {
                        setDlg(() => isSubmitting = false);
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    },
              child: isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                    )
                  : const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  // ── Delete exam confirm ─────────────────────────────────────────────────────
  Future<void> _confirmDeleteExam(BuildContext ctx, ExamProvider provider,
      Exam exam) async {
    final confirm = await showDialog<bool>(
      context: ctx,
      builder: (dlgCtx) => AlertDialog(
        title: const Text('Delete Exam?'),
        content: Text(
            'This will permanently delete "${exam.title}" and all its questions.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dlgCtx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(dlgCtx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      try {
        await provider.deleteExam(exam.id);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete: $e')),
          );
        }
      }
    }
  }

  // ── Build ───────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Manage Exams'),
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: const Border(bottom: BorderSide(color: AppColors.border)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateExamDialog,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New Exam', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.medium)),
      ),
      body: Consumer<ExamProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary)));
          }

          if (provider.exams.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.quiz_outlined, size: 64, color: AppColors.textSecondary),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'No exams yet.',
                      style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    const Text(
                      'Tap "+ New Exam" to create one.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, 100),
            itemCount: provider.exams.length,
            itemBuilder: (context, index) {
              final exam = provider.exams[index];
              return _ExamCard(
                exam: exam,
                onManageQuestions: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => QuestionManagementScreen(exam: exam),
                  ),
                ),
                onDelete: () =>
                    _confirmDeleteExam(context, provider, exam),
              );
            },
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Exam Card widget
// ─────────────────────────────────────────────────────────────────────────────

class _ExamCard extends StatelessWidget {
  final Exam exam;
  final VoidCallback onManageQuestions;
  final VoidCallback onDelete;

  const _ExamCard({
    required this.exam,
    required this.onManageQuestions,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.medium),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title + delete button row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(AppRadius.small),
                  ),
                  child: const Icon(Icons.quiz_rounded, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: AppSpacing.sm + 4),
                Expanded(
                  child: Text(
                    exam.title,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                  tooltip: 'Delete exam',
                  onPressed: onDelete,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            // Duration chip
            Row(
              children: [
                const Icon(Icons.timer_outlined, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  '${exam.durationMinutes} minutes',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            const Divider(color: AppColors.border, height: 1),
            const SizedBox(height: AppSpacing.sm + 4),
            // Manage Questions button — full width, prominent
            SizedBox(
              width: double.infinity,
              height: 46,
              child: OutlinedButton.icon(
                onPressed: onManageQuestions,
                icon: const Icon(Icons.format_list_numbered_rounded, size: 18),
                label: const Text('Manage Questions & Answers'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.medium),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Question Management — full screen, list of MCQs + Add button
// ─────────────────────────────────────────────────────────────────────────────

class QuestionManagementScreen extends StatefulWidget {
  final Exam exam;
  const QuestionManagementScreen({super.key, required this.exam});

  @override
  State<QuestionManagementScreen> createState() =>
      _QuestionManagementScreenState();
}

class _QuestionManagementScreenState
    extends State<QuestionManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExamProvider>().fetchQuestions(widget.exam.id);
    });
  }

  // ── Add question dialog ─────────────────────────────────────────────────────
  void _showAddQuestionDialog() {
    final textCtrl = TextEditingController();
    final optACtrl = TextEditingController();
    final optBCtrl = TextEditingController();
    final optCCtrl = TextEditingController();
    final optDCtrl = TextEditingController();
    String correctOption = 'A';
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlg) => AlertDialog(
          title: const Text('Add MCQ Question'),
          scrollable: true,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Question text
              TextField(
                controller: textCtrl,
                maxLines: 3,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Question Text *',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              const Text('Answer Options',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary)),
              const SizedBox(height: AppSpacing.sm),
              // Option A
              _OptionField(label: 'A', controller: optACtrl),
              const SizedBox(height: AppSpacing.sm),
              // Option B
              _OptionField(label: 'B', controller: optBCtrl),
              const SizedBox(height: AppSpacing.sm),
              // Option C
              _OptionField(label: 'C', controller: optCCtrl),
              const SizedBox(height: AppSpacing.sm),
              // Option D
              _OptionField(label: 'D', controller: optDCtrl),
              const SizedBox(height: AppSpacing.md),
              // Correct answer selector
              const Text('Correct Answer',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary)),
              const SizedBox(height: AppSpacing.sm),
              Container(
                width: double.infinity,
                alignment: Alignment.center,
                child: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'A', label: Text('A')),
                    ButtonSegment(value: 'B', label: Text('B')),
                    ButtonSegment(value: 'C', label: Text('C')),
                    ButtonSegment(value: 'D', label: Text('D')),
                  ],
                  selected: {correctOption},
                  onSelectionChanged: (val) =>
                      setDlg(() => correctOption = val.first),
                ),
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
                      final text = textCtrl.text.trim();
                      final a = optACtrl.text.trim();
                      final b = optBCtrl.text.trim();
                      final c = optCCtrl.text.trim();
                      final d = optDCtrl.text.trim();

                      if (text.isEmpty || a.isEmpty || b.isEmpty ||
                          c.isEmpty || d.isEmpty) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Please fill in the question and all 4 options.')),
                        );
                        return;
                      }
                      setDlg(() => isSubmitting = true);
                      try {
                        await context.read<ExamProvider>().addQuestion(
                              widget.exam.id,
                              text,
                              {'A': a, 'B': b, 'C': c, 'D': d},
                              correctOption,
                            );
                        if (mounted) Navigator.pop(ctx);
                      } catch (e) {
                        setDlg(() => isSubmitting = false);
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    },
              child: isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                    )
                  : const Text('Add Question'),
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
            const Text('Questions & Answers'),
            Text(
              widget.exam.title,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.normal, color: AppColors.textSecondary),
            ),
          ],
        ),
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: const Border(bottom: BorderSide(color: AppColors.border)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddQuestionDialog,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add MCQ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.medium)),
      ),
      body: Consumer<ExamProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary)));
          }

          if (provider.questions.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.format_list_bulleted, size: 64, color: AppColors.textSecondary),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'No questions yet.',
                      style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    const Text(
                      'Tap "+ Add MCQ" to add your first question.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, 100),
            itemCount: provider.questions.length,
            itemBuilder: (context, index) {
              final q = provider.questions[index];
              return _QuestionCard(
                index: index,
                question: q,
                onDelete: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (dlgCtx) => AlertDialog(
                      title: const Text('Delete Question?'),
                      content: Text('Q${index + 1}: ${q.questionText}'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dlgCtx, false),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          style: FilledButton.styleFrom(backgroundColor: AppColors.error),
                          onPressed: () => Navigator.pop(dlgCtx, true),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await provider.deleteQuestion(q.id);
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Question Card widget
// ─────────────────────────────────────────────────────────────────────────────

class _QuestionCard extends StatelessWidget {
  final int index;
  final Question question;
  final VoidCallback onDelete;

  const _QuestionCard({
    required this.index,
    required this.question,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final options = question.options;
    final correct = question.correctAnswer;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.medium),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 13,
                  backgroundColor: AppColors.primarySoft,
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm + 2),
                Expanded(
                  child: Text(
                    question.questionText,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                  tooltip: 'Delete question',
                  onPressed: onDelete,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            // Options list
            ...['A', 'B', 'C', 'D'].map((key) {
              final isCorrect = key == correct;
              return Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.xs + 2),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm + 4, vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: isCorrect ? AppColors.pastelMint : AppColors.surfaceMuted,
                  border: Border.all(
                    color: isCorrect ? AppColors.success : AppColors.border,
                    width: isCorrect ? 1.5 : 1,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.small),
                ),
                child: Row(
                  children: [
                    // Option letter badge
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: isCorrect ? AppColors.success : AppColors.textSecondary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(AppRadius.small - 4),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        key,
                        style: TextStyle(
                          color: isCorrect ? Colors.white : AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm + 2),
                    Expanded(
                      child: Text(
                        options[key] ?? '',
                        style: TextStyle(
                          color: isCorrect ? Colors.green.shade800 : AppColors.textPrimary,
                          fontWeight: isCorrect ? FontWeight.bold : FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    if (isCorrect)
                      const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 16),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Option Field helper widget
// ─────────────────────────────────────────────────────────────────────────────

class _OptionField extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const _OptionField({required this.label, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: 'Option $label *',
        prefixIcon: Container(
          margin: const EdgeInsets.all(8),
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppColors.primarySoft,
            borderRadius: BorderRadius.circular(AppRadius.small - 4),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}
