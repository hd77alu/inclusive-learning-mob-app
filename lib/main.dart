import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'firebase_options.dart';
import 'blocs/auth_bloc.dart';
import 'blocs/theme_bloc.dart';
import 'blocs/accessibility_bloc.dart';
import 'blocs/language_cubit.dart';
import 'data/services/firestore_service.dart';
import 'presentation/widgets/accessibility_provider.dart';
import 'presentation/screens/auth/auth_gate.dart';
import 'presentation/screens/core/app_outlook_screen.dart';
import 'presentation/screens/auth/sign_up_screen.dart';
import 'presentation/screens/auth/forgot_password_screen.dart';
import 'presentation/screens/auth/verify_email_screen.dart';
import 'presentation/screens/course/course_completion_screen.dart';
import 'presentation/screens/profile/preferences_screen.dart';
import 'presentation/screens/accessibility/accessibility_setup_screen.dart';
import 'presentation/screens/mentorship/my_sessions_screen.dart';

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
        BlocProvider<AccessibilityBloc>(
          create: (_) => AccessibilityBloc(FirestoreService())..add(LoadAccessibilityPreference()),
        ),
        BlocProvider<LanguageCubit>(create: (_) => LanguageCubit()),
      ],
      child: BlocBuilder<AccessibilityBloc, AccessibilityState>(
        builder: (context, a11yState) {
          return AccessibilityProvider(
            service: a11yState.service,
            child: BlocBuilder<ThemeBloc, ThemeState>(
              buildWhen: (previous, current) => previous.isDarkMode != current.isDarkMode,
              builder: (context, themeState) => MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'Inclusive Learning Platform',
                theme: _lightTheme,
                darkTheme: _darkTheme,
                themeMode: themeState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
                routes: {
                  '/': (context) => const AuthGate(),
                  '/outlook': (context) => const OutlookScreen(),
                  '/signup': (context) => const SignUpScreen(),
                  '/forgot-password': (context) => const ForgotPasswordScreen(),
                  '/verify-email': (context) => const VerifyEmailScreen(),
                  '/course-completion': (context) => const CourseCompletionScreen(),
                  '/preferences': (context) => const PreferencesScreen(),
                  '/accessibility-setup': (context) => const AccessibilitySetupScreen(),
                  '/my-sessions': (context) => const MySessionsScreen(),
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
