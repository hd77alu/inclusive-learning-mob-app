import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth_bloc.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Sign-Up / Sign-In Screen
//  • Two tabs: "Sign In" and "Sign Up"
//  • Email + Password auth (Firebase) + Google OAuth
//  • All business logic delegated to AuthBloc — zero auth code in this file
//  • Input validation on every field with inline error messages
//  • Password visibility toggle on all password fields
//  • BlocListener drives navigation and SnackBar feedback
// ─────────────────────────────────────────────────────────────────────────────

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with SingleTickerProviderStateMixin {
  static const Color teal = Color(0xFF00D4D4);
  static const Color darkBg = Color(0xFF1C2B36);

  late final TabController _tabController;

  // Sign-In tab controllers
  final _siEmailCtrl = TextEditingController();
  final _siPasswordCtrl = TextEditingController();
  bool _siPasswordVisible = false;

  // Sign-Up tab controllers
  final _suNameCtrl = TextEditingController();
  final _suEmailCtrl = TextEditingController();
  final _suPasswordCtrl = TextEditingController();
  final _suConfirmCtrl = TextEditingController();
  bool _suPasswordVisible = false;
  bool _suConfirmVisible = false;

  // Inline error texts
  String? _siEmailErr;
  String? _siPasswordErr;
  String? _suNameErr;
  String? _suEmailErr;
  String? _suPasswordErr;
  String? _suConfirmErr;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this)
      ..addListener(() {
        if (mounted) setState(() {});
      });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _siEmailCtrl.dispose();
    _siPasswordCtrl.dispose();
    _suNameCtrl.dispose();
    _suEmailCtrl.dispose();
    _suPasswordCtrl.dispose();
    _suConfirmCtrl.dispose();
    super.dispose();
  }

  // ── Validation ─────────────────────────────────────────────────────────────

  static final _emailRx = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.]+$');

  bool _validateSignIn() {
    bool ok = true;
    final email = _siEmailCtrl.text.trim();
    final pass = _siPasswordCtrl.text;

    String? emailErr;
    if (email.isEmpty) {
      emailErr = 'Email is required';
      ok = false;
    } else if (!_emailRx.hasMatch(email)) {
      emailErr = 'Enter a valid email address';
      ok = false;
    }

    String? passErr;
    if (pass.isEmpty) {
      passErr = 'Password is required';
      ok = false;
    } else if (pass.length < 6) {
      passErr = 'Password must be at least 6 characters';
      ok = false;
    }

    setState(() {
      _siEmailErr = emailErr;
      _siPasswordErr = passErr;
    });
    return ok;
  }

  bool _validateSignUp() {
    bool ok = true;
    final name = _suNameCtrl.text.trim();
    final email = _suEmailCtrl.text.trim();
    final pass = _suPasswordCtrl.text;
    final confirm = _suConfirmCtrl.text;

    String? nameErr;
    if (name.isEmpty) {
      nameErr = 'Full name is required';
      ok = false;
    } else if (name.length < 2) {
      nameErr = 'Name must be at least 2 characters';
      ok = false;
    }

    String? emailErr;
    if (email.isEmpty) {
      emailErr = 'Email is required';
      ok = false;
    } else if (!_emailRx.hasMatch(email)) {
      emailErr = 'Enter a valid email address';
      ok = false;
    }

    String? passErr;
    if (pass.isEmpty) {
      passErr = 'Password is required';
      ok = false;
    } else if (pass.length < 6) {
      passErr = 'Use at least 6 characters';
      ok = false;
    } else if (!RegExp(r'[A-Z]').hasMatch(pass)) {
      passErr = 'Include at least one uppercase letter';
      ok = false;
    }

    String? confirmErr;
    if (confirm.isEmpty) {
      confirmErr = 'Please confirm your password';
      ok = false;
    } else if (pass != confirm) {
      confirmErr = 'Passwords do not match';
      ok = false;
    }

    setState(() {
      _suNameErr = nameErr;
      _suEmailErr = emailErr;
      _suPasswordErr = passErr;
      _suConfirmErr = confirmErr;
    });
    return ok;
  }

  // ── Handlers ───────────────────────────────────────────────────────────────

  void _handleSignIn() {
    if (!_validateSignIn()) return;
    context.read<AuthBloc>().add(
          AuthSignInWithEmail(
            email: _siEmailCtrl.text.trim(),
            password: _siPasswordCtrl.text,
          ),
        );
  }

  void _handleSignUp() {
    if (!_validateSignUp()) return;
    context.read<AuthBloc>().add(
          AuthSignUpWithEmail(
            name: _suNameCtrl.text.trim(),
            email: _suEmailCtrl.text.trim(),
            password: _suPasswordCtrl.text,
          ),
        );
  }

  void _handleGoogle() {
    context.read<AuthBloc>().add(AuthSignInWithGoogle());
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLarge = screenWidth >= 400;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Welcome, ${state.user.displayName ?? state.user.email}!',
              ),
              backgroundColor: teal,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
        } else if (state is AuthEmailVerificationSent) {
          Navigator.pushReplacementNamed(context, '/verify-email');
        } else if (state is AuthEmailVerificationRequired) {
          Navigator.pushReplacementNamed(context, '/verify-email');
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline,
                      color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(state.message)),
                ],
              ),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            children: [
              // ── Teal header ──
              _SignUpHeader(teal: teal),

              // ── Dark body ──
              Expanded(
                child: Container(
                  color: darkBg,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: isLarge ? 32 : 24,
                      vertical: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Avatar
                        _AvatarWidget(teal: teal, darkBg: darkBg),
                        const SizedBox(height: 20),

                        // Tab bar
                        _AuthTabBar(
                          controller: _tabController,
                          teal: teal,
                        ),
                        const SizedBox(height: 20),

                        // Tab content — IndexedStack sizes to actual content,
                        // no fixed height needed (avoids overflow).
                        if (_tabController.index == 0)
                          _SignInForm(
                            emailCtrl: _siEmailCtrl,
                            passwordCtrl: _siPasswordCtrl,
                            emailErr: _siEmailErr,
                            passwordErr: _siPasswordErr,
                            passwordVisible: _siPasswordVisible,
                            teal: teal,
                            onEmailChanged: (_) {
                              if (_siEmailErr != null) {
                                setState(() => _siEmailErr = null);
                              }
                            },
                            onPasswordChanged: (_) {
                              if (_siPasswordErr != null) {
                                setState(() => _siPasswordErr = null);
                              }
                            },
                            onTogglePassword: () => setState(
                              () =>
                                  _siPasswordVisible = !_siPasswordVisible,
                            ),
                            onForgotPassword: () => Navigator.pushNamed(
                                context, '/forgot-password'),
                            onSignIn: isLoading ? null : _handleSignIn,
                          )
                        else
                          _SignUpForm(
                            nameCtrl: _suNameCtrl,
                            emailCtrl: _suEmailCtrl,
                            passwordCtrl: _suPasswordCtrl,
                            confirmCtrl: _suConfirmCtrl,
                            nameErr: _suNameErr,
                            emailErr: _suEmailErr,
                            passwordErr: _suPasswordErr,
                            confirmErr: _suConfirmErr,
                            passwordVisible: _suPasswordVisible,
                            confirmVisible: _suConfirmVisible,
                            teal: teal,
                            onNameChanged: (_) {
                              if (_suNameErr != null) {
                                setState(() => _suNameErr = null);
                              }
                            },
                            onEmailChanged: (_) {
                              if (_suEmailErr != null) {
                                setState(() => _suEmailErr = null);
                              }
                            },
                            onPasswordChanged: (_) {
                              if (_suPasswordErr != null) {
                                setState(() => _suPasswordErr = null);
                              }
                            },
                            onConfirmChanged: (_) {
                              if (_suConfirmErr != null) {
                                setState(() => _suConfirmErr = null);
                              }
                            },
                            onTogglePassword: () => setState(
                              () =>
                                  _suPasswordVisible = !_suPasswordVisible,
                            ),
                            onToggleConfirm: () => setState(
                              () =>
                                  _suConfirmVisible = !_suConfirmVisible,
                            ),
                            onSignUp: isLoading ? null : _handleSignUp,
                          ),

                        const SizedBox(height: 8),

                        // ── Divider ──
                        Row(
                          children: [
                            const Expanded(child: Divider(color: Colors.white24)),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                'or',
                                style: TextStyle(
                                  color: Colors.white38,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const Expanded(child: Divider(color: Colors.white24)),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // ── Google button ──
                        _GoogleButton(
                          isLoading: isLoading,
                          onPressed: isLoading ? null : _handleGoogle,
                        ),
                        const SizedBox(height: 24),

                        // ── Loading indicator ──
                        if (isLoading)
                          const Center(
                            child: CircularProgressIndicator(color: teal),
                          ),

                        // ── Home button ──
                        Center(
                          child: GestureDetector(
                            onTap: () => Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/outlook',
                              (_) => false,
                            ),
                            child: Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: teal,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.home,
                                color: Colors.black,
                                size: 28,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
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

class _SignUpHeader extends StatelessWidget {
  const _SignUpHeader({required this.teal});
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

class _AvatarWidget extends StatelessWidget {
  const _AvatarWidget({required this.teal, required this.darkBg});
  final Color teal;
  final Color darkBg;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Stack(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: const Color(0xFF2E4A5A),
            child: const Icon(Icons.person, size: 32, color: Colors.white70),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: teal,
                shape: BoxShape.circle,
                border: Border.all(color: darkBg, width: 1.5),
              ),
              child: const Icon(Icons.camera_alt, size: 11, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthTabBar extends StatelessWidget {
  const _AuthTabBar({required this.controller, required this.teal});
  final TabController controller;
  final Color teal;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2E4A5A),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TabBar(
        controller: controller,
        indicator: BoxDecoration(
          color: teal,
          borderRadius: BorderRadius.circular(8),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.black,
        unselectedLabelColor: Colors.white54,
        labelStyle:
            const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: 'Sign In'),
          Tab(text: 'Sign Up'),
        ],
      ),
    );
  }
}

// ── Sign-In Form ──────────────────────────────────────────────────────────────

class _SignInForm extends StatelessWidget {
  const _SignInForm({
    required this.emailCtrl,
    required this.passwordCtrl,
    required this.emailErr,
    required this.passwordErr,
    required this.passwordVisible,
    required this.teal,
    required this.onEmailChanged,
    required this.onPasswordChanged,
    required this.onTogglePassword,
    required this.onForgotPassword,
    required this.onSignIn,
  });

  final TextEditingController emailCtrl;
  final TextEditingController passwordCtrl;
  final String? emailErr;
  final String? passwordErr;
  final bool passwordVisible;
  final Color teal;
  final ValueChanged<String> onEmailChanged;
  final ValueChanged<String> onPasswordChanged;
  final VoidCallback onTogglePassword;
  final VoidCallback onForgotPassword;
  final VoidCallback? onSignIn;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _AuthField(
          controller: emailCtrl,
          hint: 'Email address',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          errorText: emailErr,
          onChanged: onEmailChanged,
          teal: teal,
        ),
        const SizedBox(height: 12),
        _AuthField(
          controller: passwordCtrl,
          hint: 'Password',
          icon: Icons.lock_outline,
          obscure: !passwordVisible,
          errorText: passwordErr,
          onChanged: onPasswordChanged,
          teal: teal,
          suffixIcon: IconButton(
            icon: Icon(
              passwordVisible ? Icons.visibility_off : Icons.visibility,
              color: Colors.black54,
              size: 20,
            ),
            onPressed: onTogglePassword,
          ),
        ),
        const SizedBox(height: 6),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: onForgotPassword,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 28),
            ),
            child: Text(
              'Forgot password?',
              style: TextStyle(color: teal, fontSize: 12),
            ),
          ),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: onSignIn,
          style: ElevatedButton.styleFrom(
            backgroundColor: teal,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
          ),
          child: const Text(
            'Sign In',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
        ),
      ],
    );
  }
}

