import 'package:flutter/material.dart';
import '/presentation/widgets/accessibility_provider.dart';
import '../course/discover_screen.dart';
import '../mentorship/mentorship_hub_screen.dart';
import '../skills/my_skills_screen.dart';
import '../profile/profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  static const Color _teal = Color(0xFF00D4D4);

  final List<Widget> _screens = const [
    DiscoverScreen(),
    MentorshipHubScreen(),
    MySkillsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final a11y = AccessibilityProvider.of(context);
    
    // Adjust font sizes based on accessibility mode
    final selectedFontSize = 12.0 * a11y.fontSizeMultiplier;
    final unselectedFontSize = 11.0 * a11y.fontSizeMultiplier;
    
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: isDark ? const Color(0xFF1A2426) : Colors.white,
          selectedItemColor: _teal,
          unselectedItemColor: Colors.grey.shade500,
          selectedFontSize: selectedFontSize,
          unselectedFontSize: unselectedFontSize,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.explore_outlined),
              activeIcon: Icon(Icons.explore),
              label: 'Discover',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_outline),
              activeIcon: Icon(Icons.people),
              label: 'Mentorship',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.school_outlined),
              activeIcon: Icon(Icons.school),
              label: 'Skills',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
