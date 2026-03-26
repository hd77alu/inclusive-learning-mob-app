import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/presentation/widgets/accessible_widgets.dart';
import 'preferences_screen.dart';
import '../skills/my_skills_screen.dart';
import '../course/discover_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  static const Color _teal = Color(0xFF00D4D4);
  static const Color _bg = Color(0xFFF5F5F5);

  late final AnimationController _ctrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName ?? 'Learner';
    final email = user?.email ?? 'No email';
    final isVerified = user?.emailVerified ?? false;
    final isGoogleUser = user?.providerData.any((p) => p.providerId == 'google.com') ?? false;
    final initials = displayName.isNotEmpty
        ? displayName.trim().split(' ').map((e) => e[0]).take(2).join()
        : '?';

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF0D1B1E) : _bg;

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  child: Column(
                    children: [
                      _buildAvatarCard(initials, displayName, email, isVerified || isGoogleUser),
                      const SizedBox(height: 4),
                      _buildStatsRow(),
                      const SizedBox(height: 20),
                      _buildSectionLabel('Account'),
                      const SizedBox(height: 8),
                      _buildMenuCard([
                        _MenuItem(
                          icon: Icons.email_outlined,
                          label: 'Email',
                          subtitle: email,
                          onTap: null,
                        ),
                        _MenuItem(
                          icon: Icons.tune_outlined,
                          label: 'Preferences',
                          subtitle: 'Notifications, language & more',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PreferencesScreen(),
                            ),
                          ),
                        ),
                        _MenuItem(
                          icon: Icons.accessibility_new_outlined,
                          label: 'Accessibility',
                          subtitle: 'Customize your experience',
                          onTap: () => Navigator.pushNamed(
                              context, '/accessibility-setup'),
                        ),
                      ]),
                      const SizedBox(height: 16),
                      _buildSectionLabel('Learning'),
                      const SizedBox(height: 8),
                      _buildMenuCard([
                        _MenuItem(
                          icon: Icons.calendar_month_outlined,
                          label: 'My Sessions',
                          subtitle: 'View your booked mentorship sessions',
                          onTap: () => Navigator.pushNamed(context, '/my-sessions'),
                        ),
                        _MenuItem(
                          icon: Icons.star_outline_rounded,
                          label: 'My Skills',
                          subtitle: 'View and manage your skill portfolio',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const MySkillsScreen(),
                            ),
                          ),
                        ),
                        _MenuItem(
                          icon: Icons.school_outlined,
                          label: 'My Courses',
                          subtitle: 'Browse your enrolled courses',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const DiscoverScreen(),
                            ),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 24),
                      Semantics(
                        button: true,
                        label: 'Logout',
                        hint: 'Double tap to sign out of your account',
                        child: SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _confirmLogout,
                            icon: const Icon(Icons.logout, color: Colors.red),
                            label: const AccessibleText(
                              'LOGOUT',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.red),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: _teal,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        bottom: 40,
        left: 4,
        right: 4,
      ),
      child: Row(
        children: [
          AccessibleIconButton(
            icon: Icons.arrow_back,
            onPressed: () => Navigator.maybePop(context),
            tooltip: 'Go back',
            color: Colors.black,
          ),
          Expanded(
            child: Column(
              children: [
                AccessibleText(
                  'Inclusive Learning Platform',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
                AccessibleText(
                  'My Profile',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          AccessibleIconButton(
            icon: Icons.logout,
            tooltip: 'LOGOUT',
            onPressed: _confirmLogout,
            color: Colors.black87,
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarCard(String initials, String displayName, String email, bool isVerified) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1A2426) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    
    return Transform.translate(
      offset: const Offset(0, -28),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Semantics(
              image: true,
              label: 'Profile avatar with initials $initials',
              child: CircleAvatar(
                radius: 40,
                backgroundColor: _teal,
                child: AccessibleText(
                  initials.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            AccessibleText(
              displayName,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: textColor,
              ),
            ),
            const SizedBox(height: 4),
            if (isVerified)
              Semantics(
                label: 'Account verified',
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified, size: 14, color: Colors.green.shade700),
                      const SizedBox(width: 4),
                      AccessibleText(
                        'Verified',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Semantics(
                label: 'Account not verified',
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.info_outline, size: 14, color: Colors.orange.shade700),
                      const SizedBox(width: 4),
                      AccessibleText(
                        'Unverified',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange.shade700,
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

  Widget _buildStatsRow() {
    return Row(
      children: [
        _buildStatCard(icon: Icons.school_rounded, label: 'Courses', value: '—'),
        const SizedBox(width: 12),
        _buildStatCard(icon: Icons.star_rounded, label: 'Skills', value: '—'),
        const SizedBox(width: 12),
        _buildStatCard(
            icon: Icons.workspace_premium_rounded, label: 'Badges', value: '—'),
      ],
    );
  }

  Widget _buildStatCard(
      {required IconData icon,
      required String label,
      required String value}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1A2426) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    
    return Expanded(
      child: Semantics(
        label: '$value $label',
        hint: 'Your learning statistics',
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: _teal, size: 22),
              const SizedBox(height: 6),
              AccessibleText(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 2),
              AccessibleText(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: AccessibleText(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
          color: Colors.grey.shade500,
        ),
      ),
    );
  }

  Widget _buildMenuCard(List<_MenuItem> items) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1A2426) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isLast = index == items.length - 1;
          return Column(
            children: [
              Semantics(
                button: item.onTap != null,
                label: item.label,
                hint: item.subtitle ?? (item.onTap != null ? 'Tap to open' : null),
                child: InkWell(
                  onTap: item.onTap,
                  borderRadius: BorderRadius.vertical(
                    top: index == 0 ? const Radius.circular(16) : Radius.zero,
                    bottom: isLast ? const Radius.circular(16) : Radius.zero,
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _teal.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(item.icon, size: 18, color: _teal),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AccessibleText(
                                item.label,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: textColor,
                                ),
                              ),
                              if (item.subtitle != null)
                                AccessibleText(
                                  item.subtitle!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                        if (item.onTap != null)
                          Icon(Icons.chevron_right, color: Colors.grey.shade400),
                      ],
                    ),
                  ),
                ),
              ),
              if (!isLast)
                Divider(height: 1, indent: 56, color: Colors.grey.shade100),
            ],
          );
        }),
      ),
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('LOGOUT',
            style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/signup');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
            ),
            child: const Text('LOGOUT'),
          ),
        ],
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback? onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    this.subtitle,
    required this.onTap,
  });
}
