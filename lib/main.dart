import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'firebase_options.dart';
import 'blocs/auth_bloc.dart';
import 'blocs/theme_bloc.dart';
import 'data/services/accessibility_service.dart';
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

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  AccessibilityService _accessibilityService = AccessibilityService.defaultMode;
  bool _shouldShowSuccessMessage = false;

  @override
  void initState() {
    super.initState();
    _loadAccessibilityPreference();
  }

  Future<void> _loadAccessibilityPreference() async {
    try {
      final firestoreService = FirestoreService();
      final preference = await firestoreService.getAccessibilityPreference();
      if (mounted) {
        setState(() {
          if (preference != null) {
            _accessibilityService = AccessibilityService(preference.selectedMode);
          } else {
            _accessibilityService = AccessibilityService.defaultMode;
          }
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _accessibilityService = AccessibilityService.defaultMode;
        });
      }
    }
  }

  Future<void> _reloadAccessibilityAndShowMessage() async {
    try {
      final firestoreService = FirestoreService();
      final preference = await firestoreService.getAccessibilityPreference();
      if (mounted) {
        setState(() {
          if (preference != null) {
            _accessibilityService = AccessibilityService(preference.selectedMode);
          } else {
            _accessibilityService = AccessibilityService.defaultMode;
          }
          _shouldShowSuccessMessage = true;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _accessibilityService = AccessibilityService.defaultMode;
        });
      }
    }
  }

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
    return AccessibilityProvider(
      service: _accessibilityService,
      child: MultiBlocProvider(
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
        onGenerateRoute: (settings) {
          if (settings.name == '/' && settings.arguments != null) {
            final args = settings.arguments as Map<String, dynamic>?;
            if (args?['reloadAccessibility'] == true) {
              _reloadAccessibilityAndShowMessage();
            }
          }
          
          final routes = <String, WidgetBuilder>{
            '/': (context) {
              if (_shouldShowSuccessMessage) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: const Text('Accessibility preference saved!'),
                      backgroundColor: const Color(0xFF00D4D4),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      duration: const Duration(seconds: 2),
                    ));
                    _shouldShowSuccessMessage = false;
                  }
                });
              }
              return const AuthGate();
            },
            '/outlook': (context) => const OutlookScreen(),
            '/signup': (context) => const SignUpScreen(),
            '/forgot-password': (context) => const ForgotPasswordScreen(),
            '/verify-email': (context) => const VerifyEmailScreen(),
            '/course-completion': (context) => const CourseCompletionScreen(),
            '/preferences': (context) => const PreferencesScreen(),
            '/accessibility-setup': (context) => const AccessibilitySetupScreen(),
            '/my-sessions': (context) => const MySessionsScreen(),
          };
          
          final builder = routes[settings.name];
          if (builder != null) {
            return MaterialPageRoute(builder: builder, settings: settings);
          }
          return null;
        },
          ),
        ),
      ),
    );
  }
}