// ── Sign-Up Form ──────────────────────────────────────────────────────────────

class _SignUpForm extends StatelessWidget {
  const _SignUpForm({
    required this.nameCtrl,
    required this.emailCtrl,
    required this.passwordCtrl,
    required this.confirmCtrl,
    required this.nameErr,
    required this.emailErr,
    required this.passwordErr,
    required this.confirmErr,
    required this.passwordVisible,
    required this.confirmVisible,
    required this.teal,
    required this.onNameChanged,
    required this.onEmailChanged,
    required this.onPasswordChanged,
    required this.onConfirmChanged,
    required this.onTogglePassword,
    required this.onToggleConfirm,
    required this.onSignUp,
  });

  final TextEditingController nameCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController passwordCtrl;
  final TextEditingController confirmCtrl;
  final String? nameErr;
  final String? emailErr;
  final String? passwordErr;
  final String? confirmErr;
  final bool passwordVisible;
  final bool confirmVisible;
  final Color teal;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<String> onEmailChanged;
  final ValueChanged<String> onPasswordChanged;
  final ValueChanged<String> onConfirmChanged;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirm;
  final VoidCallback? onSignUp;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _AuthField(
          controller: nameCtrl,
          hint: 'Full name',
          icon: Icons.person_outline,
          keyboardType: TextInputType.name,
          errorText: nameErr,
          onChanged: onNameChanged,
          teal: teal,
        ),
        const SizedBox(height: 10),
        _AuthField(
          controller: emailCtrl,
          hint: 'Email address',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          errorText: emailErr,
          onChanged: onEmailChanged,
          teal: teal,
        ),
        const SizedBox(height: 10),
        _AuthField(
          controller: passwordCtrl,
          hint: 'Password',
          icon: Icons.lock_outline,
          obscure: !passwordVisible,
          errorText: passwordErr,
          onChanged: onPasswordChanged,
          teal: teal,
          suffixIcon: IconButton(
            icon: Icon(
              passwordVisible ? Icons.visibility_off : Icons.visibility,
              color: Colors.black54,
              size: 20,
            ),
            onPressed: onTogglePassword,
          ),
        ),
        const SizedBox(height: 10),
        _AuthField(
          controller: confirmCtrl,
          hint: 'Confirm password',
          icon: Icons.lock_outline,
          obscure: !confirmVisible,
          errorText: confirmErr,
          onChanged: onConfirmChanged,
          teal: teal,
          suffixIcon: IconButton(
            icon: Icon(
              confirmVisible ? Icons.visibility_off : Icons.visibility,
              color: Colors.black54,
              size: 20,
            ),
            onPressed: onToggleConfirm,
          ),
        ),
        const SizedBox(height: 14),
        ElevatedButton(
          onPressed: onSignUp,
          style: ElevatedButton.styleFrom(
            backgroundColor: teal,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
          ),
          child: const Text(
            'Create Account',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
        ),
      ],
    );
  }
}

