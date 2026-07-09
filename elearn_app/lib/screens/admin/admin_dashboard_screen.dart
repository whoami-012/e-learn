import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/auth/role_route.dart';
import '../../providers/admin_provider.dart';
import '../../providers/course_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/message_provider.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../auth/login_screen.dart';
import '../../features/dashboard/presentation/screens/teacher_faculty_dashboard_screen.dart';
import '../home/home_screen.dart';
import '../courses/course_list_screen.dart';
import '../courses/course_detail_screen.dart';
import '../messages/message_screen.dart';
import '../profile/profile_screen.dart';
import '../../models/course.dart';
import '../../widgets/dashboard/app_bottom_navigation.dart';

class AdminDashboardColors {
  static const primaryPurple = Color(0xFF5B35F5);
  static const deepNavy = Color(0xFF07133D);
  static const pageBackground = Color(0xFFF9F9FD);
  static const surface = Color(0xFFFFFFFF);
  static const softLavender = Color(0xFFF4F1FF);
  static const mutedText = Color(0xFF68708A);
  static const border = Color(0xFFE8E9F1);
  static const warning = Color(0xFFFF8A2A);
  static const danger = Color(0xFFFF4267);
  static const success = Color(0xFF22B66F);
  static const info = Color(0xFF3478F6);
}

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _navIndex = 0;
  String _searchQuery = '';
  String _roleFilter = 'all'; // 'all', 'student', 'faculty', 'admin'
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchUsers();
      context.read<CourseProvider>().fetchCourses();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    await Future.wait([
      context.read<AdminProvider>().fetchUsers(),
      context.read<CourseProvider>().fetchCourses(),
    ]);
  }

  // ── Role Dialogue (Preserved from original) ──────────────────────────────────
  void _showRoleDialog(UserProfile user) {
    String selectedRole = user.role;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Change Role for ${user.name}'),
        content: DropdownButtonFormField<String>(
          initialValue: selectedRole,
          items: const [
            DropdownMenuItem(value: 'student', child: Text('Student')),
            DropdownMenuItem(value: 'faculty', child: Text('Faculty')),
            DropdownMenuItem(value: 'admin', child: Text('Admin')),
          ],
          onChanged: (val) {
            if (val != null) selectedRole = val;
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await context
                    .read<AdminProvider>()
                    .updateUserRole(user.id, selectedRole);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Role updated successfully')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed: $e')),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // ── Announcement Creation Dialog ─────────────────────────────────────────────
  void _showAnnouncementDialog() {
    final titleController = TextEditingController();
    final bodyController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create Announcement'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'Enter announcement title',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: bodyController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Message',
                hintText: 'Enter announcement message',
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
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content:
                      Text('Announcement posted successfully to all users!'),
                  backgroundColor: AdminDashboardColors.success,
                ),
              );
            },
            child: const Text('Post'),
          ),
        ],
      ),
    );
  }

  // ── User Filter Bottom Sheet ─────────────────────────────────────────────────
  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.all(24),
          child: RadioGroup<String>(
            groupValue: _roleFilter,
            onChanged: (val) {
              if (val != null) {
                setState(() => _roleFilter = val);
                Navigator.pop(context);
              }
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Filter Users by Role',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color:
                        isDark ? Colors.white : AdminDashboardColors.deepNavy,
                  ),
                ),
                const SizedBox(height: 16),
                const ListTile(
                  title: Text('All Users'),
                  leading: Radio<String>(
                    value: 'all',
                  ),
                ),
                const ListTile(
                  title: Text('Students'),
                  leading: Radio<String>(
                    value: 'student',
                  ),
                ),
                const ListTile(
                  title: Text('Faculty'),
                  leading: Radio<String>(
                    value: 'faculty',
                  ),
                ),
                const ListTile(
                  title: Text('Admins'),
                  leading: Radio<String>(
                    value: 'admin',
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Bottom Nav Tap Handler ───────────────────────────────────────────────────
  void _onNavTap(int index) {
    if (index == 0 || index == 1) {
      setState(() => _navIndex = index);
      return;
    }
    final routes = {
      2: () => const CourseListScreen(),
      3: () => const MessageScreen(),
      4: () => const ProfileScreen(),
    };
    final builder = routes[index];
    if (builder == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => builder()),
    ).then((_) {
      if (mounted) setState(() => _navIndex = 0);
    });
    setState(() => _navIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final admin = context.watch<UserProvider>().user;
    if (!canAccessAdmin(admin?.role)) {
      final redirect = switch (resolveHomeRoute(admin?.role)) {
        AppHomeRoute.faculty => const TeacherFacultyDashboardScreen(),
        AppHomeRoute.student => const HomeScreen(),
        _ => const LoginScreen(),
      };
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => redirect),
            (_) => false,
          );
        }
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final adminProvider = context.watch<AdminProvider>();
    final courseProvider = context.watch<CourseProvider>();
    final messageProvider = context.watch<MessageProvider>();

    if (admin == null) {
      return Scaffold(
        backgroundColor: isDark
            ? const Color(0xFF0F1117)
            : AdminDashboardColors.pageBackground,
        body: const SafeArea(child: AdminDashboardLoadingView()),
      );
    }

    // Filter users list locally based on query & role filter
    final filteredUsers = adminProvider.users.where((user) {
      final matchesSearch =
          user.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              user.email.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesRole =
          _roleFilter == 'all' || user.role.toLowerCase() == _roleFilter;
      return matchesSearch && matchesRole;
    }).toList();

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0F1117)
          : AdminDashboardColors.pageBackground,
      bottomNavigationBar: SafeArea(
        child: AppBottomNavigation(
          currentIndex: _navIndex,
          onTap: _onNavTap,
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AdminDashboardColors.primaryPurple,
          onRefresh: _refresh,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 720;
              final contentWidth = isWide ? 720.0 : constraints.maxWidth;

              return Center(
                child: SizedBox(
                  width: contentWidth,
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. Offline Banner
                            if (messageProvider.isOffline)
                              const AdminDashboardOfflineBanner(),

                            // 2. Admin Header
                            AdminDashboardHeader(
                              user: admin,
                              unreadNotifications:
                                  messageProvider.totalUnreadCount,
                              onNotificationTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const MessageScreen()),
                              ),
                              onSettingsTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const ProfileScreen()),
                              ),
                            ),

                            // 3. Search Bar
                            AdminDashboardSearchBar(
                              controller: _searchController,
                              onChanged: (val) {
                                setState(() => _searchQuery = val);
                                if (_navIndex == 0 && val.isNotEmpty) {
                                  // Switch to Users directory tab automatically when search query starts typing
                                  setState(() => _navIndex = 1);
                                }
                              },
                              onFilterTap: _showFilterSheet,
                            ),
                            const SizedBox(height: 16),

                            // Display appropriate Tab based on _navIndex
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: _navIndex == 1
                                  ? _buildUserDirectoryView(
                                      adminProvider, filteredUsers)
                                  : _buildMainDashboardView(
                                      adminProvider,
                                      courseProvider,
                                      messageProvider,
                                    ),
                            ),
                            const SizedBox(
                                height: 100), // Bottom padding for nav bar
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ── 1. Main Dashboard View Tab ───────────────────────────────────────────────
  Widget _buildMainDashboardView(
    AdminProvider adminProvider,
    CourseProvider courseProvider,
    MessageProvider messageProvider,
  ) {
    if (adminProvider.isLoading || courseProvider.isLoading) {
      return const AdminDashboardLoadingView();
    }

    if (adminProvider.error != null) {
      return AdminDashboardErrorView(
        message: adminProvider.error!,
        onRetry: _refresh,
      );
    }

    final totalUsers = adminProvider.users.length;
    final totalCourses = courseProvider.courses.length;
    final facultyCount =
        adminProvider.users.where((u) => u.role == 'faculty').length;
    final studentCount =
        adminProvider.users.where((u) => u.role == 'student').length;

    return Column(
      key: const ValueKey('main_dashboard'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Quick Actions
        AdminQuickActions(
          onManageUsers: () => setState(() => _navIndex = 1),
          onApproveCourses: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CourseListScreen()),
          ),
          onReports: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MessageScreen()),
          ),
          onAnnouncements: _showAnnouncementDialog,
        ),
        const SizedBox(height: 20),

        // Platform Overview Card
        PlatformOverviewCard(
          totalUsers: totalUsers,
          totalCourses: totalCourses,
          facultyCount: facultyCount,
          studentCount: studentCount,
        ),
        const SizedBox(height: 16),

        // Admin Insight Banner
        const AdminInsightBanner(),
        const SizedBox(height: 20),

        // Today's Priorities Section
        AdminPrioritiesSection(
          totalUsers: totalUsers,
          totalCourses: totalCourses,
          onUserAction: () => setState(() => _navIndex = 1),
          onCourseAction: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CourseListScreen()),
          ),
        ),
        const SizedBox(height: 20),

        // Needs Attention Section
        AdminAttentionSection(
          facultyCount: facultyCount,
          totalCourses: totalCourses,
          onFacultyTap: () {
            setState(() {
              _roleFilter = 'faculty';
              _navIndex = 1;
            });
          },
          onCoursesTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CourseListScreen()),
          ),
        ),
        const SizedBox(height: 20),

        // Recent Activity Section
        RecentAdminActivitySection(
          users: adminProvider.users.take(3).toList(),
          courses: courseProvider.courses.take(3).toList(),
          onManageUser: _showRoleDialog,
          onReviewCourse: (course) => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CourseDetailScreen(courseId: course.id),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Platform Performance Card
        PlatformPerformanceCard(
          totalUsers: totalUsers,
          facultyCount: facultyCount,
          studentCount: studentCount,
          totalCourses: totalCourses,
        ),
      ],
    );
  }

  // ── 2. User Directory View Tab ───────────────────────────────────────────────
  Widget _buildUserDirectoryView(
    AdminProvider provider,
    List<UserProfile> filteredList,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimaryColor =
        isDark ? Colors.white : AdminDashboardColors.deepNavy;

    return Padding(
      key: const ValueKey('user_directory'),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'User Directory',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textPrimaryColor,
                ),
              ),
              if (_roleFilter != 'all')
                Chip(
                  label: Text('Role: ${_roleFilter.toUpperCase()}'),
                  onDeleted: () => setState(() => _roleFilter = 'all'),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (provider.isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(
                    color: AdminDashboardColors.primaryPurple),
              ),
            )
          else if (filteredList.isEmpty)
            const AdminDashboardEmptyView(
                message: 'No users match your criteria')
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredList.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final user = filteredList[index];
                return RecentAdminActivityTile(
                  title: user.name,
                  subtitle: user.email,
                  role: user.role,
                  imageUrl: user.profileImage,
                  actionLabel: 'Manage',
                  onActionPressed: () => _showRoleDialog(user),
                  onDeletePressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Delete User?'),
                        content: Text(
                            'This will permanently delete ${user.name} from the system.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancel'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            style: FilledButton.styleFrom(
                              backgroundColor: AdminDashboardColors.danger,
                            ),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true && context.mounted) {
                      final scaffoldMessenger = ScaffoldMessenger.of(context);
                      try {
                        await provider.deleteUser(user.id);
                      } catch (e) {
                        scaffoldMessenger.showSnackBar(
                          SnackBar(content: Text('Failed: $e')),
                        );
                      }
                    }
                  },
                );
              },
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

