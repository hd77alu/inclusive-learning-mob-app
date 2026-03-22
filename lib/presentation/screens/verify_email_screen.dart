import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth_bloc.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Verify Email Screen
//  • Shown after sign-up until the user clicks the link in their inbox
//  • Auto-polls every 5 s via AuthReloadUser — works like OTP verification
//  • "Resend" button with 60-second cool-down
//  • "I've verified" manual check button
//  • Sign-out link
// ─────────────────────────────────────────────────────────────────────────────

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen>
    with SingleTickerProviderStateMixin {
  static const Color teal = Color(0xFF00D4D4);
  static const Color darkBg = Color(0xFF1C2B36);

  Timer? _pollTimer;
  Timer? _cooldownTimer;
  int _cooldownSeconds = 0;

  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();

    // Pulsing envelope animation
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    // Poll Firebase every 5 seconds to detect when the user verifies.
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted) {
        context.read<AuthBloc>().add(AuthReloadUser());
      }
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _cooldownTimer?.cancel();
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _resendEmail() {
    context.read<AuthBloc>().add(AuthSendEmailVerification());
    setState(() => _cooldownSeconds = 60);
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_cooldownSeconds <= 1) {
        t.cancel();
        if (mounted) setState(() => _cooldownSeconds = 0);
      } else {
        if (mounted) setState(() => _cooldownSeconds--);
      }
    });
  }

  void _checkNow() {
    context.read<AuthBloc>().add(AuthReloadUser());
  }

  void _signOut() {
    _pollTimer?.cancel();
    context.read<AuthBloc>().add(AuthSignOut());
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLarge = screenWidth >= 400;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          // Verified! Head to home.
          Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
        } else if (state is AuthUnauthenticated) {
          Navigator.pushNamedAndRemoveUntil(context, '/signup', (_) => false);
        } else if (state is AuthEmailVerificationSent) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Verification email sent! Check your inbox.'),
              backgroundColor: Color(0xFF00D4D4),
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        String? userEmail;
        if (state is AuthEmailVerificationRequired) {
          userEmail = state.user.email;
        } else if (state is AuthEmailVerificationSent) {
          userEmail = state.user.email;
        }

        return Scaffold(
          backgroundColor: darkBg,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isLarge ? 40 : 28,
                vertical: 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),

                  // ── Animated envelope ──
                  Center(
                    child: ScaleTransition(
                      scale: _pulseAnim,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: teal.withAlpha(38),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.mark_email_unread_outlined,
                          size: 52,
                          color: teal,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── Title ──
                  const Text(
                    'Verify your email',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── Subtitle ──
                  Text(
                    userEmail != null
                        ? 'We sent a verification link to:\n$userEmail\n\nClick the link in the email to activate your account.'
                        : 'Check your inbox and click the verification link to continue.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 13,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── Status card ──
                  _StatusCard(isLoading: isLoading, teal: teal),
                  const SizedBox(height: 28),

                  // ── "I've verified" button ──
                  ElevatedButton.icon(
                    onPressed: isLoading ? null : _checkNow,
                    icon: const Icon(Icons.check_circle_outline, size: 18),
                    label: const Text(
                      "I've verified my email",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: teal,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ── Resend button ──
                  OutlinedButton.icon(
                    onPressed:
                        (isLoading || _cooldownSeconds > 0) ? null : _resendEmail,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: Text(
                      _cooldownSeconds > 0
                          ? 'Resend in ${_cooldownSeconds}s'
                          : 'Resend verification email',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: teal,
                      side: const BorderSide(color: teal),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── Divider + sign-out ──
                  const Divider(color: Colors.white12),
                  const SizedBox(height: 12),
                  Center(
                    child: TextButton(
                      onPressed: _signOut,
                      child: const Text(
                        'Use a different account — Sign out',
                        style: TextStyle(color: Colors.white38, fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.isLoading, required this.teal});
  final bool isLoading;
  final Color teal;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2E4A5A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF00D4D4),
                  ),
                )
              : const Icon(Icons.hourglass_top_rounded,
                  size: 20, color: Color(0xFF00D4D4)),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Waiting for email verification…\nThis page checks automatically every 5 seconds.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
