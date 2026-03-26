import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/blocs/auth_bloc.dart';
import '/blocs/accessibility_bloc.dart';
import '/presentation/screens/core/app_outlook_screen.dart';
import '/presentation/screens/core/main_navigation_screen.dart';
import '/presentation/screens/auth/splash_screen.dart';
import '/presentation/screens/auth/verify_email_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AccessibilityBloc, AccessibilityState>(
      listener: (context, state) {
        if (state is AccessibilitySaved && state.showSuccessMessage) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: const Text('Accessibility preference saved!'),
                backgroundColor: const Color(0xFF00D4D4),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                duration: const Duration(seconds: 2),
              ));
            }
          });
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthInitial || state is AuthLoading) {
            return const SplashScreen();
          }
          if (state is AuthAuthenticated) {
            return const MainNavigationScreen();
          }
          if (state is AuthEmailVerificationRequired ||
              state is AuthEmailVerificationSent) {
            return const VerifyEmailScreen();
          }
          // AuthUnauthenticated, AuthError — show the landing screen.
          return const OutlookScreen();
        },
      ),
    );
  }
}
