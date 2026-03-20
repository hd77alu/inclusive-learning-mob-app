import 'package:flutter/material.dart';
import 'presentation/screens/app_outlook_screen.dart';
import 'presentation/screens/sign_up_screen.dart';
import 'presentation/screens/course_completion_screen.dart';
import 'presentation/screens/mentorship_hub_screen.dart';
import 'presentation/screens/profile_screen.dart';
import 'presentation/screens/my_skills_screen.dart';
import 'presentation/screens/preferences_screen.dart';
import 'presentation/screens/discover_screen.dart';
import 'presentation/screens/accessibility_setup_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Inclusive Learning Platform',
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF00D4D4),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const OutlookScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/course-completion': (context) => const CourseCompletionScreen(),
        '/mentorship-hub': (context) => const MentorshipHubScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/skills': (context) => const MySkillsScreen(),
        '/preferences': (context) => const PreferencesScreen(),
        '/discover': (context) => const DiscoverScreen(),
        '/accessibility-setup': (context) => const AccessibilitySetupScreen(),
      },
    );
  }
}