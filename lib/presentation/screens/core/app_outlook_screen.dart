import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '/blocs/auth_bloc.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  App Outlook Screen  (Welcome / Landing)
//  • Teal scaffold with classroom background + inner phone carousel
//  • Glowing "Start here!" button navigates to /signup
//  • Profile button opens auth-aware bottom sheet
// ─────────────────────────────────────────────────────────────────────────────

class OutlookScreen extends StatefulWidget {
  const OutlookScreen({super.key});
  @override
  State<OutlookScreen> createState() => _OutlookScreenState();
}

class _OutlookScreenState extends State<OutlookScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowCtrl;
  late Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _glowAnim = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00D9D9),
      body: SafeArea(
        child: Column(
          children: [
            // Top title
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Inclusive Learning Platform',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                  letterSpacing: 0.2,
                ),
              ),
            ),

            // Main area: classroom background + inner phone
            Expanded(
              child: Stack(
                children: [
                  const _ClassroomBackground(),
                  Center(child: _InnerPhone(onProfileTap: () => _showProfileSheet(context))),
                ],
              ),
            ),

            // Glowing "Start here!" button
            AnimatedBuilder(
              animation: _glowAnim,
              builder: (_, _) => GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/signup'),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 64, vertical: 14),
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00D9D9),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00D9D9)
                            .withValues(alpha: 0.45 + 0.45 * _glowAnim.value),
                        blurRadius: 20 + 16 * _glowAnim.value,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'Start here!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Auth-aware profile sheet ──────────────────────────────────────────────────

void _showProfileSheet(BuildContext context) {
  const teal = Color(0xFF00D9D9);
  final state = context.read<AuthBloc>().state;
  final user = state is AuthAuthenticated ? state.user : null;

  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    backgroundColor: Colors.white,
    builder: (sheetCtx) => Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          CircleAvatar(
            radius: 38,
            backgroundColor: teal.withAlpha(38),
            child: const Icon(Icons.person, size: 42, color: teal),
          ),
          const SizedBox(height: 12),
          Text(
            user?.displayName ?? 'Guest User',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Text(
            user != null ? 'Signed in' : 'Not signed in',
            style: TextStyle(
              color: user != null ? Colors.green.shade600 : Colors.grey,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 20),
          _ProfileRow(
            icon: Icons.email_outlined,
            label: 'Email',
            value: user?.email ?? '—',
          ),
          const Divider(height: 1),
          _ProfileRow(
            icon: Icons.verified_user_outlined,
            label: 'Verified',
            value: user == null ? '—' : (user.emailVerified ? 'Yes' : 'Pending'),
          ),
          const SizedBox(height: 20),
          if (user != null)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(sheetCtx);
                  context.read<AuthBloc>().add(AuthSignOut());
                },
                icon: const Icon(Icons.logout, size: 16),
                label: const Text('Sign Out'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  side: const BorderSide(color: Colors.redAccent),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            )
          else
            GestureDetector(
              onTap: () {
                Navigator.pop(sheetCtx);
                Navigator.pushNamed(context, '/signup');
              },
              child: Text.rich(
                TextSpan(
                  text: 'Want to save your progress? ',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                  children: [
                    TextSpan(
                      text: 'Sign up',
                      style: const TextStyle(
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

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade500),
          const SizedBox(width: 12),
          Text(label,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w700, color: Colors.black87)),
          const Spacer(),
          Flexible(
            child: Text(value,
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// BLURRED CLASSROOM BACKGROUND
// ─────────────────────────────────────────────
class _ClassroomBackground extends StatelessWidget {
  const _ClassroomBackground();

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        children: [
          // Base gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [Color(0xFFB8CFD8), Color(0xFFC5D8CC), Color(0xFFD0DDD5)],
              ),
            ),
          ),
          // Window light
          Positioned(
            top: -20,
            right: -10,
            child: Container(
              width: 180,
              height: 240,
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  colors: [Color(0x99FFFFD0), Colors.transparent],
                ),
              ),
            ),
          ),
          // Left silhouette body
          Positioned(
            bottom: 0,
            left: -15,
            child: _blob(120, 300, const Color(0xFF4A6A82),
                const BorderRadius.vertical(top: Radius.circular(80))),
          ),
          // Left face
          Positioned(
            bottom: 200,
            left: 18,
            child: _blob(72, 80, const Color(0xFFD4956A), BorderRadius.circular(40)),
          ),
          // Hijab
          Positioned(
            bottom: 240,
            left: 5,
            child: _blob(105, 70, const Color(0xFF3A5E7A), BorderRadius.circular(52)),
          ),
          // Right silhouette body
          Positioned(
            bottom: 0,
            right: -20,
            child: _blob(110, 260, const Color(0xFF4A6A88),
                const BorderRadius.vertical(top: Radius.circular(80))),
          ),
          // Right face
          Positioned(
            bottom: 170,
            right: 20,
            child: _blob(65, 75, const Color(0xFFC8855A), BorderRadius.circular(37)),
          ),
          // Desk
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 65,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0x55967D64)],
                ),
              ),
            ),
          ),
          // Tablet prop
          Positioned(
            bottom: 28,
            left: 25,
            child: Transform.rotate(
              angle: -0.17,
              child: Container(
                width: 50,
                height: 35,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _blob(double w, double h, Color color, BorderRadius radius) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.65),
        borderRadius: radius,
      ),
    );
  }
}

