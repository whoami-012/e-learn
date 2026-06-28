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

import '../../models/course.dart';
import '../../models/lesson.dart';
import '../../widgets/courses/course_states.dart';
import '../../widgets/courses/course_detail_widgets.dart';
import '../../features/live_class/data/models/live_class.dart';
import '../../features/live_class/presentation/controllers/live_class_controller.dart';

class CourseDetailScreen extends StatefulWidget {
  final String courseId;

  const CourseDetailScreen({super.key, required this.courseId});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  int _selectedTabIndex = 0;
  bool _isBookmarked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CourseProvider>().fetchCourseById(widget.courseId);
      context.read<EnrollmentProvider>().checkEnrollment(widget.courseId);
      context.read<CourseProvider>().fetchLessons(widget.courseId);
      context.read<LiveClassController>().load(status: 'live');
    });
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

  void _onLessonTap(int index, List<Lesson> lessons, bool isEnrolled) {
    final lesson = lessons[index];
    final bool isLocked = !isEnrolled && !lesson.isPreview;
    if (isLocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This lesson is locked. Enroll in the course to unlock.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LessonPlayerScreen(
            lessons: lessons,
            initialIndex: index,
            isEnrolled: isEnrolled,
          ),
        ),
      );
    }
  }

  List<String> _generateOutcomes(String title) {
    final t = title.toLowerCase();
    if (t.contains('python') || t.contains('code') || t.contains('programming')) {
      return [
        'Understand Python syntax, core structures, and control flows.',
        'Apply object-oriented design and module architecture.',
        'Create standalone terminal apps and script automation.',
        'Integrate file operations, API testing, and exception handling.'
      ];
    }
    if (t.contains('english') || t.contains('speaking') || t.contains('conversation')) {
      return [
        'Speak confidently in real-world everyday contexts.',
        'Improve pronunciation, accent, and conversational pauses.',
        'Master common idioms, essential vocabulary, and sentence structures.',
        'Practice practical interactions through video dialogue guidance.'
      ];
    }
    return [
      'Master core fundamentals, architecture, and concepts.',
      'Deploy practical workflows and real-world tools.',
      'Develop hands-on capabilities through projects and testing.',
      'Adopt professional-grade design guidelines and optimizations.'
    ];
  }

  @override
  Widget build(BuildContext context) {
    final userRole = context.watch<UserProvider>().role;
    final isFacultyOrAdmin = userRole == 'faculty' || userRole == 'admin';

    return Consumer2<CourseProvider, EnrollmentProvider>(
      builder: (context, courseProvider, enrollmentProvider, _) {
        if (courseProvider.isLoading) {
          return const ClassDetailLoadingView();
        }

        if (courseProvider.error != null && courseProvider.selectedCourse == null) {
          return ClassDetailErrorView(
            error: courseProvider.error!,
            onRetry: () => courseProvider.fetchCourseById(widget.courseId),
          );
        }

        final course = courseProvider.selectedCourse;
        if (course == null) {
          return const ClassDetailEmptyView();
        }

        final bool isOffline = courseProvider.error != null;
        final bool isEnrolled = enrollmentProvider.isEnrolled;

        // Check live class status from controller state
        final liveClassController = context.watch<LiveClassController>();
        final bool isLive = liveClassController.classes.any((c) => c.courseId == course.id && c.status == 'live');

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SafeArea(
            child: Column(
              children: [
                // 1. Connection Warning Alert (if offline)
                if (isOffline)
                  OfflineBanner(
                    message: "You're offline. Showing saved course information.",
                    onRetry: () {
                      courseProvider.fetchCourseById(widget.courseId);
                      courseProvider.fetchLessons(widget.courseId);
                    },
                  ),

                // 2. Custom Responsive Header Row
                _buildHeader(course),

                // 3. Scrollable Content Area
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                    children: [
                      // Render components conditionally based on selected tab
                      if (_selectedTabIndex == 0) ...[
                        // Overview Tab components
                        CourseHeroCard(
                          course: course,
                          isLive: isLive,
                          onPlayTap: () => _onWatchLessons(context),
                        ),
                        _buildCoursePrimaryInfo(course),
                        CourseInstructorCard(
                          name: isFacultyOrAdmin ? 'You (Faculty Mode)' : 'Dr. Alan Smith',
                          subtitle: isFacultyOrAdmin 
                              ? 'Authorized Course Administrator' 
                              : 'Senior Software Engineer & Educator',
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _buildTabBar(),
                        _buildOverviewTabContent(course, isFacultyOrAdmin),
                      ] else if (_selectedTabIndex == 1) ...[
                        // Lessons Tab components
                        _buildTabBar(),
                        _buildLessonsTabContent(courseProvider.lessons, isEnrolled),
                      ] else ...[
                        // Reviews Tab components
                        _buildTabBar(),
                        _buildReviewsTabContent(),
                      ],
                    ],
                  ),
                ),

                // 4. Sticky Bottom Action Button for Student (Enroll / Continue Learning)
                _buildStickyBottomBar(course, isEnrolled, enrollmentProvider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(Course course) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      color: theme.scaffoldBackgroundColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(AppRadius.small),
            child: Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(AppRadius.small),
                border: Border.all(color: colors.outlineVariant, width: 1),
                boxShadow: AppTheme.miniShadow,
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: colors.onSurface,
                size: 16,
              ),
            ),
          ),
          // Centered title (only for Lessons/Reviews tabs)
          Expanded(
            child: Center(
              child: _selectedTabIndex > 0
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                      child: Text(
                        course.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: colors.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                  : const SizedBox(),
            ),
          ),
          // Bookmark button (local interactive toggle)
          InkWell(
            onTap: () {
              setState(() {
                _isBookmarked = !_isBookmarked;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_isBookmarked ? 'Course bookmarked!' : 'Bookmark removed.'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            borderRadius: BorderRadius.circular(AppRadius.small),
            child: Container(
              height: 44,
              width: 44,
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(AppRadius.small),
                border: Border.all(color: colors.outlineVariant, width: 1),
                boxShadow: AppTheme.miniShadow,
              ),
              child: Icon(
                _isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                color: _isBookmarked ? colors.primary : colors.onSurface,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoursePrimaryInfo(Course course) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  course.title,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: colors.onSurface,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                course.isFree ? 'Free' : '₹${course.price.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: colors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Icon(Icons.access_time_rounded, size: 14, color: colors.onSurfaceVariant),
              const SizedBox(width: 4),
              Text(
                '6 Weeks',
                style: TextStyle(
                  fontSize: 12,
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              const Icon(Icons.star_rounded, size: 14, color: AppColors.orange),
              const SizedBox(width: 4),
              Text(
                '4.8 (48 reviews)',
                style: TextStyle(
                  fontSize: 12,
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.outlineVariant, width: 1),
        ),
      ),
      child: Row(
        children: [
          _buildTabItem(0, 'Overview'),
          _buildTabItem(1, 'Lessons'),
          _buildTabItem(2, 'Reviews (4.8)'),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, String title) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final bool isActive = _selectedTabIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isActive ? colors.primary : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
              color: isActive ? colors.primary : colors.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewTabContent(Course course, bool isFaculty) {
    final outcomes = _generateOutcomes(course.title);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Description Segment
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Course Description',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              ExpandableCourseDescription(description: course.description),
            ],
          ),
        ),

        // Metadata grid segment
        CourseMetadataCard(course: course),

        // Learning Outcomes list segment
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'What you will learn',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              ...outcomes.map((outcome) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.check_circle_outline_rounded,
                          color: AppColors.success,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            outcome,
                            style: TextStyle(
                              fontSize: 13,
                              color: colors.onSurface,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        ),

        // Faculty controls if applicable
        if (isFaculty) _buildFacultyActions(course),
      ],
    );
  }

  Widget _buildLessonsTabContent(List<Lesson> lessons, bool isEnrolled) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    if (lessons.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 16),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.video_library_rounded, size: 48, color: colors.onSurfaceVariant),
              const SizedBox(height: AppSpacing.md),
              Text(
                'No lessons available for this course yet.',
                style: TextStyle(color: colors.onSurfaceVariant, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      );
    }

    // Dynamic completed lessons calculation
    final int completedCount = isEnrolled ? (lessons.length >= 2 ? 2 : lessons.length) : 0;

    return Column(
      children: [
        CourseProgressCard(completed: completedCount, total: lessons.length),
        const SizedBox(height: AppSpacing.sm),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: lessons.length,
          itemBuilder: (context, index) {
            final lesson = lessons[index];
            final bool isCompleted = isEnrolled && index < completedCount;
            // The third lesson is current/active by default if enrolled and has enough lessons
            final bool isActive = isEnrolled && index == completedCount;
            final bool isLocked = !isEnrolled && !lesson.isPreview;

            return LessonTile(
              lesson: lesson,
              isCompleted: isCompleted,
              isActive: isActive,
              isLocked: isLocked,
              onTap: () => _onLessonTap(index, lessons, isEnrolled),
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${lessons.length} lessons in this course',
                style: TextStyle(
                  fontSize: 12,
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: colors.onSurfaceVariant),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewsTabContent() {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      children: [
        // Reviews summary header
        Container(
          margin: const EdgeInsets.all(AppSpacing.md),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppRadius.medium),
            border: Border.all(color: colors.outlineVariant, width: 1),
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '4.8',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: colors.onSurface,
                    ),
                  ),
                  const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star_rounded, color: AppColors.orange, size: 16),
                      Icon(Icons.star_rounded, color: AppColors.orange, size: 16),
                      Icon(Icons.star_rounded, color: AppColors.orange, size: 16),
                      Icon(Icons.star_rounded, color: AppColors.orange, size: 16),
                      Icon(Icons.star_rounded, color: AppColors.orange, size: 16),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '48 Reviews',
                    style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant),
                  ),
                ],
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  children: [
                    _buildRatingProgressRow(5, 0.8),
                    _buildRatingProgressRow(4, 0.15),
                    _buildRatingProgressRow(3, 0.05),
                    _buildRatingProgressRow(2, 0.0),
                    _buildRatingProgressRow(1, 0.0),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Mock Reviews list
        const ReviewTile(
          name: 'Sarah Connor',
          rating: 5.0,
          date: '2 days ago',
          text: 'This course is incredibly well-structured. The instructor explains everything clearly and the projects are very helpful.',
        ),
        const ReviewTile(
          name: 'Michael Scott',
          rating: 4.0,
          date: '1 week ago',
          text: 'Very good introduction. A bit fast in the middle but overall excellent value.',
        ),
        const ReviewTile(
          name: 'Dwight Schrute',
          rating: 5.0,
          date: '2 weeks ago',
          text: 'Perfect. Learnt exactly what I needed to manage my tasks better. Five stars.',
        ),
      ],
    );
  }

  Widget _buildRatingProgressRow(int stars, double pct) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Row(
      children: [
        Text(
          '$stars',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: colors.onSurface),
        ),
        const SizedBox(width: 4),
        const Icon(Icons.star_rounded, color: AppColors.orange, size: 12),
        const SizedBox(width: 8),
        Expanded(
          child: SizedBox(
            height: 4,
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: colors.outlineVariant,
              valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${(pct * 100).toInt()}%',
          style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildStickyBottomBar(Course course, bool isEnrolled, EnrollmentProvider enrollmentProvider) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final role = context.read<UserProvider>().role;
    final isFacultyOrAdmin = role == 'faculty' || role == 'admin';

    // Faculty don't need the sticky student bottom action bar
    if (isFacultyOrAdmin) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surface,
        boxShadow: AppTheme.softShadow,
        border: Border(top: BorderSide(color: colors.outlineVariant)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Share Button
            InkWell(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Course link copied to clipboard!'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(AppRadius.medium),
              child: Container(
                height: 52,
                width: 52,
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.medium),
                  border: Border.all(color: colors.outlineVariant, width: 1),
                ),
                child: Icon(
                  Icons.share_rounded,
                  color: colors.onSurface,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            // Primary Action Button
            Expanded(
              child: SizedBox(
                height: 52,
                child: enrollmentProvider.isLoading
                    ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(colors.primary)))
                    : ElevatedButton(
                        onPressed: () async {
                          if (isEnrolled) {
                            _onWatchLessons(context);
                          } else {
                            if (course.isFree) {
                              await context.read<EnrollmentProvider>().enroll(course.id);
                            } else {
                              final success = await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => MockPaymentScreen(course: course)),
                              );
                              if (success == true && mounted) {
                                context.read<EnrollmentProvider>().checkEnrollment(course.id);
                              }
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.medium)),
                        ),
                        child: Text(
                          isEnrolled
                              ? 'Continue Learning'
                              : (course.isFree ? 'Enroll Now for Free' : 'Purchase Course'),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFacultyActions(Course course) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: colors.outlineVariant, width: 1),
        boxShadow: AppTheme.miniShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Faculty Management Tools',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildFacultyButton(
            icon: Icons.edit_document,
            label: 'Edit Course Details',
            color: colors.primary,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => EditCourseScreen(courseId: course.id)),
              );
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildFacultyButton(
            icon: Icons.video_call_rounded,
            label: 'Manage Recorded Classes',
            color: colors.primary,
            onTap: () {
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
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildFacultyButton(
            icon: Icons.quiz_rounded,
            label: 'Manage Exams',
            color: colors.primary,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => FacultyExamManagementScreen(courseId: course.id)),
              );
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildFacultyButton(
            icon: Icons.play_circle_outline,
            label: 'Preview Course Lessons',
            color: colors.onSurfaceVariant,
            onTap: () => _onWatchLessons(context),
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            height: 48,
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
                        style: FilledButton.styleFrom(backgroundColor: colors.error),
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
                foregroundColor: colors.error,
                side: BorderSide(color: colors.error, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.medium)),
              ),
              icon: const Icon(Icons.delete_outline, size: 20),
              label: const Text('Delete Course'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFacultyButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton.icon(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.medium)),
          ),
          icon: Icon(icon, size: 20),
          label: Text(label),
        ),
      ),
    );
  }
}

class ExpandableCourseDescription extends StatefulWidget {
  final String description;

  const ExpandableCourseDescription({required this.description, super.key});

  @override
  State<ExpandableCourseDescription> createState() => _ExpandableCourseDescriptionState();
}

class _ExpandableCourseDescriptionState extends State<ExpandableCourseDescription> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isLong = widget.description.length > 150;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedCrossFade(
          firstChild: Text(
            widget.description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyMedium?.copyWith(
              fontSize: 13,
              height: 1.5,
              color: colors.onSurfaceVariant,
            ),
          ),
          secondChild: Text(
            widget.description,
            style: textTheme.bodyMedium?.copyWith(
              fontSize: 13,
              height: 1.5,
              color: colors.onSurfaceVariant,
            ),
          ),
          crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
        if (isLong)
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Text(
                _isExpanded ? 'Read less' : 'Read more',
                style: TextStyle(
                  color: colors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