// ── Admin Dashboard Header ───────────────────────────────────────────────────
class AdminDashboardHeader extends StatelessWidget {
  final UserProfile user;
  final int unreadNotifications;
  final VoidCallback onNotificationTap;
  final VoidCallback onSettingsTap;

  const AdminDashboardHeader({
    super.key,
    required this.user,
    required this.unreadNotifications,
    required this.onNotificationTap,
    required this.onSettingsTap,
  });

  static String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimaryColor =
        isDark ? Colors.white : AdminDashboardColors.deepNavy;
    final initials = user.name
        .trim()
        .split(' ')
        .take(2)
        .map((w) => w.isNotEmpty ? w[0] : '')
        .join()
        .toUpperCase();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AdminDashboardColors.primaryPurple
                      .withValues(alpha: 0.18),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: user.profileImage != null && user.profileImage!.isNotEmpty
                  ? Image.network(
                      user.profileImage!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          _InitialsAvatar(initials: initials),
                    )
                  : _InitialsAvatar(initials: initials),
            ),
          ),
          const SizedBox(width: 12),

          // Greeting
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${_greeting()}, ${user.name.split(' ').first}',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: textPrimaryColor,
                    letterSpacing: -0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                const Text(
                  'Platform Administrator',
                  style: TextStyle(
                    fontSize: 13,
                    color: AdminDashboardColors.mutedText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Notification Action
          _AdminIconButton(
            icon: Icons.notifications_outlined,
            onTap: onNotificationTap,
            badge: unreadNotifications > 0,
          ),
          const SizedBox(width: 8),

          // Settings Action
          _AdminIconButton(
            icon: Icons.settings_outlined,
            onTap: onSettingsTap,
          ),
        ],
      ),
    );
  }
}

