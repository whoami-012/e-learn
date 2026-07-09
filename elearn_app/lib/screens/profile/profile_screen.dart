import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../providers/user_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/course_provider.dart';
import '../../models/course.dart';
import '../../core/exceptions/auth_exception.dart';
import '../../services/auth_service.dart';
import '../../services/enrollment_service.dart';
import '../../services/course_service.dart';
import '../../widgets/dashboard/app_bottom_navigation.dart';
import '../courses/course_list_screen.dart';
import '../calendar/calendar_screen.dart';
import '../messages/message_screen.dart';
import '../auth/login_screen.dart';
import 'progress_screen.dart';

class ProfileColors {
  ProfileColors._();

  static Color primaryPurple(bool isDark) => const Color(0xFF6C45D8);
  static Color deepNavy(bool isDark) =>
      isDark ? const Color(0xFFF7F8FC) : const Color(0xFF101936);
  static Color pageBackground(bool isDark) =>
      isDark ? const Color(0xFF0F1117) : const Color(0xFFF7F8FC);
  static Color surface(bool isDark) =>
      isDark ? const Color(0xFF181B23) : const Color(0xFFFFFFFF);
  static Color softLavender(bool isDark) =>
      isDark ? const Color(0xFF2A243F) : const Color(0xFFF0ECFC);
  static Color mutedText(bool isDark) =>
      isDark ? const Color(0xFFADB4C4) : const Color(0xFF6F7588);
  static Color border(bool isDark) =>
      isDark ? const Color(0xFF303542) : const Color(0xFFE9EBF2);
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
  int _totalLessonsCount = 0;
  bool _isLoggingOut = false;
  bool _pushNotificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
    _loadNotificationPreference();
  }

  Future<void> _loadNotificationPreference() async {
    const storage = FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    );
    try {
      final val = await storage.read(key: 'push_notifications_enabled');
      if (val != null && mounted) {
        setState(() {
          _pushNotificationsEnabled = val == 'true';
        });
      }
    } catch (_) {}
  }

  Future<void> _saveNotificationPreference(bool enabled) async {
    const storage = FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    );
    try {
      await storage.write(
          key: 'push_notifications_enabled', value: enabled.toString());
      if (mounted) {
        setState(() {
          _pushNotificationsEnabled = enabled;
        });
      }
    } catch (_) {}
  }

  Future<void> _loadProfileData() async {
    if (!context.mounted) return;
    final userProvider = context.read<UserProvider>();
    final courseProvider = context.read<CourseProvider>();
    setState(() {
      _isLoading = true;
    });

    try {
      await userProvider.loadUser();
    } catch (_) {}

    if (!context.mounted) return;

    try {
      await courseProvider.fetchCourses();

      if (!context.mounted) return;

      final courses = courseProvider.courses;
      int enrolled = 0;
      int totalLessons = 0;

      // Check enrollment in parallel
      final enrollmentChecks = await Future.wait(courses.map((course) async {
        try {
          final res = await EnrollmentService.checkEnrollment(course.id);
          return MapEntry(course, res.isEnrolled);
        } catch (_) {
          return MapEntry(course, false);
        }
      }));

      final enrolledCourses = <Course>[];
      for (final entry in enrollmentChecks) {
        if (entry.value) {
          enrolledCourses.add(entry.key);
          enrolled++;
        }
      }

      // Fetch lessons in parallel for all enrolled courses
      final lessonsCounts =
          await Future.wait(enrolledCourses.map((course) async {
        try {
          final lessons = await CourseService.getLessonsForCourse(course.id);
          return lessons.length;
        } catch (_) {
          return 0;
        }
      }));

      for (final count in lessonsCounts) {
        totalLessons += count;
      }

      if (context.mounted) {
        setState(() {
          _enrolledCount = enrolled;
          _totalLessonsCount = totalLessons;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (context.mounted) {
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

  // ── Bottom Sheets for Interactive Settings & Menu Items ──

  void _showSettingsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Consumer<ThemeProvider>(
          builder: (context, themeProvider, _) {
            final isDark = themeProvider.isDarkMode;
            return Container(
              decoration: BoxDecoration(
                color: ProfileColors.surface(isDark),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24.0)),
              ),
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 24.0),
                      decoration: BoxDecoration(
                        color: ProfileColors.border(isDark),
                        borderRadius: BorderRadius.circular(2.0),
                      ),
                    ),
                  ),
                  Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Plus Jakarta Sans',
                      color: ProfileColors.deepNavy(isDark),
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  // Dark Mode Switch
                  ListTile(
                    leading: Icon(Icons.dark_mode_rounded,
                        color: ProfileColors.primaryPurple(isDark)),
                    title: Text(
                      'Dark Mode',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Plus Jakarta Sans',
                        color: ProfileColors.deepNavy(isDark),
                      ),
                    ),
                    trailing: Switch(
                      value: isDark,
                      activeThumbColor: ProfileColors.primaryPurple(isDark),
                      onChanged: (val) async {
                        await themeProvider.toggleTheme();
                        if (mounted) {
                          setState(() {});
                        }
                      },
                    ),
                  ),
                  Divider(
                      color: ProfileColors.border(isDark),
                      height: 1.0,
                      thickness: 1.0),
                  // Notification Switch
                  StatefulBuilder(
                    builder: (context, setNotificationState) {
                      return ListTile(
                        leading: Icon(Icons.notifications_rounded,
                            color: ProfileColors.primaryPurple(isDark)),
                        title: Text(
                          'Push Notifications',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Plus Jakarta Sans',
                            color: ProfileColors.deepNavy(isDark),
                          ),
                        ),
                        trailing: Switch(
                          value: _pushNotificationsEnabled,
                          activeThumbColor: ProfileColors.primaryPurple(isDark),
                          onChanged: (val) {
                            setNotificationState(() {
                              _pushNotificationsEnabled = val;
                            });
                            _saveNotificationPreference(val);
                          },
                        ),
                      );
                    },
                  ),
                  Divider(
                      color: ProfileColors.border(isDark),
                      height: 1.0,
                      thickness: 1.0),
                  // Language Selection
                  ListTile(
                    leading: Icon(Icons.language_rounded,
                        color: ProfileColors.primaryPurple(isDark)),
                    title: Text(
                      'Language',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Plus Jakarta Sans',
                        color: ProfileColors.deepNavy(isDark),
                      ),
                    ),
                    trailing: Text(
                      'English',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Plus Jakarta Sans',
                        color: ProfileColors.primaryPurple(isDark),
                      ),
                    ),
                    onTap: () {},
                  ),
                  const SizedBox(height: 24.0),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showEditProfileSheet(bool isDark, String name, String email) {
    final nameController = TextEditingController(text: name);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            decoration: BoxDecoration(
              color: ProfileColors.surface(isDark),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24.0)),
            ),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 24.0),
                    decoration: BoxDecoration(
                      color: ProfileColors.border(isDark),
                      borderRadius: BorderRadius.circular(2.0),
                    ),
                  ),
                ),
                Text(
                  'Edit Profile',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Plus Jakarta Sans',
                    color: ProfileColors.deepNavy(isDark),
                  ),
                ),
                const SizedBox(height: 24.0),
                // Avatar Upload Placeholder
                Center(
                  child: Stack(
                    children: [
                      Container(
                        width: 90.0,
                        height: 90.0,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              ProfileColors.primaryPurple(isDark)
                                  .withValues(alpha: 0.8),
                              ProfileColors.primaryPurple(isDark),
                            ],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            _getInitials(name),
                            style: const TextStyle(
                              fontSize: 32.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'Plus Jakarta Sans',
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6.0),
                          decoration: BoxDecoration(
                            color: ProfileColors.primaryPurple(isDark),
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: ProfileColors.surface(isDark),
                                width: 2.0),
                          ),
                          child: const Icon(Icons.camera_alt_rounded,
                              color: Colors.white, size: 16.0),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24.0),
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.0)),
                  ),
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  initialValue: email,
                  enabled: false,
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.0)),
                  ),
                ),
                const SizedBox(height: 24.0),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Profile updated successfully!'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ProfileColors.primaryPurple(isDark),
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0)),
                  ),
                  child: const Text(
                    'Save Changes',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showChangePasswordSheet(bool isDark) async {
    final formKey = GlobalKey<FormState>();
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final submissionError = ValueNotifier<String?>(null);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            decoration: BoxDecoration(
              color: ProfileColors.surface(isDark),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24.0)),
            ),
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 24.0),
                        decoration: BoxDecoration(
                          color: ProfileColors.border(isDark),
                          borderRadius: BorderRadius.circular(2.0),
                        ),
                      ),
                    ),
                    Text(
                      'Change Password',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Plus Jakarta Sans',
                        color: ProfileColors.deepNavy(isDark),
                      ),
                    ),
                    const SizedBox(height: 24.0),
                    TextFormField(
                      controller: currentPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Current Password',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.0)),
                      ),
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'Please enter your current password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: newPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'New Password',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.0)),
                      ),
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'Please enter a new password';
                        }
                        if (val.length < 8) {
                          return 'Password must be at least 8 characters long';
                        }
                        if (!val.contains(RegExp(r'[A-Z]'))) {
                          return 'Password must contain at least one uppercase letter';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: confirmPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Confirm New Password',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.0)),
                      ),
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'Please confirm your new password';
                        }
                        if (val != newPasswordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    ValueListenableBuilder<String?>(
                      valueListenable: submissionError,
                      builder: (context, error, _) {
                        if (error == null) return const SizedBox.shrink();
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16.0),
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(
                              color: Colors.red.withValues(alpha: 0.35),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline,
                                  color: Colors.red, size: 20.0),
                              const SizedBox(width: 8.0),
                              Expanded(
                                child: Text(
                                  error,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        submissionError.value = null;
                        if (!formKey.currentState!.validate()) return;

                        try {
                          await AuthService.changePassword(
                            currentPassword: currentPasswordController.text,
                            newPassword: newPasswordController.text,
                          );
                          if (!mounted || !context.mounted) return;
                          Navigator.pop(context);
                          ScaffoldMessenger.of(this.context).showSnackBar(
                            const SnackBar(
                              content: Text('Password updated successfully!'),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        } on AuthException catch (error) {
                          if (!context.mounted) return;
                          submissionError.value = error.message;
                        } catch (_) {
                          if (!context.mounted) return;
                          submissionError.value =
                              'Unable to change password. Please try again.';
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ProfileColors.primaryPurple(isDark),
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0)),
                      ),
                      child: const Text(
                        'Update Password',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    submissionError.dispose();
  }

  void _showPaymentMethodsSheet(bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: ProfileColors.surface(isDark),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24.0)),
          ),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24.0),
                  decoration: BoxDecoration(
                    color: ProfileColors.border(isDark),
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                ),
              ),
              Text(
                'Payment Methods',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Plus Jakarta Sans',
                  color: ProfileColors.deepNavy(isDark),
                ),
              ),
              const SizedBox(height: 20.0),
              // Card Mock 1
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C45D8), Color(0xFF8A65E8)],
                  ),
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.credit_card_rounded,
                        color: Colors.white, size: 32.0),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Visa Ending in 4242',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                          Text('Expires 12/28',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 12.0)),
                        ],
                      ),
                    ),
                    const Icon(Icons.check_circle_rounded,
                        color: Colors.white, size: 24.0),
                  ],
                ),
              ),
              const SizedBox(height: 24.0),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add New Card'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: ProfileColors.primaryPurple(isDark),
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  side: BorderSide(color: ProfileColors.primaryPurple(isDark)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCertificatesSheet(bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: ProfileColors.surface(isDark),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24.0)),
          ),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24.0),
                  decoration: BoxDecoration(
                    color: ProfileColors.border(isDark),
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                ),
              ),
              Text(
                'My Certificates',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Plus Jakarta Sans',
                  color: ProfileColors.deepNavy(isDark),
                ),
              ),
              const SizedBox(height: 20.0),
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: ProfileColors.softLavender(isDark),
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(color: ProfileColors.border(isDark)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.workspace_premium_rounded,
                        color: ProfileColors.primaryPurple(isDark), size: 36.0),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'UI/UX Design Masterclass',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: ProfileColors.deepNavy(isDark),
                            ),
                          ),
                          const Text('Issued on May 2026',
                              style: TextStyle(
                                  color: Colors.grey, fontSize: 12.0)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.download_rounded,
                          color: ProfileColors.primaryPurple(isDark)),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24.0),
            ],
          ),
        );
      },
    );
  }

  void _showSavedCoursesSheet(bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: ProfileColors.surface(isDark),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24.0)),
          ),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24.0),
                  decoration: BoxDecoration(
                    color: ProfileColors.border(isDark),
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                ),
              ),
              Text(
                'Saved Courses',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Plus Jakarta Sans',
                  color: ProfileColors.deepNavy(isDark),
                ),
              ),
              const SizedBox(height: 20.0),
              ListTile(
                leading: const Icon(Icons.bookmark_added_rounded,
                    color: Colors.orange),
                title: Text(
                  'Advanced Flutter Concepts',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: ProfileColors.deepNavy(isDark),
                  ),
                ),
                subtitle: const Text('Saved 2 days ago'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
              const SizedBox(height: 24.0),
            ],
          ),
        );
      },
    );
  }

  void _showLearningHistorySheet(bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: ProfileColors.surface(isDark),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24.0)),
          ),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24.0),
                  decoration: BoxDecoration(
                    color: ProfileColors.border(isDark),
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                ),
              ),
              Text(
                'Learning History',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Plus Jakarta Sans',
                  color: ProfileColors.deepNavy(isDark),
                ),
              ),
              const SizedBox(height: 20.0),
              ListTile(
                leading:
                    const Icon(Icons.play_circle_outline, color: Colors.blue),
                title: Text(
                  'State Management with Provider',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: ProfileColors.deepNavy(isDark),
                  ),
                ),
                subtitle: const Text('Watched for 18 mins • Today'),
                onTap: () {},
              ),
              const SizedBox(height: 24.0),
            ],
          ),
        );
      },
    );
  }

  void _showWishlistSheet(bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: ProfileColors.surface(isDark),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24.0)),
          ),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24.0),
                  decoration: BoxDecoration(
                    color: ProfileColors.border(isDark),
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                ),
              ),
              Text(
                'Wishlist',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Plus Jakarta Sans',
                  color: ProfileColors.deepNavy(isDark),
                ),
              ),
              const SizedBox(height: 20.0),
              ListTile(
                leading: const Icon(Icons.favorite_rounded, color: Colors.red),
                title: Text(
                  'Introduction to FastAPI Backend',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: ProfileColors.deepNavy(isDark),
                  ),
                ),
                subtitle: const Text('\$49.99'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
              const SizedBox(height: 24.0),
            ],
          ),
        );
      },
    );
  }

  void _showPrivacyPolicySheet(bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: ProfileColors.surface(isDark),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24.0)),
          ),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24.0),
                  decoration: BoxDecoration(
                    color: ProfileColors.border(isDark),
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                ),
              ),
              Text(
                'Privacy Policy',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Plus Jakarta Sans',
                  color: ProfileColors.deepNavy(isDark),
                ),
              ),
              const SizedBox(height: 16.0),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    'At E-Learn, we take your privacy seriously. This policy outlines how we collect, use, and protect your personal information when you use our mobile application and services.\n\n'
                    '1. Information We Collect\n'
                    'We collect personal data like your name, email, and progress to personalize your dashboard. We do not sell your personal data.\n\n'
                    '2. How We Use Data\n'
                    'Your statistics, course completion rates, and active study hours are tracked locally and synced to optimize your curriculum recommendations.\n\n'
                    '3. Third-party Services\n'
                    'Payment data is securely processed via Stripe. We do not store full credit card numbers on our servers.',
                    style: TextStyle(
                      fontSize: 14.0,
                      fontFamily: 'Plus Jakarta Sans',
                      color: ProfileColors.mutedText(isDark),
                      height: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
            ],
          ),
        );
      },
    );
  }

  void _showHelpSheet(bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: BoxDecoration(
            color: ProfileColors.surface(isDark),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24.0)),
          ),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24.0),
                  decoration: BoxDecoration(
                    color: ProfileColors.border(isDark),
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                ),
              ),
              Text(
                'Help & Support',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Plus Jakarta Sans',
                  color: ProfileColors.deepNavy(isDark),
                ),
              ),
              const SizedBox(height: 20.0),
              Expanded(
                child: ListView(
                  children: [
                    _buildFaqItem(
                        'How do I download a Certificate?',
                        'Navigate to My Learning > My Certificates, and tap the download icon next to the certificate.',
                        isDark),
                    _buildFaqItem(
                        'Can I sync progress offline?',
                        'Yes, lessons are completed locally and automatically synced once you regain connection.',
                        isDark),
                    _buildFaqItem(
                        'How do I cancel my plan?',
                        'Go to settings, manage subscription, and tap cancel subscription.',
                        isDark),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFaqItem(String question, String answer, bool isDark) {
    return ExpansionTile(
      title: Text(
        question,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14.0,
          fontFamily: 'Plus Jakarta Sans',
          color: ProfileColors.deepNavy(isDark),
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            answer,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              color: ProfileColors.mutedText(isDark),
              fontSize: 13.0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider(bool isDark) {
    return Container(
      width: 1.0,
      height: 36.0,
      color: ProfileColors.border(isDark).withValues(alpha: 0.5),
    );
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
          currentIndex: 4,
          onTap: (index) {
            if (index == 4) return;
            if (index == 0) {
              Navigator.pop(context);
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
                            label: 'Settings',
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
                                  Icons.settings_outlined,
                                  color: ProfileColors.deepNavy(isDark),
                                ),
                                onPressed: () => _showSettingsSheet(),
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
                              color: Colors.black
                                  .withValues(alpha: isDark ? 0.2 : 0.03),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            InkWell(
                              onTap: () =>
                                  _showEditProfileSheet(isDark, name, email),
                              borderRadius: BorderRadius.circular(16.0),
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4.0),
                                child: Row(
                                  children: [
                                    // Avatar
                                    Container(
                                      width: 64.0,
                                      height: 64.0,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            ProfileColors.primaryPurple(isDark)
                                                .withValues(alpha: 0.8),
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  name,
                                                  style: TextStyle(
                                                    fontSize: 18.0,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily:
                                                        'Plus Jakarta Sans',
                                                    color:
                                                        ProfileColors.deepNavy(
                                                            isDark),
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              const SizedBox(width: 6.0),
                                              const Icon(
                                                Icons.verified_rounded,
                                                color: Colors.blue,
                                                size: 18.0,
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4.0),
                                          Text(
                                            email,
                                            style: TextStyle(
                                              fontSize: 14.0,
                                              fontFamily: 'Plus Jakarta Sans',
                                              color: ProfileColors.mutedText(
                                                  isDark),
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Icons.chevron_right_rounded,
                                      color: ProfileColors.mutedText(isDark),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20.0),
                            Divider(
                                color: ProfileColors.border(isDark),
                                height: 1.0),
                            const SizedBox(height: 20.0),
                            // Stats Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildStatItem(
                                  context,
                                  icon: Icons.home_outlined,
                                  value: _isLoading ? '...' : '$_enrolledCount',
                                  label: 'Courses',
                                  isDark: isDark,
                                ),
                                _buildVerticalDivider(isDark),
                                _buildStatItem(
                                  context,
                                  icon: Icons.calendar_today_outlined,
                                  value: _isLoading
                                      ? '...'
                                      : '$_totalLessonsCount',
                                  label: 'Lessons',
                                  isDark: isDark,
                                ),
                                _buildVerticalDivider(isDark),
                                _buildStatItem(
                                  context,
                                  icon: Icons.workspace_premium_outlined,
                                  value: _isLoading
                                      ? '...'
                                      : (_enrolledCount > 0 ? '1' : '0'),
                                  label: 'Certificates',
                                  isDark: isDark,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20.0),

                      // ── Membership Promotion Card ──
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: ProfileColors.softLavender(isDark),
                          borderRadius: BorderRadius.circular(20.0),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF3F356B)
                                : const Color(0xFFDFD7FA),
                            width: 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10.0),
                              decoration: BoxDecoration(
                                color: ProfileColors.surface(isDark),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.workspace_premium_rounded,
                                color: ProfileColors.primaryPurple(isDark),
                                size: 24.0,
                              ),
                            ),
                            const SizedBox(width: 16.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "You're a Premium Member",
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Plus Jakarta Sans',
                                      color: ProfileColors.deepNavy(isDark),
                                    ),
                                  ),
                                  const SizedBox(height: 2.0),
                                  Text(
                                    "Valid until 20 May 2025",
                                    style: TextStyle(
                                      fontSize: 12.0,
                                      fontFamily: 'Plus Jakarta Sans',
                                      color: ProfileColors.mutedText(isDark),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: ProfileColors.surface(isDark),
                                foregroundColor:
                                    ProfileColors.primaryPurple(isDark),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0, vertical: 10.0),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                  side: BorderSide(
                                      color: ProfileColors.primaryPurple(isDark)
                                          .withValues(alpha: 0.5)),
                                ),
                              ),
                              child: Text(
                                'View Plan',
                                style: TextStyle(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Plus Jakarta Sans',
                                  color: ProfileColors.primaryPurple(isDark),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28.0),

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
                            _buildMenuTile(
                              context,
                              icon: Icons.workspace_premium_outlined,
                              title: 'My Certificates',
                              isDark: isDark,
                              onTap: () => _showCertificatesSheet(isDark),
                            ),
                            Divider(
                                color: ProfileColors.border(isDark),
                                height: 1.0,
                                indent: 64.0),
                            _buildMenuTile(
                              context,
                              icon: Icons.bookmark_border_rounded,
                              title: 'Saved Courses',
                              isDark: isDark,
                              onTap: () => _showSavedCoursesSheet(isDark),
                            ),
                            Divider(
                                color: ProfileColors.border(isDark),
                                height: 1.0,
                                indent: 64.0),
                            _buildMenuTile(
                              context,
                              icon: Icons.insights_rounded,
                              title: 'My Progress',
                              isDark: isDark,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const ProgressScreen()),
                                );
                              },
                            ),
                            Divider(
                                color: ProfileColors.border(isDark),
                                height: 1.0,
                                indent: 64.0),
                            _buildMenuTile(
                              context,
                              icon: Icons.history_rounded,
                              title: 'Learning History',
                              isDark: isDark,
                              onTap: () => _showLearningHistorySheet(isDark),
                            ),
                            Divider(
                                color: ProfileColors.border(isDark),
                                height: 1.0,
                                indent: 64.0),
                            _buildMenuTile(
                              context,
                              icon: Icons.favorite_border_rounded,
                              title: 'Wishlist',
                              isDark: isDark,
                              onTap: () => _showWishlistSheet(isDark),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28.0),

                      // ── Account Section ──
                      Text(
                        'Account',
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
                            _buildMenuTile(
                              context,
                              icon: Icons.person_outline_rounded,
                              title: 'Edit Profile',
                              isDark: isDark,
                              onTap: () =>
                                  _showEditProfileSheet(isDark, name, email),
                            ),
                            Divider(
                                color: ProfileColors.border(isDark),
                                height: 1.0,
                                indent: 64.0),
                            _buildMenuTile(
                              context,
                              icon: Icons.lock_outline_rounded,
                              title: 'Change Password',
                              isDark: isDark,
                              onTap: () => _showChangePasswordSheet(isDark),
                            ),
                            Divider(
                                color: ProfileColors.border(isDark),
                                height: 1.0,
                                indent: 64.0),
                            _buildMenuTile(
                              context,
                              icon: Icons.credit_card_outlined,
                              title: 'Payment Methods',
                              isDark: isDark,
                              onTap: () => _showPaymentMethodsSheet(isDark),
                            ),
                            Divider(
                                color: ProfileColors.border(isDark),
                                height: 1.0,
                                indent: 64.0),
                            _buildMenuTile(
                              context,
                              icon: Icons.notifications_none_rounded,
                              title: 'Notifications',
                              isDark: isDark,
                              onTap: () => _showSettingsSheet(),
                            ),
                            Divider(
                                color: ProfileColors.border(isDark),
                                height: 1.0,
                                indent: 64.0),
                            _buildMenuTile(
                              context,
                              icon: Icons.shield_outlined,
                              title: 'Privacy Policy',
                              isDark: isDark,
                              onTap: () => _showPrivacyPolicySheet(isDark),
                            ),
                            Divider(
                                color: ProfileColors.border(isDark),
                                height: 1.0,
                                indent: 64.0),
                            _buildMenuTile(
                              context,
                              icon: Icons.help_outline_rounded,
                              title: 'Help & Support',
                              isDark: isDark,
                              onTap: () => _showHelpSheet(isDark),
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
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          ProfileColors.primaryPurple(isDark),
                                        ),
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.logout_rounded,
                                          color: ProfileColors.primaryPurple(
                                              isDark),
                                          size: 20.0,
                                        ),
                                        const SizedBox(width: 8.0),
                                        Text(
                                          'Log Out',
                                          style: TextStyle(
                                            fontSize: 16.0,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Plus Jakarta Sans',
                                            color: ProfileColors.primaryPurple(
                                                isDark),
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
        Icon(
          icon,
          color: ProfileColors.primaryPurple(isDark),
          size: 24.0,
        ),
        const SizedBox(height: 6.0),
        Text(
          value,
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.w800,
            fontFamily: 'Plus Jakarta Sans',
            color: ProfileColors.deepNavy(isDark),
          ),
        ),
        const SizedBox(height: 2.0),
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
            Icon(
              icon,
              color: ProfileColors.primaryPurple(isDark),
              size: 24.0,
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
