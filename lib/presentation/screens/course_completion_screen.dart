import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CourseCompletionScreen extends StatelessWidget {
  const CourseCompletionScreen({super.key});

  static const _bg = Color(0xFF0D1B1E);
  static const _cyan = Color(0xFF1AFFFF);

  Future<void> _onProceed(BuildContext context) async {
    try {
      Navigator.pushReplacementNamed(context, '/mentorship-hub');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Navigation error: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (FirebaseAuth.instance.currentUser == null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => Navigator.pushReplacementNamed(context, '/signup'),
      );
      return const SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SizedBox.shrink(),

              // ── "Congratulations!" pill badge ────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 30, vertical: 14),
                decoration: BoxDecoration(
                  color: _cyan,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text(
                  'Congratulations!',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // ── Proceed button ───────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () => _onProceed(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _cyan,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: const StadiumBorder(),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: const Text('Proceed'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
