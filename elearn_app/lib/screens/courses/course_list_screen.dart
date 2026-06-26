import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/course_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/course_card.dart';
import '../../theme/app_theme.dart';
import 'course_detail_screen.dart';
import 'create_course_screen.dart';

class CourseListScreen extends StatefulWidget {
  const CourseListScreen({super.key});

  @override
  State<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen> {
  final _searchController = TextEditingController();
  String _selectedFilter = 'All'; // 'All', 'Free', 'Paid'
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CourseProvider>().fetchCourses();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final isFaculty = userProvider.isFaculty || userProvider.isAdmin;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Explore Courses'),
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: const Border(bottom: BorderSide(color: AppColors.border)),
      ),
      floatingActionButton: isFaculty
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateCourseScreen()),
              ).then((_) {
                if (mounted) context.read<CourseProvider>().fetchCourses();
              }),
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('New Course', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.medium)),
            )
          : null,
      body: Consumer<CourseProvider>(
        builder: (context, provider, _) {
          // Filtered list based on search query and category chips
          final filteredCourses = provider.courses.where((course) {
            final matchesSearch = course.title.toLowerCase().contains(_searchQuery.toLowerCase());
            final matchesFilter = _selectedFilter == 'All' ||
                (_selectedFilter == 'Free' && course.isFree) ||
                (_selectedFilter == 'Paid' && !course.isFree);
            return matchesSearch && matchesFilter;
          }).toList();

          return Column(
            children: [
              // Search and Filter Bar Header
              Container(
                color: AppColors.surface,
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  children: [
                    // Search text field
                    TextField(
                      controller: _searchController,
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search by course name...',
                        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, color: AppColors.textSecondary),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                },
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    // Category Chips (All, Free, Paid)
                    Row(
                      children: ['All', 'Free', 'Paid'].map((filter) {
                        final isSelected = _selectedFilter == filter;
                        return Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.sm),
                          child: ChoiceChip(
                            label: Text(filter),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _selectedFilter = filter;
                                });
                              }
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Builder(
                  builder: (context) {
                    // Loading State
                    if (provider.isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                      );
                    }

                    // Error State
                    if (provider.error != null) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(AppSpacing.lg),
                                decoration: const BoxDecoration(
                                  color: AppColors.pastelPink,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.wifi_off_rounded,
                                  size: 40,
                                  color: AppColors.error,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                'Connection Failed',
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                provider.error!,
                                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              ElevatedButton(
                                onPressed: () => provider.fetchCourses(),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                ),
                                child: const Text('Try Again'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    // Empty State
                    if (filteredCourses.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(AppSpacing.lg),
                                decoration: const BoxDecoration(
                                  color: AppColors.pastelPurple,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.auto_stories_rounded,
                                  size: 40,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Text(
                                'No courses found',
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                _searchQuery.isNotEmpty
                                    ? "We couldn't find any courses matching your search query."
                                    : "There are no courses listed in this category right now.",
                                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    // Normal course list
                    return RefreshIndicator(
                      onRefresh: () => provider.fetchCourses(),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: filteredCourses.length,
                        itemBuilder: (context, index) {
                          final course = filteredCourses[index];
                          return CourseCard(
                            course: course,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CourseDetailScreen(courseId: course.id),
                              ),
                            ).then((_) {
                              if (mounted) context.read<CourseProvider>().fetchCourses();
                            }),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
