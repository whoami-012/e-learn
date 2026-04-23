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
      builder: (_) => const Center(child: CircularProgressIndicator()),
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
    final color = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Consumer<CourseProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline_rounded,
                      size: 48, color: Colors.grey.shade300),
                  const SizedBox(height: 12),
                  Text(provider.error!),
                  const SizedBox(height: 12),
                  FilledButton.tonal(
                    onPressed: () =>
                        provider.fetchCourseById(widget.courseId),
                    child: const Text('Retry'),
                  ),
                ],
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
                expandedHeight: 300,
                pinned: true,
                elevation: 0,
                backgroundColor: AppTheme.indigoAccent,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.black.withOpacity(0.24),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: const [StretchMode.zoomBackground],
                  titlePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  title: Text(
                    course.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [Shadow(color: Colors.black.withOpacity(0.45), blurRadius: 8)],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
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
                              Colors.black.withOpacity(0.38),
                              Colors.transparent,
                              Colors.black.withOpacity(0.87),
                            ],
                            stops: const [0.0, 0.4, 1.0],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── 2. Course Content Section ──────────────────────────────────
              SliverToBoxAdapter(
                child: Transform.translate(
                  offset: const Offset(0, -20),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppTheme.background,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXL)),
                    ),
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Price Badge & Category ───────────────────────────
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: course.isFree ? Colors.green.shade50 : AppTheme.indigoAccent.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                course.isFree ? '🎓 FREE' : '₹${course.price.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: course.isFree ? Colors.green.shade700 : AppTheme.indigoAccent,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Development', // Placeholder category
                                style: AppTheme.bodySmall.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // ── Description ──────────────────────────────────────
                        const Text('About this course', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Text(
                          course.description,
                          style: AppTheme.bodySmall.copyWith(fontSize: 15, height: 1.6, color: Colors.grey.shade700),
                        ),

                        const SizedBox(height: 32),

                        // ── Lock/Enrollment State ───────────────────────────
                        _buildActionSection(context, course),
                      ],
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
            height: 56,
            child: FilledButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => EditCourseScreen(courseId: course.id)),
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.indigoAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusLG)),
              ),
              icon: const Icon(Icons.edit_document),
              label: const Text('Edit Course Details', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton.icon(
              onPressed: () => _onWatchLessons(context),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.indigoAccent, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusLG)),
              ),
              icon: const Icon(Icons.play_circle_outline, color: AppTheme.indigoAccent),
              label: const Text('Preview Course Lessons', style: TextStyle(color: AppTheme.indigoAccent, fontWeight: FontWeight.bold)),
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
            margin: const EdgeInsets.only(bottom: 24),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(AppTheme.radiusMD),
              border: Border.all(color: Colors.amber.shade100),
            ),
            child: Row(
              children: [
                Icon(Icons.lock_person_rounded, color: Colors.amber.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Enroll to unlock all modules and resources.',
                    style: TextStyle(color: Colors.amber.shade900, fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        
        if (isEnrolled) ...[
          const Center(
            child: Text('🎉 You are enrolled!', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          const SizedBox(height: 16),
          _buildActionBtn(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => NotesScreen(courseId: course.id))),
            icon: Icons.sticky_note_2_rounded,
            label: 'Open Course Materials',
            isPrimary: true,
          ),
          const SizedBox(height: 12),
          _buildActionBtn(
            onPressed: () => _onWatchLessons(context),
            icon: Icons.play_circle_filled_rounded,
            label: 'Watch Course Lessons',
            isPrimary: false,
          ),
        ] else if (enrollment.isLoading) ...[
          const Center(child: CircularProgressIndicator())
        ] else ...[
          _buildActionBtn(
            onPressed: () async {
              if (course.isFree) {
                await context.read<EnrollmentProvider>().enroll(course.id);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment system coming soon!')));
              }
            },
            icon: course.isFree ? Icons.school_rounded : Icons.shopping_bag_rounded,
            label: course.isFree ? 'Enroll Now for Free' : 'Purchase Course',
            isPrimary: true,
          ),
          const SizedBox(height: 12),
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
      height: 56,
      child: isPrimary
          ? FilledButton.icon(
              onPressed: onPressed,
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.indigoAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusLG)),
              ),
              icon: Icon(icon),
              label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            )
          : OutlinedButton.icon(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.indigoAccent, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusLG)),
              ),
              icon: Icon(icon, color: AppTheme.indigoAccent),
              label: Text(label, style: const TextStyle(color: AppTheme.indigoAccent, fontWeight: FontWeight.bold)),
            ),
    );
  }
}
