import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
//  SCREEN 1: App Outlook / Home Screen
// ─────────────────────────────────────────────
class OutlookScreen extends StatelessWidget {
  const OutlookScreen({super.key});

  static const Color teal = Color(0xFF00D4D4);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ── Header ──
          _buildHeader(),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // ── Hero illustration ──
                  _buildHeroIllustration(context),

                  // ── Dots + Welcome text ──
                  const SizedBox(height: 12),
                  _buildDots(),
                  const SizedBox(height: 8),
                  _buildWelcomeText(),
                  const SizedBox(height: 16),

                  // ── Icon grid ──
                  _buildIconGrid(context),
                  const SizedBox(height: 16),

                  // ── Start button ──
                  _buildStartButton(context),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      color: teal,
      padding: const EdgeInsets.only(top: 50, bottom: 14),
      child: const Text(
        'Inclusive Learning Platform',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w800,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildHeroIllustration(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 240,
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFc8e8f5), Color(0xFFa0cce0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 10,
                runSpacing: 10,
                children: [
                  _person(Colors.grey.shade600, const Color(0xFFF5C5A3), '👴'),
                  _person(
                    const Color(0xFFE07B30),
                    const Color(0xFFD4956A),
                    '👦',
                  ),
                  _person(
                    const Color(0xFF4A90D9),
                    const Color(0xFFC4885A),
                    '🧔',
                  ),
                  _person(
                    const Color(0xFFD4608A),
                    const Color(0xFFF0B8A0),
                    '👧',
                  ),
                  _person(
                    const Color(0xFF1A7AD4),
                    const Color(0xFFF5C090),
                    '🧑‍🦲',
                  ),
                  _person(
                    const Color(0xFF4A90D9),
                    const Color(0xFFD4956A),
                    '🧑‍🦽',
                  ),
                ],
              ),
            ),
          ),
        ),
        // Back and profile buttons
        Positioned(
          top: 10,
          left: 12,
          child: _circleButton(
            icon: Icons.arrow_back,
            onTap: () => Navigator.maybePop(context),
          ),
        ),
        Positioned(
          top: 10,
          right: 12,
          child: _circleButton(
            icon: Icons.person,
            onTap: () => _showProfileSheet(context),
          ),
        ),
      ],
    );
  }

  void _showProfileSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // drag handle
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Avatar with default person icon
            Stack(
              children: [
                CircleAvatar(
                  radius: 38,
                  backgroundColor: teal.withOpacity(0.15),
                  child: const Icon(Icons.person, size: 42, color: teal),
                ),
              ],
            ),
            const SizedBox(height: 12),

            const Text(
              'Guest User',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            const Text(
              'Not signed in',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 20),

            // Profile info rows
            _profileInfoRow(Icons.email_outlined, 'Email', '—'),
            const Divider(height: 1),
            _profileInfoRow(Icons.school_outlined, 'Progress', 'No data yet'),
            const SizedBox(height: 20),

            // Small sign-up link at bottom
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/signup');
              },
              child: Text.rich(
                TextSpan(
                  text: 'Want to save your progress? ',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                  children: [
                    TextSpan(
                      text: 'Sign up',
                      style: TextStyle(
                        color: teal,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        decoration: TextDecoration.underline,
                        decorationColor: teal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade500),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _person(Color bodyColor, Color skinColor, String emoji) {
    return Column(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: skinColor,
          child: Text(emoji, style: const TextStyle(fontSize: 18)),
        ),
        Container(
          width: 28,
          height: 30,
          decoration: BoxDecoration(
            color: bodyColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ),
      ],
    );
  }

  Widget _circleButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.85),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 16, color: Colors.black87),
      ),
    );
  }

  Widget _buildDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _dot(true),
        const SizedBox(width: 5),
        _dot(false),
        const SizedBox(width: 5),
        _dot(false),
      ],
    );
  }

  Widget _dot(bool active) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: active ? teal : Colors.grey.shade300,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildWelcomeText() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Text(
            'Welcome to Our\nLearning Platform!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Colors.black87,
              height: 1.3,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'A place for everyone to grow and\nlearn together.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildIconGrid(BuildContext context) {
    final items = [
      {
        'icon': Icons.menu_book,
        'color': const Color(0xFF4A90D9),
        'label': 'Lessons',
        'route': '/discover',
      },
      {
        'icon': Icons.play_circle_fill,
        'color': const Color(0xFFE04A4A),
        'label': 'Videos',
        'route': '',
      },
      {
        'icon': Icons.palette,
        'color': const Color(0xFF9B59B6),
        'label': 'Creative',
        'route': '',
      },
      {
        'icon': Icons.movie,
        'color': const Color(0xFF1a5fb4),
        'label': 'Movies',
        'route': '',
      },
      {
        'icon': Icons.chat_bubble,
        'color': const Color(0xFF00A89A),
        'label': 'Chat',
        'route': '',
      },
      {'icon': Icons.forum, 'color': const Color(0xFFF0B429), 'label': 'Forum', 'route': ''},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.count(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: items.map((item) {
          return InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              final route = item['route'] as String;
              if (route.isNotEmpty) {
                Navigator.pushNamed(context, route);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${item['label']} — coming soon!'),
                    duration: const Duration(seconds: 1),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: Container(
              decoration: BoxDecoration(
                color: item['color'] as Color,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(item['icon'] as IconData, color: Colors.white, size: 30),
                  const SizedBox(height: 6),
                  Text(
                    item['label'] as String,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStartButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => Navigator.pushNamed(context, '/accessibility-setup'),
          style: ElevatedButton.styleFrom(
            backgroundColor: teal,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 0,
          ),
          child: const Text(
            'Start here!',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          ),
        ),
      ),
    );
  }
}