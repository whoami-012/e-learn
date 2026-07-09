import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'providers/user_provider.dart';
import 'providers/course_provider.dart';
import 'providers/enrollment_provider.dart';
import 'providers/note_provider.dart';
import 'providers/teacher_dashboard_provider.dart';
import 'providers/exam_provider.dart';
import 'providers/admin_provider.dart';
import 'features/live_class/presentation/controllers/live_class_controller.dart';
import 'providers/theme_provider.dart';
import 'providers/message_provider.dart';
import 'theme/app_theme.dart';
import 'screens/splash/auth_check_screen.dart';
import 'services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Native Firebase reads google-services.json/GoogleService-Info.plist.
  // This app does not use Firebase services on web; Google Sign-In exchanges
  // its OAuth ID token directly with the FastAPI backend.
  if (!kIsWeb) {
    await Firebase.initializeApp();
  }
  await AuthService.initializeGoogleSignIn();
  runApp(const ELearnApp());
}

class ELearnApp extends StatelessWidget {
  const ELearnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => CourseProvider()),
        ChangeNotifierProvider(create: (_) => EnrollmentProvider()),
        ChangeNotifierProvider(create: (_) => NoteProvider()),
        ChangeNotifierProvider(create: (_) => TeacherDashboardProvider()),
        ChangeNotifierProvider(create: (_) => ExamProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
        ChangeNotifierProvider(create: (_) => LiveClassController()),
        ChangeNotifierProvider(create: (_) => MessageProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) => MaterialApp(
          title: 'E-Learn',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          home: const AuthCheckScreen(),
        ),
      ),
    );
  }
}