// ─────────────────────────────────────────────
// INNER PHONE SHELL
// ─────────────────────────────────────────────
class _InnerPhone extends StatelessWidget {
  const _InnerPhone({required this.onProfileTap});
  final VoidCallback onProfileTap;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.044,
      child: Transform.translate(
        offset: const Offset(0, -10),
        child: Container(
          width: 210,
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1E),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.55),
                blurRadius: 44,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          padding: const EdgeInsets.all(5),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: _InnerScreen(onProfileTap: onProfileTap),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// INNER SCREEN (carousel + grid)
// ─────────────────────────────────────────────
class _InnerScreen extends StatefulWidget {
  const _InnerScreen({required this.onProfileTap});
  final VoidCallback onProfileTap;

  @override
  State<_InnerScreen> createState() => _InnerScreenState();
}

class _InnerScreenState extends State<_InnerScreen> {
  static const int _slideCount = 6;
  final PageController _pageCtrl = PageController();
  int _page = 0;
  Timer? _timer;

  static const _titles = [
    'Welcome to Our\nLearning Platform!',
    'Learn Without\nBoundaries!',
    'Join Our\nCommunity!',
    'Learn Your Way',
    'Track Your Growth',
    'Connect & Grow',
  ];

  static const _subs = [
    'A place for everyone to grow\nand learn together.',
    'Breaking barriers through\ninclusive digital education.',
    '500+ learners already growing\nwith us today.',
    'Visual, audio & motor support\nbuilt in for every learner.',
    'Real-time progress & achievements\non every lesson you complete.',
    'Learn from expert mentors and\ngrow with a global community.',
  ];

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted || !_pageCtrl.hasClients) return;
      _pageCtrl.animateToPage(
        (_page + 1) % _slideCount,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
          // ── Status bar (punch-hole)
          Container(
            color: const Color(0xFFF5F9FC),
            padding: const EdgeInsets.fromLTRB(10, 5, 10, 4),
            child: Row(
              children: [
                Container(
                  width: 7, height: 7,
                  decoration: const BoxDecoration(
                      color: Color(0xFF111111), shape: BoxShape.circle),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: widget.onProfileTap,
                  child: Container(
                    width: 20, height: 20,
                    decoration: BoxDecoration(
                        color: Colors.grey.shade200, shape: BoxShape.circle),
                    child: const Icon(Icons.person_outline,
                        size: 12, color: Colors.black54),
                  ),
                ),
              ],
            ),
          ),

          // ── Nav bar (back arrow + profile)
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
            child: Row(
              children: [
                _navBtn(Icons.arrow_back_ios_new_rounded),
              ],
            ),
          ),

