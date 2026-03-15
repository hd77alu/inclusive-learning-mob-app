import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CourseCompletionScreen extends StatefulWidget {
  const CourseCompletionScreen({super.key});

  @override
  State<CourseCompletionScreen> createState() => _CourseCompletionScreenState();
}

class _CourseCompletionScreenState extends State<CourseCompletionScreen>
    with SingleTickerProviderStateMixin {
  static const Color _teal = Color(0xFF00D4D4);

  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();

    // Auth guard — only block if truly not signed in at all
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (FirebaseAuth.instance.currentUser == null) {
        Navigator.pushReplacementNamed(context, '/signup');
      }
    });

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnim = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLandscape = size.width > size.height;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0A1F1A), Color(0xFF0D2B22), Color(0xFF071510)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: IntrinsicHeight(
                child: isLandscape
                    ? _buildLandscapeLayout(context)
                    : _buildPortraitLayout(context),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Portrait layout — stacked vertically
  Widget _buildPortraitLayout(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(),
        _buildTrophyIcon(),
        const SizedBox(height: 32),
        _buildCongratsBadge(),
        const SizedBox(height: 16),
        _buildSubtitle(),
        const SizedBox(height: 24),
        _buildCertificateCard(),
        const Spacer(),
        _buildProceedButton(context),
        const SizedBox(height: 40),
      ],
    );
  }

  // Landscape layout — side by side
  Widget _buildLandscapeLayout(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTrophyIcon(),
              const SizedBox(height: 20),
              _buildCongratsBadge(),
              const SizedBox(height: 12),
              _buildSubtitle(),
            ],
          ),
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildCertificateCard(),
              const SizedBox(height: 24),
              _buildProceedButton(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTrophyIcon() {
    return ScaleTransition(
      scale: _scaleAnim,
      child: Container(
        width: 110,
        height: 110,
        decoration: BoxDecoration(
          color: _teal.withValues(alpha: 0.15),
          shape: BoxShape.circle,
          border: Border.all(color: _teal, width: 2),
          boxShadow: [
            BoxShadow(
              color: _teal.withValues(alpha: 0.3),
              blurRadius: 24,
              spreadRadius: 4,
            ),
          ],
        ),
        child: const Icon(
          Icons.emoji_events_rounded,
          size: 60,
          color: _teal,
        ),
      ),
    );
  }

  Widget _buildCongratsBadge() {
    return FadeTransition(
      opacity: _fadeAnim,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        decoration: BoxDecoration(
          color: _teal,
          borderRadius: BorderRadius.circular(30),
        ),
        child: const Text(
          'Congratulations!',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildSubtitle() {
    return FadeTransition(
      opacity: _fadeAnim,
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 40),
        child: Text(
          'You have successfully completed this course.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            color: Colors.white70,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  // Certificate card widget
  Widget _buildCertificateCard() {
    final user = FirebaseAuth.instance.currentUser;
    final displayName = (user == null || user.isAnonymous)
        ? 'Guest Learner'
        : (user.email ?? 'Learner');
    return FadeTransition(
      opacity: _fadeAnim,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _teal.withValues(alpha: 0.4),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              const Icon(Icons.workspace_premium, color: _teal, size: 32),
              const SizedBox(height: 10),
              const Text(
                'Certificate of Completion',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                displayName,
                style: const TextStyle(
                  color: _teal,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Inclusive Learning Platform',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProceedButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () =>
              Navigator.pushNamed(context, '/mentorship-hub'),
          style: ElevatedButton.styleFrom(
            backgroundColor: _teal,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 0,
          ),
          child: const Text(
            'Proceed to Mentorship Hub',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}