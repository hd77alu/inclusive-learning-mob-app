import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth_bloc.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Forgot Password Screen
//  • User enters their email and the BLoC sends a Firebase reset link
//  • Success state shows a confirmation card with instructions
//  • Stateless beyond the form — all logic in AuthBloc
// ─────────────────────────────────────────────────────────────────────────────

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  static const Color teal = Color(0xFF00D4D4);
  static const Color darkBg = Color(0xFF1C2B36);

  final _emailCtrl = TextEditingController();
  String? _emailErr;

  static final _emailRx = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.]+$');

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  bool _validate() {
    final email = _emailCtrl.text.trim();
    String? err;
    if (email.isEmpty) {
      err = 'Email is required';
    } else if (!_emailRx.hasMatch(email)) {
      err = 'Enter a valid email address';
    }
    setState(() => _emailErr = err);
    return err == null;
  }

  void _submit() {
    if (!_validate()) return;
    context.read<AuthBloc>().add(
          AuthSendPasswordReset(email: _emailCtrl.text.trim()),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
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
        final isSuccess = state is AuthPasswordResetSent;

        return Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            children: [
              // ── Teal header ──
              Container(
                width: double.infinity,
                color: teal,
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 12,
                  bottom: 14,
                  left: 16,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text(
                        'Reset Password',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48), // balance the back button
                  ],
                ),
              ),

              // ── Dark body ──
              Expanded(
                child: Container(
                  color: darkBg,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 16),

                        // Lock icon
                        const _LockIcon(teal: teal),
                        const SizedBox(height: 24),

                        const Text(
                          'Forgot your password?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Enter your registered email and we\'ll send you a link to reset your password.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 32),

                        if (isSuccess) ...[
                          _SuccessCard(
                            email: _emailCtrl.text.trim(),
                            teal: teal,
                            onBack: () => Navigator.pop(context),
                          ),
                        ] else ...[
                          // Email field
                          _ResetField(
                            controller: _emailCtrl,
                            errorText: _emailErr,
                            teal: teal,
                            onChanged: (_) {
                              if (_emailErr != null) {
                                setState(() => _emailErr = null);
                              }
                            },
                          ),
                          const SizedBox(height: 24),

                          // Submit button
                          ElevatedButton(
                            onPressed: isLoading ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: teal,
                              foregroundColor: Colors.black,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.black,
                                    ),
                                  )
                                : const Text(
                                    'Send Reset Link',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 20),

                          Center(
                            child: TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                'Back to Sign In',
                                style: TextStyle(
                                  color: teal,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _LockIcon extends StatelessWidget {
  const _LockIcon({required this.teal});
  final Color teal;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: teal.withAlpha(38),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.lock_reset, size: 40, color: Color(0xFF00D4D4)),
      ),
    );
  }
}

class _ResetField extends StatelessWidget {
  const _ResetField({
    required this.controller,
    required this.teal,
    required this.onChanged,
    this.errorText,
  });

  final TextEditingController controller;
  final Color teal;
  final ValueChanged<String> onChanged;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          onChanged: onChanged,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: 'Email address',
            hintStyle: const TextStyle(color: Colors.black45, fontSize: 13),
            prefixIcon: const Icon(
              Icons.email_outlined,
              size: 18,
              color: Colors.black54,
            ),
            filled: true,
            fillColor: const Color(0xFFC8CDD0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: errorText != null
                  ? const BorderSide(color: Colors.redAccent, width: 1.5)
                  : BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: errorText != null ? Colors.redAccent : teal,
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            errorText!,
            style: const TextStyle(
              color: Colors.redAccent,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}

class _SuccessCard extends StatelessWidget {
  const _SuccessCard({
    required this.email,
    required this.teal,
    required this.onBack,
  });

  final String email;
  final Color teal;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF2E4A5A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.mark_email_read_outlined,
                size: 48, color: Color(0xFF00D4D4)),
            const SizedBox(height: 16),
            const Text(
              'Check your inbox!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'We sent a password reset link to:\n$email',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Check your spam folder if you don\'t see it.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white38, fontSize: 11),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onBack,
                style: ElevatedButton.styleFrom(
                  backgroundColor: teal,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Back to Sign In',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