// ── Shared field widget ───────────────────────────────────────────────────────

class _AuthField extends StatelessWidget {
  const _AuthField({
    required this.controller,
    required this.hint,
    required this.icon,
    required this.onChanged,
    required this.teal,
    this.keyboardType,
    this.obscure = false,
    this.errorText,
    this.suffixIcon,
  });

  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscure;
  final String? errorText;
  final Widget? suffixIcon;
  final ValueChanged<String> onChanged;
  final Color teal;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscure,
          onChanged: onChanged,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.black45, fontSize: 13),
            prefixIcon: Icon(icon, size: 18, color: Colors.black54),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: const Color(0xFFC8CDD0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: errorText != null
                  ? const BorderSide(color: Colors.redAccent, width: 1.5)
                  : BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: errorText != null ? Colors.redAccent : teal,
                width: 1.5,
              ),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 3),
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

// ── Google Button ─────────────────────────────────────────────────────────────

class _GoogleButton extends StatelessWidget {
  const _GoogleButton({required this.isLoading, required this.onPressed});
  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF4285F4),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(2),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
        ),
        child: TextButton.icon(
          onPressed: onPressed,
          icon: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF4285F4),
                  ),
                )
              : const Icon(
                  Icons.g_mobiledata,
                  size: 24,
                  color: Color(0xFF4285F4),
                ),
          label: Text(
            isLoading ? 'Connecting...' : 'Continue with Google',
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
      ),
    );
  }
}
