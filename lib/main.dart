import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'firebase_options.dart';
import 'blocs/auth_bloc.dart';

// ── Jongkuch: App Outlook + Auth screens ─────────────────────────────────────
import 'presentation/screens/app_outlook_screen.dart';
import 'presentation/screens/sign_up_screen.dart';
import 'presentation/screens/forgot_password_screen.dart';
import 'presentation/screens/verify_email_screen.dart';

// ── Other team members' screens ───────────────────────────────────────────────
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

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>(
      create: (_) => AuthBloc()..add(AuthCheckRequested()),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Inclusive Learning Platform',
        theme: ThemeData(
          colorSchemeSeed: const Color(0xFF00D4D4),
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: {
          // _AuthGate checks persisted auth state and routes automatically.
          '/': (context) => const _AuthGate(),

          // ── Jongkuch: App Outlook + Auth ──────────────────────────────────
          '/outlook': (context) => const OutlookScreen(),
          '/signup': (context) => const SignUpScreen(),
          '/forgot-password': (context) => const ForgotPasswordScreen(),
          '/verify-email': (context) => const VerifyEmailScreen(),

          // ── Other team members' routes ────────────────────────────────────
          '/course-completion': (context) => const CourseCompletionScreen(),
          '/mentorship-hub': (context) => const MentorshipHubScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/skills': (context) => const MySkillsScreen(),
          '/preferences': (context) => const PreferencesScreen(),
          '/discover': (context) => const DiscoverScreen(),
          '/accessibility-setup': (context) => const AccessibilitySetupScreen(),
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  _AuthGate — single source of truth for auth-based routing on app start.
// ─────────────────────────────────────────────────────────────────────────────

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthInitial || state is AuthLoading) {
          return const _SplashScreen();
        }
        if (state is AuthAuthenticated) {
          return const OutlookScreen();
        }
        if (state is AuthEmailVerificationRequired ||
            state is AuthEmailVerificationSent) {
          return const VerifyEmailScreen();
        }
        // AuthUnauthenticated, AuthError — show the landing screen.
        return const OutlookScreen();
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Splash screen — shown only during the initial Firebase auth check.
// ─────────────────────────────────────────────────────────────────────────────

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF00D4D4),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.school, size: 72, color: Colors.white),
            SizedBox(height: 16),
            Text(
              'Inclusive Learning Platform',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 24),
            CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
