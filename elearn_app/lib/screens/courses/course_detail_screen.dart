import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/course_provider.dart';
import '../../providers/enrollment_provider.dart';
import '../../providers/user_provider.dart';
import '../../theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import 'edit_course_screen.dart';
import 'notes_screen.dart';
import '../lesson_player_screen.dart';
import '../../services/course_service.dart';
import 'mock_payment_screen.dart';
import '../exams/exam_list_screen.dart';
import '../exams/faculty_exam_management_screen.dart';
import 'faculty_lesson_management_screen.dart';

class CourseDetailScreen extends StatefulWidget {
  final String courseId;

  const CourseDetailScreen({super.key, required this.courseId});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CourseProvider>().fetchCourseById(widget.courseId);
      context.read<EnrollmentProvider>().checkEnrollment(widget.courseId);
    });
  }

  String _fullImageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    return '${AppConstants.serverBase}$path';
  }

  Future<void> _onWatchLessons(BuildContext context) async {
    final provider = context.read<CourseProvider>();
    final isEnrolled = context.read<EnrollmentProvider>().isEnrolled;
    
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      ),
    );

    try {
      await provider.fetchLessons(widget.courseId);
      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog

      if (provider.lessons.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No lessons available for this course yet.')),
        );
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LessonPlayerScreen(
            lessons: provider.lessons,
            isEnrolled: isEnrolled,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load lessons: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<CourseProvider>(
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
                    Text(provider.error!, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                    const SizedBox(height: AppSpacing.md),
                    ElevatedButton(
                      onPressed: () => provider.fetchCourseById(widget.courseId),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final course = provider.selectedCourse;
          if (course == null) return const SizedBox();

          final imageUrl = _fullImageUrl(course.thumbnailUrl);

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── 1. Visual Header with Thumbnail ────────────────────────────
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                elevation: 0,
                backgroundColor: AppColors.primary,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.black.withOpacity(0.35),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: const [StretchMode.zoomBackground],
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Thumbnail Image
                      imageUrl.isNotEmpty
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _buildPlaceholder(),
                            )
                          : _buildPlaceholder(),
                      
                      // Gradient Overlay for Readability
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.2),
                              Colors.transparent,
                              Colors.black.withOpacity(0.65),
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── 2. Course Content Section ──────────────────────────────────
              SliverToBoxAdapter(
                child: Container(
                  color: AppColors.background,
                  padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.lg, AppSpacing.md, AppSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Course Title
                      Text(
                        course.title,
                        style: textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),

                      const SizedBox(height: AppSpacing.sm),

                      // ── Price Badge & Category ───────────────────────────
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: course.isFree ? AppColors.pastelMint : AppColors.primarySoft,
                              borderRadius: BorderRadius.circular(AppRadius.pill),
                            ),
                            child: Text(
                              course.isFree ? '🎓 FREE' : '₹${course.price.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: course.isFree ? Colors.green.shade700 : AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(AppRadius.pill),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Text(
                              'Development',
                              style: textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      // ── Key Metrics Banner ─────────────────────────────────
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppRadius.medium),
                          border: Border.all(color: AppColors.border),
                          boxShadow: AppTheme.miniShadow,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _MetricItem(icon: Icons.star_rounded, label: '4.8', subLabel: 'Rating', iconColor: AppColors.warning),
                            _MetricItem(icon: Icons.access_time_filled_rounded, label: '6 Weeks', subLabel: 'Duration', iconColor: AppColors.blue),
                            _MetricItem(icon: Icons.play_lesson_rounded, label: '12 Chapters', subLabel: 'Modules', iconColor: AppColors.primary),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      // ── Description ──────────────────────────────────────
                      Text(
                        'About this course',
                        style: textTheme.titleMedium?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        course.description,
                        style: textTheme.bodyMedium?.copyWith(
                          fontSize: 14,
                          height: 1.6,
                          color: AppColors.textSecondary,
                        ),
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      // ── Instructor Card ──────────────────────────────────
                      Text(
                        'Your Instructor',
                        style: textTheme.titleMedium?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppRadius.medium),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            Container(
                              height: 48,
                              width: 48,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: AppTheme.avatarGradient,
                              ),
                              alignment: Alignment.center,
                              child: const Text(
                                'AS',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Dr. Alan Smith',
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Senior Software Engineer & Educator',
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      // ── Lock/Enrollment Action State ───────────────────────
                      _buildActionSection(context, course),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.primaryGradient,
      ),
      child: const Icon(Icons.menu_book_rounded, size: 80, color: Colors.white24),
    );
  }

  Widget _buildActionSection(BuildContext context, dynamic course) {
    final role = context.read<UserProvider>().role;
    final isFacultyOrAdmin = role == 'faculty' || role == 'admin';
    final enrollment = context.watch<EnrollmentProvider>();
    final isEnrolled = enrollment.isEnrolled;

    if (isFacultyOrAdmin) {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => EditCourseScreen(courseId: course.id)),
                );
              },
              icon: const Icon(Icons.edit_document),
              label: const Text('Edit Course Details'),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FacultyLessonManagementScreen(
                      courseId: course.id,
                      courseTitle: course.title,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              icon: const Icon(Icons.video_call_rounded, color: Colors.white),
              label: const Text('Manage Recorded Classes', style: TextStyle(color: Colors.white)),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => FacultyExamManagementScreen(courseId: course.id)),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.blue),
              icon: const Icon(Icons.quiz_rounded, color: Colors.white),
              label: const Text('Manage Exams', style: TextStyle(color: Colors.white)),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Delete Course?'),
                    content: const Text('This will permanently delete the course and all its materials.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                      FilledButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        style: FilledButton.styleFrom(backgroundColor: AppColors.error),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );

                if (confirm == true && mounted) {
                  try {
                    await CourseService.deleteCourse(course.id);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Course deleted successfully')));
                      Navigator.pop(context); // Go back after deletion
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
                    }
                  }
                }
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error, width: 1.5),
              ),
              icon: const Icon(Icons.delete_outline),
              label: const Text('Delete Course'),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: () => _onWatchLessons(context),
              icon: const Icon(Icons.play_circle_outline),
              label: const Text('Preview Course Lessons'),
            ),
          ),
        ],
      );
    }

    // Student View
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!course.isFree && !isEnrolled)
          Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.pastelYellow,
              borderRadius: BorderRadius.circular(AppRadius.medium),
              border: Border.all(color: AppColors.warning.withOpacity(0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.lock_person_rounded, color: AppColors.secondary),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    'Enroll to unlock all modules and resources.',
                    style: TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        
        if (isEnrolled) ...[
          const Center(
            child: Text('🎉 You are enrolled in this course!', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 15)),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildActionBtn(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => NotesScreen(courseId: course.id))),
            icon: Icons.sticky_note_2_rounded,
            label: 'Open Course Materials',
            isPrimary: true,
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildActionBtn(
            onPressed: () => _onWatchLessons(context),
            icon: Icons.play_circle_filled_rounded,
            label: 'Watch Course Lessons',
            isPrimary: false,
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildActionBtn(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ExamListScreen(
                    courseId: course.id,
                    courseTitle: course.title,
                  ),
                ),
              );
            },
            icon: Icons.assignment_rounded,
            label: 'Take Exams',
            isPrimary: false,
          ),
        ] else if (enrollment.isLoading) ...[
          const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary)))
        ] else ...[
          _buildActionBtn(
            onPressed: () async {
              if (course.isFree) {
                await context.read<EnrollmentProvider>().enroll(course.id);
              } else {
                final success = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => MockPaymentScreen(course: course)),
                );
                if (success == true && mounted) {
                  // Enrollment is handled in MockPaymentScreen
                }
              }
            },
            icon: course.isFree ? Icons.school_rounded : Icons.shopping_bag_rounded,
            label: course.isFree ? 'Enroll Now for Free' : 'Purchase Course',
            isPrimary: true,
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildActionBtn(
            onPressed: () => _onWatchLessons(context),
            icon: Icons.play_circle_filled_rounded,
            label: 'Preview Course Lessons',
            isPrimary: false,
          ),
        ],
      ],
    );
  }

  Widget _buildActionBtn({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required bool isPrimary,
  }) {
    return SizedBox(
      height: 52,
      child: isPrimary
          ? ElevatedButton.icon(
              onPressed: onPressed,
              icon: Icon(icon),
              label: Text(label),
            )
          : OutlinedButton.icon(
              onPressed: onPressed,
              icon: Icon(icon),
              label: Text(label),
            ),
    );
  }
}

class _MetricItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subLabel;
  final Color iconColor;

  const _MetricItem({
    required this.icon,
    required this.label,
    required this.subLabel,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 24),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
        ),
        Text(
          subLabel,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
