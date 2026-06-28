import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/course_provider.dart';
import '../../providers/user_provider.dart';
import '../../theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../models/course.dart';
import '../../widgets/courses/course_list_card.dart';
import '../../widgets/courses/course_list_skeleton.dart';
import '../../widgets/courses/course_states.dart';
import '../../widgets/courses/course_widgets.dart';
import '../../widgets/dashboard/app_bottom_navigation.dart';
import '../calendar/calendar_screen.dart';
import '../messages/message_screen.dart';
import '../profile/profile_screen.dart';
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

  // ── Course Data Mappings & Fallbacks ────────────────────────────────────────

  String _getStudentCountLabel(Course course) {
    // Generate a stable, premium mock count based on the course ID hash
    final hash = course.id.hashCode.abs();
    final count = (hash % 1200) + 180;
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K students';
    }
    return '$count students';
  }

  String _getDurationLabel(Course course) {
    // Generate a stable mock duration based on title length
    final durationWeeks = (course.title.length % 5) + 4;
    return '$durationWeeks weeks';
  }

  String _getCategoryLabel(Course course) {
    // Parse category based on keywords in the course title
    final title = course.title.toLowerCase();
    if (title.contains('python') || title.contains('programming') || title.contains('coding') || title.contains('java') || title.contains('c++')) {
      return 'Programming';
    } else if (title.contains('web') || title.contains('flask') || title.contains('html') || title.contains('development') || title.contains('django')) {
      return 'Web Development';
    } else if (title.contains('cyber') || title.contains('security') || title.contains('hack') || title.contains('network')) {
      return 'Cybersecurity';
    } else if (title.contains('design') || title.contains('ui') || title.contains('ux') || title.contains('figma') || title.contains('graphic')) {
      return 'Design';
    } else if (title.contains('data') || title.contains('analytics') || title.contains('science') || title.contains('machine')) {
      return 'Data Science';
    }
    return 'General';
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final isFaculty = userProvider.isFaculty || userProvider.isAdmin;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1117) : const Color(0xFFF7F8FC),
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
              label: const Text(
                'New Course',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Plus Jakarta Sans',
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
            )
          : null,
      bottomNavigationBar: SafeArea(
        child: AppBottomNavigation(
          currentIndex: 1, // Courses tab is active
          onTap: (index) {
            if (index == 1) return; // Already on this tab
            if (index == 0) {
              Navigator.pop(context); // Pop back to Home Dashboard
              return;
            }
            if (index == 2) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const CalendarScreen()),
              );
              return;
            }
            if (index == 3) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const MessageScreen()),
              );
              return;
            }
            if (index == 4) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
              return;
            }
          },
        ),
      ),
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

          return SafeArea(
            bottom: false,
            child: RefreshIndicator(
              onRefresh: () => provider.fetchCourses(),
              color: AppColors.primary,
              backgroundColor: Colors.white,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isTablet = constraints.maxWidth >= 700;
                  final double horizontalPadding = isTablet ? 32.0 : 20.0;

                  return CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    slivers: [
                      // ── 1. Modern Header ──
                      SliverToBoxAdapter(
                        child: CourseScreenHeader(
                          onActionTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Explore course topics and enroll to start learning.'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                        ),
                      ),

                      // ── 2. Rounded Search Field ──
                      SliverToBoxAdapter(
                        child: CourseSearchField(
                          controller: _searchController,
                          onChanged: (val) {
                            setState(() {
                              _searchQuery = val;
                            });
                          },
                          onClear: () {
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        ),
                      ),

                      // ── 3. Filter Pill Chips ──
                      SliverToBoxAdapter(
                        child: CourseFilterBar(
                          selectedFilter: _selectedFilter,
                          onFilterChanged: (filter) {
                            setState(() {
                              _selectedFilter = filter;
                            });
                          },
                        ),
                      ),

                      // ── 4. Offline Connection Banner (above cached list) ──
                      if (provider.error != null && provider.courses.isNotEmpty)
                        SliverPadding(
                          padding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding,
                            vertical: 8.0,
                          ),
                          sliver: SliverToBoxAdapter(
                            child: OfflineBanner(
                              message: "You're offline. Showing saved course information.",
                              onRetry: () => provider.fetchCourses(),
                            ),
                          ),
                        ),

                      const SliverToBoxAdapter(child: SizedBox(height: 12)),

                      // ── 5. Main Content Area (Lists / Grids / Skeletons / Errors) ──
                      SliverPadding(
                        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                        sliver: _buildMainContent(provider, filteredCourses, isTablet),
                      ),

                      // Bottom layout spacer to clear floating bottom navigation
                      const SliverToBoxAdapter(
                        child: SizedBox(height: 130.0),
                      ),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMainContent(CourseProvider provider, List<Course> filteredCourses, bool isTablet) {
    // 1. Loading State
    if (provider.isLoading) {
      return const SliverToBoxAdapter(
        child: CourseListSkeleton(),
      );
    }

    // 2. Full Error State (Connection failed with no local cache)
    if (provider.error != null && provider.courses.isEmpty) {
      return SliverToBoxAdapter(
        child: CourseErrorState(
          title: 'Unable to load courses',
          description: 'Check your connection and try again.',
          onRetry: () => provider.fetchCourses(),
        ),
      );
    }

    // 3. Empty States
    if (filteredCourses.isEmpty) {
      if (_searchQuery.isNotEmpty) {
        return SliverToBoxAdapter(
          child: CourseEmptyState(
            title: 'No courses found',
            description: 'Try another course name or clear your filters.',
            icon: Icons.search_off_rounded,
            actionText: 'Clear search',
            onActionTap: () {
              _searchController.clear();
              setState(() {
                _searchQuery = '';
              });
            },
          ),
        );
      } else if (_selectedFilter == 'Free') {
        return SliverToBoxAdapter(
          child: CourseEmptyState(
            title: 'No free courses available',
            description: 'Try viewing all courses or check again later.',
            icon: Icons.money_off_rounded,
            actionText: 'View all courses',
            onActionTap: () {
              setState(() {
                _selectedFilter = 'All';
              });
            },
          ),
        );
      } else if (_selectedFilter == 'Paid') {
        return SliverToBoxAdapter(
          child: CourseEmptyState(
            title: 'No paid courses available',
            description: 'Try viewing all courses or check again later.',
            icon: Icons.payments_outlined,
            actionText: 'View all courses',
            onActionTap: () {
              setState(() {
                _selectedFilter = 'All';
              });
            },
          ),
        );
      } else {
        return SliverToBoxAdapter(
          child: CourseEmptyState(
            title: 'No courses available',
            description: 'New courses will appear here when they are published.',
            icon: Icons.auto_stories_rounded,
            actionText: 'Refresh',
            onActionTap: () => provider.fetchCourses(),
          ),
        );
      }
    }

    // 4. Normal course grid/list
    final itemCount = filteredCourses.length;

    if (isTablet) {
      return SliverGrid(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 480,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          mainAxisExtent: 145, // exact height to display Card elements properly
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final course = filteredCourses[index];
            return _buildCourseCard(course);
          },
          childCount: itemCount,
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final course = filteredCourses[index];
          return _buildCourseCard(course);
        },
        childCount: itemCount,
      ),
    );
  }

  Widget _buildCourseCard(Course course) {
    final category = _getCategoryLabel(course);
    final categoryStyle = CourseCategoryStyle.fromCategory(category);
    final studentCountLabel = _getStudentCountLabel(course);
    final durationLabel = _getDurationLabel(course);

    String? fullImageUrl;
    if (course.thumbnailUrl != null && course.thumbnailUrl!.trim().isNotEmpty) {
      final path = course.thumbnailUrl!;
      if (path.startsWith('http')) {
        fullImageUrl = path;
      } else {
        final cleanPath = path.startsWith('/') ? path.substring(1) : path;
        fullImageUrl = '${AppConstants.serverBase}/$cleanPath';
      }
    }

    return CourseListCard(
      title: course.title,
      imageUrl: fullImageUrl,
      studentCountLabel: studentCountLabel,
      durationLabel: durationLabel,
      categoryLabel: category,
      categoryStyle: categoryStyle,
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CourseDetailScreen(courseId: course.id),
        ),
      ).then((_) {
        if (mounted) context.read<CourseProvider>().fetchCourses();
      }),
    );
  }
}
