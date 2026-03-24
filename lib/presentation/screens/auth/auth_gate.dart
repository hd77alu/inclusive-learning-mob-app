import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/blocs/auth_bloc.dart';
import '/presentation/screens/core/app_outlook_screen.dart';
import '/presentation/screens/core/main_navigation_screen.dart';
import '/presentation/screens/auth/splash_screen.dart';
import '/presentation/screens/auth/verify_email_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
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
    );
  }
}
