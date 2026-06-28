import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/storage/token_storage.dart';
import '../../providers/user_provider.dart';
import '../../theme/app_theme.dart';
import '../auth/login_screen.dart';
import '../home/home_screen.dart';
import '../teacher_home_screen.dart';

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
  // Store the future exactly once. If created inline in build(), FutureBuilder
  // restarts on every rebuild and never resolves → infinite loading loop.
  late final Future<bool> _sessionFuture;

  @override
  void initState() {
    super.initState();
    _sessionFuture = _checkSession();
  }

  /// Checks for a valid token and pre-loads the user profile.
  Future<bool> _checkSession() async {
    final hasSession = await TokenStorage.hasSession();
    if (hasSession && mounted) {
      // Pre-load user so HomeScreen has role info immediately
      await context.read<UserProvider>().loadUser();
      if (mounted) {
        final hasUser = context.read<UserProvider>().hasUser;
        if (hasUser) {
          return true;
        } else {
          // Token is invalid or expired. Clear tokens so they are redirected to login.
          await TokenStorage.clearTokens();
          return false;
        }
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _sessionFuture, // ← same Future instance every build
      builder: (context, snapshot) {
        // ── Still checking ───────────────────────────────────────────────
        if (snapshot.connectionState != ConnectionState.done) {
          return const _SplashView();
        }

        // ── Session exists → Home ─────────────────────────────────────────
        if (snapshot.data == true) {
          final userRole = context.read<UserProvider>().user?.role;
          if (userRole == 'faculty' || userRole == 'admin') {
            return const TeacherHomeScreen();
          }
          return const HomeScreen();
        }

        // ── No session → Login ────────────────────────────────────────────
        return const LoginScreen();
      },
    );
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
                      color: AppColors.primary.withOpacity(0.12),
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