          // ── Carousel (visual only — no text inside)
          SizedBox(
            height: 148,
            child: PageView(
              controller: _pageCtrl,
              onPageChanged: (i) {
                setState(() => _page = i);
                _startTimer();
              },
              children: const [
                _Slide1Characters(),
                _Slide2Mission(),
                _Slide3Stats(),
                _Slide4Accessibility(),
                _Slide5Progress(),
                _Slide6Connect(),
              ],
            ),
          ),

          // ── Dot indicators
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_slideCount, (i) {
                final active = i == _page;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  width: active ? 14 : 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: active
                        ? const Color(0xFF00D9D9)
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
          ),

          // ── Title + subtitle (changes with slide)
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            child: Padding(
              key: ValueKey(_page),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                children: [
                  Text(
                    _titles[_page],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1A1A2E),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _subs[_page],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 7,
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 6),

          // Feature grid
          Padding(
            padding: const EdgeInsets.fromLTRB(9, 0, 9, 8),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              crossAxisSpacing: 5,
              mainAxisSpacing: 5,
              children: const [
                _GridTile(Icons.menu_book_rounded, Color(0xFF5B9EE8),
                    Color(0xFF3A7BD5), 'Discover'),
                _GridTile(Icons.videocam_rounded, Color(0xFF26C6DA),
                    Color(0xFF0097A7), 'Courses'),
                _GridTile(Icons.dashboard_customize_rounded, Color(0xFFFFC947),
                    Color(0xFFFF8F00), 'Preferences'),
                _GridTile(Icons.play_circle_filled_rounded, Color(0xFF81C784),
                    Color(0xFF388E3C), 'My Skills'),
                _GridTile(Icons.chat_bubble_rounded, Color(0xFF64B5F6),
                    Color(0xFF1976D2), 'Mentorship'),
                _GridTile(Icons.accessibility_new_rounded, Color(0xFFFFE57F),
                    Color(0xFFFFAB00), 'Accessibility'),
              ],
            ),
          ),
        ],
      ),
      ),
    );
  }


  Widget _navBtn(IconData icon) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.08), blurRadius: 4)
        ],
      ),
      child: Icon(icon, size: 11, color: Colors.black54),
    );
  }
}

// ─────────────────────────────────────────────
// GRID TILE
// ─────────────────────────────────────────────
class _GridTile extends StatelessWidget {
  final IconData icon;
  final Color c1, c2;
  final String label;
  const _GridTile(this.icon, this.c1, this.c2, this.label);

