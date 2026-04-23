import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/course_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/course_card.dart';
import 'course_detail_screen.dart';
import 'create_course_screen.dart';

class CourseListScreen extends StatefulWidget {
  const CourseListScreen({super.key});

  @override
  State<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch courses after first frame to allow Provider to be ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CourseProvider>().fetchCourses();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isFaculty = context.watch<UserProvider>().isFaculty ||
        context.watch<UserProvider>().isAdmin;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Courses',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
      ),
      // ── FAB: only visible to faculty/admin ──────────────────────────────────
      floatingActionButton: isFaculty
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const CreateCourseScreen()),
              ),
              icon: const Icon(Icons.add),
              label: const Text('New Course'),
            )
          : null,
      body: Consumer<CourseProvider>(
        builder: (context, provider, _) {
          // ── Loading ──────────────────────────────────────────────────────────
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // ── Error ────────────────────────────────────────────────────────────
          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.wifi_off_rounded,
                      size: 48, color: Colors.grey.shade300),
                  const SizedBox(height: 12),
                  Text(provider.error!,
                      style: TextStyle(color: Colors.grey.shade500)),
                  const SizedBox(height: 16),
                  FilledButton.tonal(
                    onPressed: () => provider.fetchCourses(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // ── Empty ────────────────────────────────────────────────────────────
          if (provider.courses.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.auto_stories_rounded,
                      size: 48, color: Colors.grey.shade300),
                  const SizedBox(height: 12),
                  Text('No courses available yet.',
                      style: TextStyle(color: Colors.grey.shade500)),
                ],
              ),
            );
          }

          // ── List ─────────────────────────────────────────────────────────────
          return RefreshIndicator(
            onRefresh: () => provider.fetchCourses(),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: provider.courses.length,
              itemBuilder: (context, index) {
                final course = provider.courses[index];
                return CourseCard(
                  course: course,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          CourseDetailScreen(courseId: course.id),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
