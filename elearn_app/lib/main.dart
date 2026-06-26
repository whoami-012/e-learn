import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/user_provider.dart';
import 'providers/course_provider.dart';
import 'providers/enrollment_provider.dart';
import 'providers/note_provider.dart';
import 'providers/teacher_dashboard_provider.dart';
import 'providers/exam_provider.dart';
import 'providers/admin_provider.dart';
import 'theme/app_theme.dart';
import 'screens/splash/auth_check_screen.dart';

void main() {
  runApp(const ELearnApp());
}

class ELearnApp extends StatelessWidget {
  const ELearnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => CourseProvider()),
        ChangeNotifierProvider(create: (_) => EnrollmentProvider()),
        ChangeNotifierProvider(create: (_) => NoteProvider()),
        ChangeNotifierProvider(create: (_) => TeacherDashboardProvider()),
        ChangeNotifierProvider(create: (_) => ExamProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
      ],
      child: MaterialApp(
        title: 'E-Learn',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AuthCheckScreen(),
      ),
    );
  }
}