  void _showComingSoon(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 20),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 36, height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Icon badge
            Container(
              width: 60, height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [c1, c2]),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: c2.withValues(alpha: 0.4), blurRadius: 14, offset: const Offset(0, 4)),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(height: 16),
            Text(
              label,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1A1A2E)),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF00D9D9).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Coming Soon',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF00A0A8),
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Our team is working hard to bring you this feature. Stay tuned!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500, height: 1.5),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00D9D9),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  elevation: 0,
                ),
                child: const Text('Got it!', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showComingSoon(context),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [c1, c2],
          ),
          borderRadius: BorderRadius.circular(9),
          boxShadow: [
            BoxShadow(
                color: c2.withValues(alpha: 0.35),
                blurRadius: 8,
                offset: const Offset(0, 3))
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(height: 3),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 6,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SLIDE 1 — Animated AI Characters
// ─────────────────────────────────────────────
class _Slide1Characters extends StatefulWidget {
  const _Slide1Characters();
  @override
  State<_Slide1Characters> createState() => _Slide1State();
}

class _Slide1State extends State<_Slide1Characters>
    with TickerProviderStateMixin {
  late List<AnimationController> _ctrls;
  late List<Animation<double>> _anims;

  @override
  void initState() {
    super.initState();
    _ctrls = List.generate(
        8,
        (i) => AnimationController(
              vsync: this,
              duration: Duration(milliseconds: 2800 + i * 200),
            )..repeat(reverse: true));
    _anims = _ctrls
        .map((c) => Tween<double>(begin: 0, end: -5)
            .animate(CurvedAnimation(parent: c, curve: Curves.easeInOut)))
        .toList();
  }

  @override
  void dispose() {
    for (final c in _ctrls) { c.dispose(); }
    super.dispose();
  }

  Widget _float(int i, Widget child) => AnimatedBuilder(
        animation: _anims[i],
        builder: (_, _) => Transform.translate(
            offset: Offset(0, _anims[i].value), child: child),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFCCE8FF), Color(0xFFDFF0FF), Color(0xFFF0F8FF)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 4,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _float(0, _elderlyMan()),
                const SizedBox(width: 4),
                _float(1, _orangeGuy()),
                const SizedBox(width: 4),
                _float(2, _blueCenter()),
                const SizedBox(width: 4),
                _float(3, _purpleGuy()),
                const SizedBox(width: 4),
                _float(4, _pinkGirl()),
              ],
            ),
          ),
          Positioned(
            bottom: 6,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _float(5, _wheelchairBoy()),
                const SizedBox(width: 12),
                _float(6, _seatedCenter()),
                const SizedBox(width: 12),
                _float(7, _greenGirl()),
              ],
            ),
          ),
          Positioned(top: 8, left: 16, child: _sparkle(Colors.white)),
          Positioned(top: 14, right: 20, child: _sparkle(const Color(0xFFFFE082))),
          Positioned(top: 5, left: 90, child: _sparkle(const Color(0xFFB3E5FC))),
        ],
      ),
    );
  }

  Widget _sparkle(Color color) => Container(
        width: 5,
        height: 5,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );

  Widget _head(Color c1, Color c2, Color hair, {double size = 18}) {
    return Stack(children: [
      Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [c1, c2]),
              shape: BoxShape.circle)),
      Positioned(
          top: 0,
          left: 2,
          right: 2,
          child: Container(
              height: size * 0.35,
              decoration: BoxDecoration(
                  color: hair,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(size / 2))))),
    ]);
  }

  Widget _body(Color c1, Color c2, Color book, {double w = 22, double h = 26}) {
    return Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [c1, c2]),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6))),
        alignment: Alignment.bottomCenter,
        padding: const EdgeInsets.only(bottom: 2),
        child: Container(
            width: 14,
            height: 9,
            decoration:
                BoxDecoration(color: book, borderRadius: BorderRadius.circular(2))));
  }

  Widget _leg(Color c, {double w = 9, double h = 11}) => Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
          color: c,
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(3))));

  Widget _charCol(List<Widget> children) =>
      Column(mainAxisSize: MainAxisSize.min, children: children);

  Widget _elderlyMan() => _charCol([
        _head(const Color(0xFFD4A574), const Color(0xFFC08050),
            const Color(0xFFB0B0B0)),
        const SizedBox(height: 1),
        _body(const Color(0xFF66BB6A), const Color(0xFF388E3C),
            const Color(0xFFC62828)),
        Row(children: [
          _leg(const Color(0xFF1565C0)),
          const SizedBox(width: 2),
          _leg(const Color(0xFF1565C0))
        ]),
      ]);

  Widget _orangeGuy() => _charCol([
        _head(const Color(0xFFDBA07A), const Color(0xFFC07855),
            const Color(0xFF3E2723)),
        const SizedBox(height: 1),
        _body(const Color(0xFFFFA726), const Color(0xFFE65100),
            const Color(0xFFB71C1C),
            w: 23, h: 28),
        Row(children: [
          _leg(const Color(0xFF1565C0)),
          const SizedBox(width: 2),
          _leg(const Color(0xFF1565C0))
        ]),
      ]);

  Widget _blueCenter() => _charCol([
        _head(const Color(0xFFD4A07A), const Color(0xFFB87850),
            const Color(0xFF1A1A1A),
            size: 23),
        const SizedBox(height: 1),
        Container(
            width: 28,
            height: 32,
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF29B6F6), Color(0xFF0288D1)]),
                borderRadius: BorderRadius.vertical(top: Radius.circular(7))),
            alignment: Alignment.bottomCenter,
            padding: const EdgeInsets.only(bottom: 3),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 9, height: 12, color: const Color(0xFF1565C0)),
              Container(width: 1, color: const Color(0xFF0D47A1)),
              Container(width: 9, height: 12, color: const Color(0xFF1565C0)),
            ])),
        Row(children: [
          _leg(const Color(0xFF1A237E), w: 10, h: 12),
          const SizedBox(width: 2),
          _leg(const Color(0xFF1A237E), w: 10, h: 12)
        ]),
      ]);

  Widget _purpleGuy() => _charCol([
        _head(const Color(0xFFC8907A), const Color(0xFFA87060),
            const Color(0xFF212121)),
        const SizedBox(height: 1),
        _body(const Color(0xFFCE93D8), const Color(0xFF7B1FA2),
            const Color(0xFF4A148C),
            w: 23, h: 28),
        Row(children: [
          _leg(const Color(0xFF1565C0)),
          const SizedBox(width: 2),
          _leg(const Color(0xFF1565C0))
        ]),
      ]);

  Widget _pinkGirl() => _charCol([
        _head(const Color(0xFFD4A080), const Color(0xFFB87860),
            const Color(0xFF880E4F)),
        const SizedBox(height: 1),
        _body(const Color(0xFFF48FB1), const Color(0xFFC2185B),
            const Color(0xFF880E4F),
            w: 21, h: 25),
        Row(children: [
          _leg(const Color(0xFF1565C0), w: 8),
          const SizedBox(width: 2),
          _leg(const Color(0xFF1565C0), w: 8)
        ]),
      ]);

  Widget _wheelchairBoy() => _charCol([
        _head(const Color(0xFF90CAF9), const Color(0xFF1565C0),
            const Color(0xFF1A1A2E)),
        const SizedBox(height: 1),
        Container(
            width: 30,
            height: 16,
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                    colors: [Color(0xFF42A5F5), Color(0xFF1565C0)]),
                borderRadius: BorderRadius.all(Radius.circular(5))),
            child: const Icon(Icons.accessible_forward_rounded,
                color: Colors.white, size: 12)),
        const SizedBox(height: 1),
        Container(
            width: 16,
            height: 10,
            decoration: BoxDecoration(
                color: const Color(0xFFC62828),
                borderRadius: BorderRadius.circular(2))),
      ]);

  Widget _seatedCenter() => _charCol([
        _head(const Color(0xFFD4A07A), const Color(0xFFB87850),
            const Color(0xFF212121)),
        const SizedBox(height: 1),
        Container(
            width: 24,
            height: 20,
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                    colors: [Color(0xFFF5F5F5), Color(0xFFE0E0E0)]),
                borderRadius: BorderRadius.vertical(top: Radius.circular(6))),
            alignment: Alignment.center,
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 7, height: 10, color: const Color(0xFF00796B)),
              Container(width: 1, color: const Color(0xFF004D40)),
              Container(width: 7, height: 10, color: const Color(0xFF00796B)),
            ])),
        Row(children: [
          Transform.rotate(
              angle: 0.26,
              child: _leg(const Color(0xFF1565C0), w: 10, h: 8)),
          const SizedBox(width: 1),
          Transform.rotate(
              angle: -0.26,
              child: _leg(const Color(0xFF1565C0), w: 10, h: 8)),
        ]),
      ]);

  Widget _greenGirl() => _charCol([
        _head(const Color(0xFFD4A07A), const Color(0xFFB07050),
            const Color(0xFF3E2723)),
        const SizedBox(height: 1),
        Container(
            width: 20,
            height: 18,
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                    colors: [Color(0xFF8BC34A), Color(0xFF558B2F)]),
                borderRadius: BorderRadius.vertical(top: Radius.circular(5))),
            alignment: Alignment.center,
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 5, height: 8, color: const Color(0xFFC62828)),
              Container(width: 1, color: const Color(0xFFB71C1C)),
              Container(width: 5, height: 8, color: const Color(0xFFC62828)),
            ])),
        Row(children: [
          Transform.rotate(
              angle: 0.17,
              child: _leg(const Color(0xFF1565C0), w: 8, h: 8)),
          const SizedBox(width: 1),
          Transform.rotate(
              angle: -0.17,
              child: _leg(const Color(0xFF1565C0), w: 8, h: 8)),
        ]),
      ]);
}

