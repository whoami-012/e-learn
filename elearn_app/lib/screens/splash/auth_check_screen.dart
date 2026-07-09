import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/auth/role_route.dart';
import '../../core/storage/token_storage.dart';
import '../../providers/user_provider.dart';
import '../../theme/app_theme.dart';
import '../auth/login_screen.dart';
import '../home/home_screen.dart';
import '../../features/dashboard/presentation/screens/teacher_faculty_dashboard_screen.dart';
import '../admin/admin_dashboard_screen.dart';

/// AuthCheckScreen — App startup gate.
///
/// **Must be a StatefulWidget** so the [Future] is created once in [initState]
/// and NOT recreated on every rebuild (which would cause an infinite loading loop).
class AuthCheckScreen extends StatefulWidget {
  const AuthCheckScreen({super.key});

  @override
  State<AuthCheckScreen> createState() => _AuthCheckScreenState();
}

class _AuthCheckScreenState extends State<AuthCheckScreen> {
  Timer? _navigationTimer;
  bool _isLoading = true;
  bool _isAuthenticated = false;
  String? _userRole;

  @override
  void initState() {
    super.initState();
    debugPrint("DEBUG: initState AuthCheckScreen");
    _navigationTimer = Timer(
      const Duration(milliseconds: 500),
      _checkAuthentication,
    );
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkAuthentication() async {
    debugPrint("DEBUG: Entering _checkAuthentication");
    bool authenticated = false;
    String? role;
    final userProvider = context.read<UserProvider>();
    try {
      debugPrint("DEBUG: Checking TokenStorage.hasSession()...");
      final hasSession = await TokenStorage.hasSession().timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          debugPrint("DEBUG: TokenStorage.hasSession() TIMEOUT!");
          return false;
        },
      );
      debugPrint("DEBUG: hasSession = $hasSession");
      if (hasSession && mounted) {
        debugPrint(
            "DEBUG: Pre-loading user profile via UserProvider.loadUser()...");
        await userProvider.loadUser().timeout(
          const Duration(seconds: 4),
          onTimeout: () {
            debugPrint("DEBUG: UserProvider.loadUser() TIMEOUT!");
          },
        );
        if (mounted) {
          final hasUser = userProvider.hasUser;
          debugPrint("DEBUG: hasUser = $hasUser");
          if (hasUser) {
            authenticated = true;
            role = userProvider.user?.role;
          } else {
            debugPrint("DEBUG: Token invalid/expired. Clearing tokens...");
            await TokenStorage.clearTokens();
          }
        }
      }
    } catch (e) {
      debugPrint("DEBUG: Exception in _checkAuthentication: $e");
    }

    if (!mounted) return;

    setState(() {
      _isAuthenticated = authenticated;
      _userRole = role;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const _SplashView();
    }

    if (_isAuthenticated) {
      switch (resolveHomeRoute(_userRole)) {
        case AppHomeRoute.faculty:
          return const TeacherFacultyDashboardScreen();
        case AppHomeRoute.admin:
          return const AdminDashboardScreen();
        case AppHomeRoute.student:
          return const HomeScreen();
        case AppHomeRoute.login:
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            await TokenStorage.clearTokens();
            if (context.mounted) {
              context.read<UserProvider>().clearUser();
            }
          });
          return const LoginScreen();
      }
    }

    return const LoginScreen();
  }
}

// ── Splash / Loading UI ────────────────────────────────────────────────────────

class _SplashView extends StatelessWidget {
  const _SplashView();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF9F8FD), AppColors.pastelPurple],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Beautiful logo container with soft shadow and white surface
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.large),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.school_rounded,
                    size: 52,
                    color: AppColors.primary,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              Text(
                'LearnFlow',
                style: textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                'Your premium learning companion',
                style: textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 48),

              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
