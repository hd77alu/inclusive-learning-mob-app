import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth_bloc.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  App Outlook / Home Screen
//  • Fully stateless — auth state read from AuthBloc
//  • Hero section fades in with AnimatedOpacity
//  • Profile sheet is auth-aware (shows real user data when signed in)
//  • Responsive: compact for ≤ 5.5″, spacious for ≥ 6.7″
// ─────────────────────────────────────────────────────────────────────────────

class OutlookScreen extends StatefulWidget {
  const OutlookScreen({super.key});

  @override
  State<OutlookScreen> createState() => _OutlookScreenState();
}

class _OutlookScreenState extends State<OutlookScreen>
    with SingleTickerProviderStateMixin {
  static const Color teal = Color(0xFF00D4D4);

  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));

    // Trigger the entrance animation after the first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _animController.forward();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Treat ≥ 6.7″ phones (≥ 411 dp wide) and tablets as "large".
    final isLarge = screenWidth >= 400;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          // Already signed in — nothing extra to do on this screen.
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            _AppHeader(teal: teal),
            Expanded(
              child: SingleChildScrollView(
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: Column(
                      children: [
                        _HeroIllustration(teal: teal, isLarge: isLarge),
                        SizedBox(height: isLarge ? 16 : 10),
                        const _DotIndicator(teal: teal),
                        SizedBox(height: isLarge ? 12 : 8),
                        _WelcomeText(isLarge: isLarge),
                        SizedBox(height: isLarge ? 22 : 14),
                        _IconGrid(isLarge: isLarge),
                        SizedBox(height: isLarge ? 22 : 14),
                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            if (state is AuthAuthenticated) {
                              return const SizedBox.shrink();
                            }
                            return _StartButton(teal: teal);
                          },
                        ),
                        SizedBox(height: isLarge ? 28 : 20),
                      ],
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

// ── Sub-widgets (all stateless) ───────────────────────────────────────────────

class _AppHeader extends StatelessWidget {
  const _AppHeader({required this.teal});
  final Color teal;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: teal,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        bottom: 14,
      ),
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
}

class _HeroIllustration extends StatelessWidget {
  const _HeroIllustration({required this.teal, required this.isLarge});
  final Color teal;
  final bool isLarge;

  static const _people = [
    ('👴', Color(0xFFE07B30), Color(0xFFF5C5A3)),
    ('👦', Color(0xFF4A90D9), Color(0xFFD4956A)),
    ('🧔', Color(0xFFD4608A), Color(0xFFC4885A)),
    ('👧', Color(0xFF1A7AD4), Color(0xFFF0B8A0)),
    ('🧒', Color(0xFF9B59B6), Color(0xFFF5C090)),
    ('🧑‍🦽', Color(0xFF00A89A), Color(0xFFD4956A)),
  ];

  @override
  Widget build(BuildContext context) {
    final heroHeight = isLarge ? 250.0 : 210.0;

    return Stack(
      children: [
        Container(
          height: heroHeight,
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFc8e8f5), Color(0xFF88c5e0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: isLarge ? 14 : 10,
                runSpacing: isLarge ? 12 : 8,
                children: _people
                    .map((p) => _PersonAvatar(
                          emoji: p.$1,
                          bodyColor: p.$2,
                          skinColor: p.$3,
                          isLarge: isLarge,
                        ))
                    .toList(),
              ),
            ),
          ),
        ),
        // Back button
        Positioned(
          top: 10,
          left: 12,
          child: _CircleIconButton(
            icon: Icons.arrow_back,
            onTap: () => Navigator.maybePop(context),
          ),
        ),
        // Profile button — opens auth-aware bottom sheet
        Positioned(
          top: 10,
          right: 12,
          child: _CircleIconButton(
            icon: Icons.person,
            onTap: () => _showProfileSheet(context, teal),
          ),
        ),
      ],
    );
  }
}