// ─────────────────────────────────────────────
// SLIDE 2 — Mission
// ─────────────────────────────────────────────
class _Slide2Mission extends StatelessWidget {
  const _Slide2Mission();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFF66BB6A), Color(0xFF2E7D32)]),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: const Color(0xFF2E7D32).withValues(alpha: 0.35),
                    blurRadius: 14)
              ],
            ),
            child: const Icon(Icons.star_rounded, color: Colors.white, size: 30),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _iconBtn(Icons.menu_book_rounded),
              const SizedBox(width: 10),
              _iconBtn(Icons.play_arrow_rounded),
              const SizedBox(width: 10),
              _iconBtn(Icons.chat_rounded),
              const SizedBox(width: 10),
              _iconBtn(Icons.accessibility_new_rounded),
            ],
          ),
        ],
      ),
    );
  }

  Widget _iconBtn(IconData icon) => Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1), blurRadius: 6)
            ]),
        child: Icon(icon, color: const Color(0xFF388E3C), size: 14),
      );
}

// ─────────────────────────────────────────────
// SLIDE 3 — Stats
// ─────────────────────────────────────────────
class _Slide3Stats extends StatelessWidget {
  const _Slide3Stats();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(children: [
            _statCard('500+', 'Learners', const Color(0xFF1565C0)),
            const SizedBox(width: 5),
            _statCard('120+', 'Courses', const Color(0xFF00838F)),
            const SizedBox(width: 5),
            _statCard('98%', 'Satisfied', const Color(0xFF2E7D32)),
          ]),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08), blurRadius: 6)
              ],
            ),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Course completion rate',
                  style:
                      TextStyle(fontSize: 6, color: Color(0xFF555555))),
              const SizedBox(height: 3),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: const LinearProgressIndicator(
                  value: 0.87,
                  minHeight: 5,
                  backgroundColor: Color(0xFFE3F2FD),
                  valueColor:
                      AlwaysStoppedAnimation(Color(0xFF1565C0)),
                ),
              ),
              const SizedBox(height: 1),
              const Align(
                alignment: Alignment.centerRight,
                child: Text('87%',
                    style: TextStyle(
                        fontSize: 6, color: Color(0xFF1565C0))),
              ),
            ]),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _avatar(const Color(0xFFD4A07A)),
              _avatar(const Color(0xFF90CAF9), offset: -8),
              _avatar(const Color(0xFFCE93D8), offset: -8),
              _avatar(const Color(0xFFA5D6A7), offset: -8),
              Transform.translate(
                offset: const Offset(-8, 0),
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Center(
                    child: Text('+96',
                        style: TextStyle(
                            fontSize: 5.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1565C0))),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statCard(String value, String label, Color color) => Expanded(
        child: Container(
          padding:
              const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08), blurRadius: 6)
            ],
          ),
          child: Column(children: [
            Text(value,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: color)),
            Text(label,
                style: TextStyle(fontSize: 5.5, color: color)),
          ]),
        ),
      );

  Widget _avatar(Color color, {double offset = 0}) => Transform.translate(
        offset: Offset(offset, 0),
        child: Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15), blurRadius: 4)
            ],
          ),
        ),
      );
}

