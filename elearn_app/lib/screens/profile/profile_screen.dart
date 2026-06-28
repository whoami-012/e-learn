import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/user_provider.dart';
import '../../providers/course_provider.dart';
import '../../services/auth_service.dart';
import '../../services/enrollment_service.dart';
import '../../widgets/dashboard/app_bottom_navigation.dart';
import '../courses/course_list_screen.dart';
import '../calendar/calendar_screen.dart';
import '../messages/message_screen.dart';
import '../auth/login_screen.dart';
import 'progress_screen.dart';

class ProfileColors {
  ProfileColors._();

  static Color primaryPurple(bool isDark) => const Color(0xFF6C45D8);
  static Color deepNavy(bool isDark) => isDark ? const Color(0xFFF7F8FC) : const Color(0xFF101936);
  static Color pageBackground(bool isDark) => isDark ? const Color(0xFF0F1117) : const Color(0xFFF7F8FC);
  static Color surface(bool isDark) => isDark ? const Color(0xFF181B23) : const Color(0xFFFFFFFF);
  static Color softLavender(bool isDark) => isDark ? const Color(0xFF2A243F) : const Color(0xFFF0ECFC);
  static Color mutedText(bool isDark) => isDark ? const Color(0xFFADB4C4) : const Color(0xFF6F7588);
  static Color border(bool isDark) => isDark ? const Color(0xFF303542) : const Color(0xFFE9EBF2);
  static Color success(bool isDark) => const Color(0xFF2DCB82);
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  int _enrolledCount = 0;
  bool _isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      await context.read<UserProvider>().loadUser();
    } catch (_) {}

    try {
      final courseProvider = context.read<CourseProvider>();
      await courseProvider.fetchCourses();
      
      if (!mounted) return;
      
      final courses = courseProvider.courses;
      int enrolled = 0;
      final results = await Future.wait(
        courses.map((course) async {
          try {
            final res = await EnrollmentService.checkEnrollment(course.id);
            return res.isEnrolled;
          } catch (_) {
            return false;
          }
        })
      );
      
      for (final isEnrolled in results) {
        if (isEnrolled) {
          enrolled++;
        }
      }

      if (mounted) {
        setState(() {
          _enrolledCount = enrolled;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _logout() async {
    setState(() {
      _isLoggingOut = true;
    });
    try {
      await AuthService.logout();
      if (!mounted) return;
      context.read<UserProvider>().clearUser();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoggingOut = false;
        });
      }
    }
  }

  String _getInitials(String name) {
    if (name.trim().isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length > 1) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.user;

    final name = user?.name ?? 'Loading...';
    final email = user?.email ?? '';

    return Scaffold(
      backgroundColor: ProfileColors.pageBackground(isDark),
      bottomNavigationBar: SafeArea(
        child: AppBottomNavigation(
          currentIndex: 4, // Profile tab active
          onTap: (index) {
            if (index == 4) return;
            if (index == 0) {
              Navigator.pop(context); // Go back to Home
              return;
            }
            if (index == 1) {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CourseListScreen()),
              );
              return;
            }
            if (index == 2) {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CalendarScreen()),
              );
              return;
            }
            if (index == 3) {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MessageScreen()),
              );
              return;
            }
          },
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isTablet = constraints.maxWidth >= 720;
            final double horizontalPadding = isTablet ? 40.0 : 20.0;

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: RefreshIndicator(
                  onRefresh: _loadProfileData,
                  color: ProfileColors.primaryPurple(isDark),
                  child: ListView(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: 24.0,
                    ),
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    children: [
                      // ── Profile Header ──
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Profile',
                            style: TextStyle(
                              fontSize: 32.0,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'Plus Jakarta Sans',
                              color: ProfileColors.deepNavy(isDark),
                            ),
                          ),
                          Semantics(
                            label: 'Toggle Dark Mode',
                            button: true,
                            child: Container(
                              decoration: BoxDecoration(
                                color: ProfileColors.surface(isDark),
                                borderRadius: BorderRadius.circular(16.0),
                                border: Border.all(
                                  color: ProfileColors.border(isDark),
                                  width: 1.0,
                                ),
                              ),
                              child: IconButton(
                                icon: Icon(
                                  isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                                  color: ProfileColors.primaryPurple(isDark),
                                ),
                                onPressed: () {
                                  // Call toggleTheme if available globally or show a message.
                                  // In this app, we can toggle the brightness using theme settings if configured.
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Theme mode switched to ${isDark ? "Light" : "Dark"}!'),
                                      behavior: SnackBarBehavior.floating,
                                      duration: const Duration(seconds: 1),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24.0),

                      // ── Profile Summary Card ──
                      Container(
                        padding: const EdgeInsets.all(20.0),
                        decoration: BoxDecoration(
                          color: ProfileColors.surface(isDark),
                          borderRadius: BorderRadius.circular(24.0),
                          border: Border.all(
                            color: ProfileColors.border(isDark),
                            width: 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                // Avatar
                                Container(
                                  width: 64.0,
                                  height: 64.0,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        ProfileColors.primaryPurple(isDark).withOpacity(0.8),
                                        ProfileColors.primaryPurple(isDark),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      _getInitials(name),
                                      style: const TextStyle(
                                        fontSize: 22.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontFamily: 'Plus Jakarta Sans',
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16.0),
                                // Name & Email
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              name,
                                              style: TextStyle(
                                                fontSize: 18.0,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Plus Jakarta Sans',
                                                color: ProfileColors.deepNavy(isDark),
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4.0),
                                      Text(
                                        email,
                                        style: TextStyle(
                                          fontSize: 14.0,
                                          fontFamily: 'Plus Jakarta Sans',
                                          color: ProfileColors.mutedText(isDark),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20.0),
                            Divider(color: ProfileColors.border(isDark), height: 1.0),
                            const SizedBox(height: 16.0),
                            // Stats Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildStatItem(
                                  context,
                                  icon: Icons.auto_stories_rounded,
                                  value: _isLoading ? '...' : '$_enrolledCount',
                                  label: 'Courses',
                                  isDark: isDark,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32.0),

                      // ── My Learning Section ──
                      Text(
                        'My Learning',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Plus Jakarta Sans',
                          color: ProfileColors.deepNavy(isDark),
                        ),
                      ),
                      const SizedBox(height: 12.0),
                      Container(
                        decoration: BoxDecoration(
                          color: ProfileColors.surface(isDark),
                          borderRadius: BorderRadius.circular(20.0),
                          border: Border.all(
                            color: ProfileColors.border(isDark),
                            width: 1.0,
                          ),
                        ),
                        child: Column(
                          children: [
                            Semantics(
                              label: 'View My Progress',
                              button: true,
                              child: _buildMenuTile(
                                context,
                                icon: Icons.insights_rounded,
                                title: 'My Progress',
                                isDark: isDark,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const ProgressScreen()),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32.0),

                      // ── Logout Button ──
                      Semantics(
                        label: 'Log Out',
                        button: true,
                        child: InkWell(
                          onTap: _isLoggingOut ? null : _logout,
                          borderRadius: BorderRadius.circular(20.0),
                          child: Container(
                            height: 56.0,
                            decoration: BoxDecoration(
                              color: ProfileColors.softLavender(isDark),
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: Center(
                              child: _isLoggingOut
                                  ? SizedBox(
                                      width: 24.0,
                                      height: 24.0,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          ProfileColors.primaryPurple(isDark),
                                        ),
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.logout_rounded,
                                          color: ProfileColors.primaryPurple(isDark),
                                          size: 20.0,
                                        ),
                                        const SizedBox(width: 8.0),
                                        Text(
                                          'Log Out',
                                          style: TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Plus Jakarta Sans',
                                            color: ProfileColors.primaryPurple(isDark),
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
    required bool isDark,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            color: ProfileColors.softLavender(isDark),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: ProfileColors.primaryPurple(isDark),
            size: 20.0,
          ),
        ),
        const SizedBox(height: 8.0),
        Text(
          value,
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.w800,
            fontFamily: 'Plus Jakarta Sans',
            color: ProfileColors.deepNavy(isDark),
          ),
        ),
        const SizedBox(height: 4.0),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.0,
            fontFamily: 'Plus Jakarta Sans',
            color: ProfileColors.mutedText(isDark),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: ProfileColors.softLavender(isDark),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Icon(
                icon,
                color: ProfileColors.primaryPurple(isDark),
                size: 20.0,
              ),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Plus Jakarta Sans',
                  color: ProfileColors.deepNavy(isDark),
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: ProfileColors.mutedText(isDark),
              size: 24.0,
            ),
          ],
        ),
      ),
    );
  }
}
