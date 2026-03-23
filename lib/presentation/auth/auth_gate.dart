import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/auth_bloc.dart';
import '../screens/app_outlook_screen.dart';
import '../screens/discover_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/verify_email_screen.dart';

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
          return const DiscoverScreen();
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