// ─────────────────────────────────────────────
// SLIDE 4 — Accessibility
// ─────────────────────────────────────────────
class _Slide4Accessibility extends StatelessWidget {
  const _Slide4Accessibility();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF3E5F5), Color(0xFFCE93D8)],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF7B1FA2),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: const Color(0xFF4A148C).withValues(alpha: 0.4), blurRadius: 14),
              ],
            ),
            child: const Icon(Icons.accessibility_new_rounded, color: Colors.white, size: 26),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _featureChip(Icons.closed_caption_rounded, 'Captions', const Color(0xFF7B1FA2)),
              const SizedBox(width: 8),
              _featureChip(Icons.contrast_rounded, 'Contrast', const Color(0xFF6A1B9A)),
              const SizedBox(width: 8),
              _featureChip(Icons.record_voice_over_rounded, 'Voice', const Color(0xFF4A148C)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _featureChip(IconData icon, String text, Color color) {
    return Column(
      children: [
        Container(
          width: 30, height: 30,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: color.withValues(alpha: 0.25), blurRadius: 6)],
          ),
          child: Icon(icon, size: 15, color: color),
        ),
        const SizedBox(height: 3),
        Text(text, style: TextStyle(fontSize: 5.5, color: color, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// SLIDE 5 — Progress Tracking
// ─────────────────────────────────────────────
class _Slide5Progress extends StatelessWidget {
  const _Slide5Progress();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF8E1), Color(0xFFFFCC02)],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFFFB300), Color(0xFFFF6F00)]),
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: const Color(0xFFFF6F00).withValues(alpha: 0.4), blurRadius: 14)],
            ),
            child: const Icon(Icons.emoji_events_rounded, color: Colors.white, size: 26),
          ),
          const SizedBox(height: 14),
          // Skill bars
          _skillBar('Reading',    0.85, const Color(0xFFFF8F00)),
          const SizedBox(height: 5),
          _skillBar('Writing',    0.62, const Color(0xFFFFA000)),
          const SizedBox(height: 5),
          _skillBar('Listening',  0.74, const Color(0xFFFFB300)),
        ],
      ),
    );
  }

  Widget _skillBar(String label, double value, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 38,
          child: Text(label, style: const TextStyle(fontSize: 6, color: Color(0xFF4E2600), fontWeight: FontWeight.w600)),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 5,
              backgroundColor: Colors.white.withValues(alpha: 0.6),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '${(value * 100).round()}%',
          style: TextStyle(fontSize: 5.5, color: color, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// SLIDE 6 — Connect & Grow
// ─────────────────────────────────────────────
class _Slide6Connect extends StatelessWidget {
  const _Slide6Connect();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE8EAF6), Color(0xFF9FA8DA)],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF3949AB), Color(0xFF1A237E)]),
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: const Color(0xFF1A237E).withValues(alpha: 0.4), blurRadius: 14)],
            ),
            child: const Icon(Icons.groups_rounded, color: Colors.white, size: 26),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _avatar(const Color(0xFF3949AB), Icons.person_rounded, 'Mentor'),
              const SizedBox(width: 6),
              Container(
                width: 20, height: 2,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF3949AB), Color(0xFF7986CB)]),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
              const Icon(Icons.favorite_rounded, size: 10, color: Color(0xFFE53935)),
              Container(
                width: 20, height: 2,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF7986CB), Color(0xFF3949AB)]),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
              const SizedBox(width: 6),
              _avatar(const Color(0xFF7986CB), Icons.school_rounded, 'You'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _avatar(Color color, IconData icon, String label) {
    return Column(
      children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 8)],
          ),
          child: Icon(icon, color: Colors.white, size: 16),
        ),
        const SizedBox(height: 3),
        Text(label, style: TextStyle(fontSize: 5.5, color: color, fontWeight: FontWeight.w700)),
      ],
    );
  }
}