class _InitialsAvatar extends StatelessWidget {
  final String initials;
  const _InitialsAvatar({required this.initials});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AdminDashboardColors.primaryPurple, Color(0xFF7C5CFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        initials.isNotEmpty ? initials : '?',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}

class _AdminIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool badge;

  const _AdminIconButton({
    required this.icon,
    required this.onTap,
    this.badge = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        isDark ? const Color(0xFF181B23) : AdminDashboardColors.surface;
    final borderColor =
        isDark ? const Color(0xFF303542) : AdminDashboardColors.border;
    final iconColor = isDark ? Colors.white : AdminDashboardColors.deepNavy;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
              boxShadow: isDark ? null : AppTheme.miniShadow,
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 20, color: iconColor),
          ),
          if (badge)
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: AdminDashboardColors.danger,
                  shape: BoxShape.circle,
                  border: Border.all(color: bgColor, width: 1.5),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Search Bar ───────────────────────────────────────────────────────────────
class AdminDashboardSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onFilterTap;

  const AdminDashboardSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final containerColor =
        isDark ? const Color(0xFF181B23) : AdminDashboardColors.surface;
    final borderColor =
        isDark ? const Color(0xFF303542) : AdminDashboardColors.border;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: containerColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor),
          boxShadow: isDark ? null : AppTheme.softShadow,
        ),
        child: Row(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 14),
              child: Icon(
                Icons.search_rounded,
                color: AdminDashboardColors.mutedText,
                size: 22,
              ),
            ),
            Expanded(
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                style: TextStyle(
                  color: isDark ? Colors.white : AdminDashboardColors.deepNavy,
                  fontSize: 14,
                ),
                decoration: const InputDecoration(
                  hintText: 'Search users, email directory...',
                  hintStyle: TextStyle(
                    color: AdminDashboardColors.mutedText,
                    fontSize: 14,
                  ),
                  fillColor: Colors.transparent,
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            Semantics(
              label: 'Filter users list',
              button: true,
              child: IconButton(
                icon: const Icon(
                  Icons.filter_list_rounded,
                  color: AdminDashboardColors.primaryPurple,
                  size: 22,
                ),
                onPressed: onFilterTap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Quick Actions Grid ────────────────────────────────────────────────────────
class AdminQuickActions extends StatelessWidget {
  final VoidCallback onManageUsers;
  final VoidCallback onApproveCourses;
  final VoidCallback onReports;
  final VoidCallback onAnnouncements;

  const AdminQuickActions({
    super.key,
    required this.onManageUsers,
    required this.onApproveCourses,
    required this.onReports,
    required this.onAnnouncements,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 360;
          if (isNarrow) {
            return SizedBox(
              height: 84,
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildCard(
                    context: context,
                    icon: Icons.people_alt_rounded,
                    label: 'Manage Users',
                    color: AdminDashboardColors.warning,
                    bgColor: const Color(0xFFFFECE0),
                    onTap: onManageUsers,
                  ),
                  const SizedBox(width: 8),
                  _buildCard(
                    context: context,
                    icon: Icons.menu_book_rounded,
                    label: 'Courses',
                    color: AdminDashboardColors.primaryPurple,
                    bgColor: AdminDashboardColors.softLavender,
                    onTap: onApproveCourses,
                  ),
                  const SizedBox(width: 8),
                  _buildCard(
                    context: context,
                    icon: Icons.analytics_outlined,
                    label: 'Reports',
                    color: AdminDashboardColors.info,
                    bgColor: const Color(0xFFE8F1FF),
                    onTap: onReports,
                  ),
                  const SizedBox(width: 8),
                  _buildCard(
                    context: context,
                    icon: Icons.campaign_rounded,
                    label: 'Announce',
                    color: AdminDashboardColors.danger,
                    bgColor: const Color(0xFFFFECEF),
                    onTap: onAnnouncements,
                  ),
                ],
              ),
            );
          }

          return GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 4,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1.0,
            children: [
              _buildCard(
                context: context,
                icon: Icons.people_alt_rounded,
                label: 'Users',
                color: AdminDashboardColors.warning,
                bgColor: const Color(0xFFFFECE0),
                onTap: onManageUsers,
              ),
              _buildCard(
                context: context,
                icon: Icons.menu_book_rounded,
                label: 'Courses',
                color: AdminDashboardColors.primaryPurple,
                bgColor: AdminDashboardColors.softLavender,
                onTap: onApproveCourses,
              ),
              _buildCard(
                context: context,
                icon: Icons.analytics_outlined,
                label: 'Reports',
                color: AdminDashboardColors.info,
                bgColor: const Color(0xFFE8F1FF),
                onTap: onReports,
              ),
              _buildCard(
                context: context,
                icon: Icons.campaign_rounded,
                label: 'Announce',
                color: AdminDashboardColors.danger,
                bgColor: const Color(0xFFFFECEF),
                onTap: onAnnouncements,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? color.withValues(alpha: 0.12) : bgColor;

    return Semantics(
      label: label,
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? color.withValues(alpha: 0.3)
                  : color.withValues(alpha: 0.12),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white24,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : color,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Platform Overview Card ───────────────────────────────────────────────────
class PlatformOverviewCard extends StatelessWidget {
  final int totalUsers;
  final int totalCourses;
  final int facultyCount;
  final int studentCount;

  const PlatformOverviewCard({
    super.key,
    required this.totalUsers,
    required this.totalCourses,
    required this.facultyCount,
    required this.studentCount,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg =
        isDark ? const Color(0xFF181B23) : AdminDashboardColors.surface;
    final titleColor = isDark ? Colors.white : AdminDashboardColors.deepNavy;
    final borderColor =
        isDark ? const Color(0xFF303542) : AdminDashboardColors.border;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: borderColor),
          boxShadow: isDark ? null : AppTheme.softShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Platform Overview',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: titleColor,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AdminDashboardColors.softLavender,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.auto_awesome,
                          color: AdminDashboardColors.primaryPurple, size: 12),
                      SizedBox(width: 4),
                      Text(
                        'Live Analytics',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AdminDashboardColors.primaryPurple,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 420;

                if (isNarrow) {
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: PlatformMetricItem(
                              value: totalUsers.toString(),
                              label: 'Total Users',
                              icon: Icons.people_outline,
                              color: AdminDashboardColors.primaryPurple,
                              bgColor: AdminDashboardColors.softLavender,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: PlatformMetricItem(
                              value: totalCourses.toString(),
                              label: 'Active Courses',
                              icon: Icons.library_books_outlined,
                              color: AdminDashboardColors.success,
                              bgColor: const Color(0xFFE2F7EF),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: PlatformMetricItem(
                              value: facultyCount.toString(),
                              label: 'Faculty',
                              icon: Icons.badge_outlined,
                              color: AdminDashboardColors.info,
                              bgColor: const Color(0xFFE8F1FF),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: PlatformMetricItem(
                              value: studentCount.toString(),
                              label: 'Students',
                              icon: Icons.school_outlined,
                              color: AdminDashboardColors.warning,
                              bgColor: const Color(0xFFFFECE0),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(
                      child: PlatformMetricItem(
                        value: totalUsers.toString(),
                        label: 'Total Users',
                        icon: Icons.people_outline,
                        color: AdminDashboardColors.primaryPurple,
                        bgColor: AdminDashboardColors.softLavender,
                      ),
                    ),
                    Expanded(
                      child: PlatformMetricItem(
                        value: totalCourses.toString(),
                        label: 'Active Courses',
                        icon: Icons.library_books_outlined,
                        color: AdminDashboardColors.success,
                        bgColor: const Color(0xFFE2F7EF),
                      ),
                    ),
                    Expanded(
                      child: PlatformMetricItem(
                        value: facultyCount.toString(),
                        label: 'Faculty',
                        icon: Icons.badge_outlined,
                        color: AdminDashboardColors.info,
                        bgColor: const Color(0xFFE8F1FF),
                      ),
                    ),
                    Expanded(
                      child: PlatformMetricItem(
                        value: studentCount.toString(),
                        label: 'Students',
                        icon: Icons.school_outlined,
                        color: AdminDashboardColors.warning,
                        bgColor: const Color(0xFFFFECE0),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class PlatformMetricItem extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;
  final Color bgColor;

  const PlatformMetricItem({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final displayBg = isDark ? color.withValues(alpha: 0.15) : bgColor;

    return Semantics(
      label: '$label is $value',
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: displayBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AdminDashboardColors.deepNavy,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AdminDashboardColors.mutedText,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ── Admin Insight Banner ─────────────────────────────────────────────────────
class AdminInsightBanner extends StatelessWidget {
  const AdminInsightBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final containerColor =
        isDark ? const Color(0xFF1E1E2C) : const Color(0xFFF0EDFF);
    final textColor =
        isDark ? Colors.white : AdminDashboardColors.primaryPurple;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: containerColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AdminDashboardColors.primaryPurple.withValues(alpha: 0.12),
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.bolt_rounded,
              color: AdminDashboardColors.primaryPurple,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'LearnFlow core server connectivity is optimized & fully synchronized.',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Today's Priorities ───────────────────────────────────────────────────────
class AdminPrioritiesSection extends StatelessWidget {
  final int totalUsers;
  final int totalCourses;
  final VoidCallback onUserAction;
  final VoidCallback onCourseAction;

  const AdminPrioritiesSection({
    super.key,
    required this.totalUsers,
    required this.totalCourses,
    required this.onUserAction,
    required this.onCourseAction,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimaryColor =
        isDark ? Colors.white : AdminDashboardColors.deepNavy;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Today's Priorities",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textPrimaryColor,
                ),
              ),
              Text(
                'High Priority',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AdminDashboardColors.danger.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 600;

              final uCard = AdminPriorityCard(
                title: 'User Management',
                status: '$totalUsers Accounts',
                description:
                    'Review and update user roles or clean inactive directory.',
                actionLabel: 'Manage Now',
                icon: Icons.manage_accounts_rounded,
                accentColor: AdminDashboardColors.warning,
                bgColor: const Color(0xFFFFECE0),
                onAction: onUserAction,
              );

              final cCard = AdminPriorityCard(
                title: 'Course Catalog',
                status: '$totalCourses Published',
                description:
                    'Verify current list of uploaded lectures and courses.',
                actionLabel: 'Inspect Catalog',
                icon: Icons.library_books_rounded,
                accentColor: AdminDashboardColors.primaryPurple,
                bgColor: AdminDashboardColors.softLavender,
                onAction: onCourseAction,
              );

              if (isNarrow) {
                return Column(
                  children: [
                    uCard,
                    const SizedBox(height: 12),
                    cCard,
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: uCard),
                  const SizedBox(width: 12),
                  Expanded(child: cCard),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class AdminPriorityCard extends StatelessWidget {
  final String title;
  final String status;
  final String description;
  final String actionLabel;
  final IconData icon;
  final Color accentColor;
  final Color bgColor;
  final VoidCallback onAction;

  const AdminPriorityCard({
    super.key,
    required this.title,
    required this.status,
    required this.description,
    required this.actionLabel,
    required this.icon,
    required this.accentColor,
    required this.bgColor,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg =
        isDark ? const Color(0xFF181B23) : AdminDashboardColors.surface;
    final titleColor = isDark ? Colors.white : AdminDashboardColors.deepNavy;
    final borderColor =
        isDark ? const Color(0xFF303542) : AdminDashboardColors.border;
    final iconBg = isDark ? accentColor.withValues(alpha: 0.15) : bgColor;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: isDark ? null : AppTheme.miniShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: accentColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: titleColor,
                      ),
                    ),
                    Text(
                      status,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(
              fontSize: 12,
              color: AdminDashboardColors.mutedText,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 38,
            child: ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                actionLabel,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Needs Attention Section ──────────────────────────────────────────────────
class AdminAttentionSection extends StatelessWidget {
  final int facultyCount;
  final int totalCourses;
  final VoidCallback onFacultyTap;
  final VoidCallback onCoursesTap;

  const AdminAttentionSection({
    super.key,
    required this.facultyCount,
    required this.totalCourses,
    required this.onFacultyTap,
    required this.onCoursesTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimaryColor =
        isDark ? Colors.white : AdminDashboardColors.deepNavy;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Needs Attention',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textPrimaryColor,
            ),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 600;

              final facultyCard = AdminAttentionCard(
                count: facultyCount.toString(),
                label: 'Faculty Members',
                subtitle: 'Active teacher directory',
                icon: Icons.people_outline_rounded,
                color: AdminDashboardColors.primaryPurple,
                onTap: onFacultyTap,
              );

              final coursesCard = AdminAttentionCard(
                count: totalCourses.toString(),
                label: 'System Catalog',
                subtitle: 'Total published classes',
                icon: Icons.grid_view_rounded,
                color: AdminDashboardColors.info,
                onTap: onCoursesTap,
              );

              if (isNarrow) {
                return Column(
                  children: [
                    facultyCard,
                    const SizedBox(height: 10),
                    coursesCard,
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: facultyCard),
                  const SizedBox(width: 12),
                  Expanded(child: coursesCard),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class AdminAttentionCard extends StatelessWidget {
  final String count;
  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const AdminAttentionCard({
    super.key,
    required this.count,
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg =
        isDark ? const Color(0xFF181B23) : AdminDashboardColors.surface;
    final borderColor =
        isDark ? const Color(0xFF303542) : AdminDashboardColors.border;

    return Semantics(
      label: '$count attention items for $label',
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
            boxShadow: isDark ? null : AppTheme.miniShadow,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? Colors.white
                            : AdminDashboardColors.deepNavy,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                          fontSize: 11, color: AdminDashboardColors.mutedText),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  count,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: isDark ? Colors.grey : AdminDashboardColors.mutedText,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Recent Activity Section ──────────────────────────────────────────────────
class RecentAdminActivitySection extends StatelessWidget {
  final List<UserProfile> users;
  final List<Course> courses;
  final Function(UserProfile) onManageUser;
  final Function(Course) onReviewCourse;

  const RecentAdminActivitySection({
    super.key,
    required this.users,
    required this.courses,
    required this.onManageUser,
    required this.onReviewCourse,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimaryColor =
        isDark ? Colors.white : AdminDashboardColors.deepNavy;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Admin Activity',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textPrimaryColor,
            ),
          ),
          const SizedBox(height: 12),
          if (users.isEmpty && courses.isEmpty)
            const AdminDashboardEmptyView(message: 'No recent activity to show')
          else ...[
            // Render Courses Activity
            if (courses.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.only(bottom: 8, top: 4),
                child: Text(
                  'RECENT COURSE PUBLISHES',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AdminDashboardColors.mutedText,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: courses.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final course = courses[index];
                  return RecentAdminActivityTile(
                    title: course.title,
                    subtitle:
                        'Published: ${course.isFree ? "Free Lecture" : "Paid Class"}',
                    role: 'Course',
                    imageUrl: course.thumbnailUrl,
                    actionLabel: 'Review',
                    onActionPressed: () => onReviewCourse(course),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],

            // Render Users Activity
            if (users.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  'RECENT USER REGISTRATIONS',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AdminDashboardColors.mutedText,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: users.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final user = users[index];
                  return RecentAdminActivityTile(
                    title: user.name,
                    subtitle: user.email,
                    role: user.role,
                    imageUrl: user.profileImage,
                    actionLabel: 'Manage',
                    onActionPressed: () => onManageUser(user),
                  );
                },
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class RecentAdminActivityTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String role;
  final String? imageUrl;
  final String actionLabel;
  final VoidCallback onActionPressed;
  final VoidCallback? onDeletePressed;

  const RecentAdminActivityTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.role,
    this.imageUrl,
    required this.actionLabel,
    required this.onActionPressed,
    this.onDeletePressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg =
        isDark ? const Color(0xFF181B23) : AdminDashboardColors.surface;
    final titleColor = isDark ? Colors.white : AdminDashboardColors.deepNavy;
    final borderColor =
        isDark ? const Color(0xFF303542) : AdminDashboardColors.border;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: isDark ? null : AppTheme.miniShadow,
      ),
      child: Row(
        children: [
          // Icon/Thumbnail placeholder
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AdminDashboardColors.softLavender,
              shape: role.toLowerCase() == 'course'
                  ? BoxShape.rectangle
                  : BoxShape.circle,
              borderRadius: role.toLowerCase() == 'course'
                  ? BorderRadius.circular(8)
                  : null,
            ),
            child: ClipRRect(
              borderRadius: role.toLowerCase() == 'course'
                  ? BorderRadius.circular(8)
                  : BorderRadius.circular(22),
              child: imageUrl != null && imageUrl!.isNotEmpty
                  ? Image.network(imageUrl!, fit: BoxFit.cover)
                  : Center(
                      child: Icon(
                        role.toLowerCase() == 'course'
                            ? Icons.library_books_rounded
                            : Icons.person_rounded,
                        color: AdminDashboardColors.primaryPurple,
                        size: 20,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),

          // Title & Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: titleColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    AdminStatusBadge(status: role),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AdminDashboardColors.mutedText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Primary action
          TextButton(
            onPressed: onActionPressed,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              minimumSize: const Size(60, 32),
            ),
            child: Text(
              actionLabel,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),

          // Optional delete button
          if (onDeletePressed != null)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded,
                  color: AdminDashboardColors.danger, size: 20),
              onPressed: onDeletePressed,
              tooltip: 'Delete User',
            ),
        ],
      ),
    );
  }
}

// ── Reusable Status Badge ────────────────────────────────────────────────────
class AdminStatusBadge extends StatelessWidget {
  final String status;

  const AdminStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg = AdminDashboardColors.softLavender;
    Color fg = AdminDashboardColors.primaryPurple;

    switch (status.toLowerCase()) {
      case 'admin':
        bg = const Color(0xFFF0EDFF);
        fg = AdminDashboardColors.primaryPurple;
        break;
      case 'faculty':
      case 'teacher':
        bg = const Color(0xFFFFECE0);
        fg = AdminDashboardColors.warning;
        break;
      case 'student':
        bg = const Color(0xFFE2F7EF);
        fg = AdminDashboardColors.success;
        break;
      case 'course':
        bg = const Color(0xFFE8F1FF);
        fg = AdminDashboardColors.info;
        break;
      case 'high priority':
        bg = const Color(0xFFFFECEF);
        fg = AdminDashboardColors.danger;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: fg,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// ── Platform Performance Card ────────────────────────────────────────────────
class PlatformPerformanceCard extends StatelessWidget {
  final int totalUsers;
  final int facultyCount;
  final int studentCount;
  final int totalCourses;

  const PlatformPerformanceCard({
    super.key,
    required this.totalUsers,
    required this.facultyCount,
    required this.studentCount,
    required this.totalCourses,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg =
        isDark ? const Color(0xFF181B23) : AdminDashboardColors.surface;
    final titleColor = isDark ? Colors.white : AdminDashboardColors.deepNavy;
    final borderColor =
        isDark ? const Color(0xFF303542) : AdminDashboardColors.border;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: borderColor),
          boxShadow: isDark ? null : AppTheme.softShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Platform Performance',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: titleColor,
                  ),
                ),
                Text(
                  'This Week',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AdminDashboardColors.primaryPurple
                        .withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 420;

                final cRate = _PerformanceMetric(
                  label: 'Uptime Status',
                  value: '99.9%',
                  icon: Icons.cloud_done_rounded,
                  color: AdminDashboardColors.success,
                );

                final growth = _PerformanceMetric(
                  label: 'Active Ratio',
                  value: totalUsers > 0
                      ? '${((studentCount / totalUsers) * 100).toStringAsFixed(0)}%'
                      : '0%',
                  icon: Icons.trending_up_rounded,
                  color: AdminDashboardColors.primaryPurple,
                );

                final courseAvg = _PerformanceMetric(
                  label: 'Avg. Price',
                  value: 'Free/Paid',
                  icon: Icons.local_offer_outlined,
                  color: AdminDashboardColors.info,
                );

                final ticketCount = _PerformanceMetric(
                  label: 'Active Chats',
                  value: 'Online',
                  icon: Icons.chat_bubble_outline_rounded,
                  color: AdminDashboardColors.warning,
                );

                if (isNarrow) {
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: cRate),
                          const SizedBox(width: 8),
                          Expanded(child: growth),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: courseAvg),
                          const SizedBox(width: 8),
                          Expanded(child: ticketCount),
                        ],
                      ),
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: cRate),
                    Expanded(child: growth),
                    Expanded(child: courseAvg),
                    Expanded(child: ticketCount),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _PerformanceMetric extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _PerformanceMetric({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Semantics(
      label: '$label metric is $value',
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AdminDashboardColors.deepNavy,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AdminDashboardColors.mutedText,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ── Loading Skeletons ────────────────────────────────────────────────────────
class AdminDashboardLoadingView extends StatelessWidget {
  const AdminDashboardLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(20.0),
      child: Column(
        children: [
          SizedBox(height: 20),
          LinearProgressIndicator(
              color: AdminDashboardColors.primaryPurple, minHeight: 4),
          SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _SkeletonCircle(size: 48),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SkeletonLine(width: 140, height: 16),
                      SizedBox(height: 6),
                      _SkeletonLine(width: 80, height: 12),
                    ],
                  ),
                ),
              ),
              _SkeletonRect(width: 40, height: 40),
            ],
          ),
          SizedBox(height: 32),
          _SkeletonRect(width: double.infinity, height: 48),
          SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  child: _SkeletonRect(width: double.infinity, height: 80)),
              SizedBox(width: 12),
              Expanded(
                  child: _SkeletonRect(width: double.infinity, height: 80)),
              SizedBox(width: 12),
              Expanded(
                  child: _SkeletonRect(width: double.infinity, height: 80)),
            ],
          ),
          SizedBox(height: 24),
          _SkeletonRect(width: double.infinity, height: 160),
        ],
      ),
    );
  }
}

class _SkeletonLine extends StatelessWidget {
  final double width;
  final double height;

  const _SkeletonLine({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? Colors.white10 : Colors.black12;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class _SkeletonCircle extends StatelessWidget {
  final double size;

  const _SkeletonCircle({required this.size});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? Colors.white10 : Colors.black12;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _SkeletonRect extends StatelessWidget {
  final double width;
  final double height;

  const _SkeletonRect({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? Colors.white10 : Colors.black12;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

// ── Empty States ─────────────────────────────────────────────────────────────
class AdminDashboardEmptyView extends StatelessWidget {
  final String message;

  const AdminDashboardEmptyView({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.info_outline_rounded,
              size: 48,
              color: AdminDashboardColors.mutedText,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: AdminDashboardColors.mutedText,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Error View ───────────────────────────────────────────────────────────────
class AdminDashboardErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const AdminDashboardErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 54,
              color: AdminDashboardColors.danger,
            ),
            const SizedBox(height: 14),
            Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AdminDashboardColors.danger,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Offline Banner ───────────────────────────────────────────────────────────
class AdminDashboardOfflineBanner extends StatelessWidget {
  const AdminDashboardOfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AdminDashboardColors.danger,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off_rounded, color: Colors.white, size: 16),
          SizedBox(width: 8),
          Text(
            'You are offline. Showing cached information.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