void _showProfileSheet(BuildContext context, Color teal) {
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

          // Avatar
          CircleAvatar(
            radius: 38,
            backgroundColor: teal.withAlpha(38),
            child: const Icon(Icons.person, size: 42, color: Color(0xFF00D4D4)),
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

          // Info rows
          _ProfileRow(
            icon: Icons.email_outlined,
            label: 'Email',
            value: user?.email ?? '—',
          ),
          const Divider(height: 1),
          _ProfileRow(
            icon: Icons.verified_user_outlined,
            label: 'Verified',
            value: user == null
                ? '—'
                : (user.emailVerified ? 'Yes' : 'Pending'),
          ),
          const SizedBox(height: 20),

          // Action button
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

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({
    required this.icon,
    required this.label,
    required this.value,
  });
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
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ),
        ],
      ),
    );
  }
}

class _PersonAvatar extends StatelessWidget {
  const _PersonAvatar({
    required this.emoji,
    required this.bodyColor,
    required this.skinColor,
    required this.isLarge,
  });
  final String emoji;
  final Color bodyColor;
  final Color skinColor;
  final bool isLarge;

  @override
  Widget build(BuildContext context) {
    final r = isLarge ? 20.0 : 17.0;
    final bw = isLarge ? 32.0 : 26.0;
    final bh = isLarge ? 34.0 : 28.0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: r,
          backgroundColor: skinColor,
          child: Text(emoji, style: TextStyle(fontSize: r)),
        ),
        Container(
          width: bw,
          height: bh,
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
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(216),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: Colors.black87),
      ),
    );
  }
}

class _DotIndicator extends StatelessWidget {
  const _DotIndicator({required this.teal});
  final Color teal;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _Dot(active: true, teal: teal),
        const SizedBox(width: 6),
        _Dot(active: false, teal: teal),
        const SizedBox(width: 6),
        _Dot(active: false, teal: teal),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.active, required this.teal});
  final bool active;
  final Color teal;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: active ? 20 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: active ? teal : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class _WelcomeText extends StatelessWidget {
  const _WelcomeText({required this.isLarge});
  final bool isLarge;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          Text(
            'Welcome to Our\nLearning Platform!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isLarge ? 20 : 17,
              fontWeight: FontWeight.w900,
              color: Colors.black87,
              height: 1.3,
            ),
          ),
          SizedBox(height: isLarge ? 10 : 6),
          Text(
            'A place for everyone to grow and learn together.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isLarge ? 14 : 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

class _IconGrid extends StatelessWidget {
  const _IconGrid({required this.isLarge});
  final bool isLarge;

  static const _items = [
    (Icons.menu_book, Color(0xFF4A90D9), 'Lessons', '/signup'),
    (Icons.play_circle_fill, Color(0xFFE04A4A), 'Videos', ''),
    (Icons.palette, Color(0xFF9B59B6), 'Creative', ''),
    (Icons.movie, Color(0xFF1a5fb4), 'Movies', ''),
    (Icons.chat_bubble, Color(0xFF00A89A), 'Chat', ''),
    (Icons.forum, Color(0xFFF0B429), 'Forum', ''),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isLarge ? 24 : 16),
      child: GridView.count(
        crossAxisCount: 3,
        crossAxisSpacing: isLarge ? 14 : 10,
        mainAxisSpacing: isLarge ? 14 : 10,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: _items.map((item) {
          return _GridCard(
            icon: item.$1,
            color: item.$2,
            label: item.$3,
            route: item.$4,
            isLarge: isLarge,
          );
        }).toList(),
      ),
    );
  }
}

class _GridCard extends StatelessWidget {
  const _GridCard({
    required this.icon,
    required this.color,
    required this.label,
    required this.route,
    required this.isLarge,
  });
  final IconData icon;
  final Color color;
  final String label;
  final String route;
  final bool isLarge;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          final isLoggedIn =
              context.read<AuthBloc>().state is AuthAuthenticated;
          if (route.isNotEmpty && !isLoggedIn) {
            Navigator.pushNamed(context, route);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$label — coming soon!'),
                duration: const Duration(seconds: 1),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: Container(
          color: color,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: isLarge ? 34 : 28),
              SizedBox(height: isLarge ? 8 : 5),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isLarge ? 12 : 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StartButton extends StatelessWidget {
  const _StartButton({required this.teal});
  final Color teal;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => Navigator.pushNamed(context, '/signup'),
          style: ElevatedButton.styleFrom(
            backgroundColor: teal,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 2,
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
