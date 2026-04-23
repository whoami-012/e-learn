import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/storage/token_storage.dart';
import '../../providers/user_provider.dart';
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
    }
    return hasSession;
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
    final color = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: color.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.school_rounded, size: 48, color: color.primary),
            ),

            const SizedBox(height: 20),

            Text(
              'E-Learn',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: color.primary,
                letterSpacing: 1,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Loading your session...',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: color.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
