import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'firebase_options.dart';
import 'blocs/auth_bloc.dart';
import 'blocs/theme_bloc.dart';
import 'presentation/auth/auth_gate.dart';
import 'presentation/screens/app_outlook_screen.dart';
import 'presentation/screens/sign_up_screen.dart';
import 'presentation/screens/forgot_password_screen.dart';
import 'presentation/screens/verify_email_screen.dart';
import 'presentation/screens/course_completion_screen.dart';
import 'presentation/screens/mentorship_hub_screen.dart';
import 'presentation/screens/profile_screen.dart';
import 'presentation/screens/my_skills_screen.dart';
import 'presentation/screens/preferences_screen.dart';
import 'presentation/screens/discover_screen.dart';
import 'presentation/screens/accessibility_setup_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  static final _lightTheme = ThemeData(
    colorSchemeSeed: const Color(0xFF00D4D4),
    useMaterial3: true,
    brightness: Brightness.light,
  );

  static final _darkTheme = ThemeData(
    colorSchemeSeed: const Color(0xFF00D4D4),
    useMaterial3: true,
    brightness: Brightness.dark,
  );

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => AuthBloc()..add(AuthCheckRequested())),
        BlocProvider<ThemeBloc>(create: (_) => ThemeBloc()),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        buildWhen: (previous, current) => previous.isDarkMode != current.isDarkMode,
        builder: (context, themeState) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Inclusive Learning Platform',
          theme: _lightTheme,
          darkTheme: _darkTheme,
          themeMode: themeState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          initialRoute: '/',
        routes: {
          // AuthGate checks persisted auth state and routes automatically.
          '/': (context) => const AuthGate(),
          // Authenticated routes:
          '/outlook': (context) => const OutlookScreen(),
          '/signup': (context) => const SignUpScreen(),
          '/forgot-password': (context) => const ForgotPasswordScreen(),
          '/verify-email': (context) => const VerifyEmailScreen(),
          '/course-completion': (context) => const CourseCompletionScreen(),
          '/mentorship-hub': (context) => const MentorshipHubScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/skills': (context) => const MySkillsScreen(),
          '/preferences': (context) => const PreferencesScreen(),
          '/discover': (context) => const DiscoverScreen(),
          '/accessibility-setup': (context) => const AccessibilitySetupScreen(),
        },
        ),
      ),
    );
  }
}
