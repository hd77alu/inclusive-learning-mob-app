import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

// ── Events ────────────────────────────────────────────────────────────────────

abstract class AuthEvent {}

/// Check the persisted auth state on app start / resume.
class AuthCheckRequested extends AuthEvent {}

/// Create a new account with email, password, and display name.
class AuthSignUpWithEmail extends AuthEvent {
  final String name;
  final String email;
  final String password;
  AuthSignUpWithEmail({
    required this.name,
    required this.email,
    required this.password,
  });
}

/// Sign in an existing user with email and password.
class AuthSignInWithEmail extends AuthEvent {
  final String email;
  final String password;
  AuthSignInWithEmail({required this.email, required this.password});
}

/// Trigger Google OAuth sign-in.
class AuthSignInWithGoogle extends AuthEvent {}

/// Sign out and clear all session state.
class AuthSignOut extends AuthEvent {}

/// Send a password-reset email.
class AuthSendPasswordReset extends AuthEvent {
  final String email;
  AuthSendPasswordReset({required this.email});
}

/// (Re)send an email-verification link to the current user.
class AuthSendEmailVerification extends AuthEvent {}

/// Reload Firebase user and re-evaluate verification status.
class AuthReloadUser extends AuthEvent {}

// ── States ────────────────────────────────────────────────────────────────────

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

/// A verified user is signed in and ready.
class AuthAuthenticated extends AuthState {
  final User user;
  AuthAuthenticated(this.user);
}

/// User signed up / in with email but hasn't verified it yet.
class AuthEmailVerificationRequired extends AuthState {
  final User user;
  AuthEmailVerificationRequired(this.user);
}

class AuthUnauthenticated extends AuthState {}

/// An auth operation produced a user-facing error.
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

/// Password-reset email dispatched successfully.
class AuthPasswordResetSent extends AuthState {}

/// Verification email (re)sent — show the verify-email screen.
class AuthEmailVerificationSent extends AuthState {
  final User user;
  AuthEmailVerificationSent(this.user);
}

// ── BLoC ──────────────────────────────────────────────────────────────────────

/// All authentication business logic lives here.
/// UI layers only dispatch [AuthEvent]s and react to [AuthState]s.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _auth;
  final GoogleSignIn? _googleSignIn;

  AuthBloc({FirebaseAuth? auth, GoogleSignIn? googleSignIn})
      : _auth = auth ?? FirebaseAuth.instance,
      _googleSignIn = kIsWeb
        ? null
        : (googleSignIn ?? GoogleSignIn(scopes: ['email', 'profile'])),
        super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthSignUpWithEmail>(_onSignUpWithEmail);
    on<AuthSignInWithEmail>(_onSignInWithEmail);
    on<AuthSignInWithGoogle>(_onSignInWithGoogle);
    on<AuthSignOut>(_onSignOut);
    on<AuthSendPasswordReset>(_onSendPasswordReset);
    on<AuthSendEmailVerification>(_onSendEmailVerification);
    on<AuthReloadUser>(_onReloadUser);
  }

  // ── Handlers ────────────────────────────────────────────────────────────────

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    final user = _auth.currentUser;
    if (user == null) {
      emit(AuthUnauthenticated());
      return;
    }
    final isGoogle =
        user.providerData.any((p) => p.providerId == 'google.com');
    if (user.emailVerified || isGoogle) {
      emit(AuthAuthenticated(user));
    } else {
      emit(AuthEmailVerificationRequired(user));
    }
  }

  Future<void> _onSignUpWithEmail(
    AuthSignUpWithEmail event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: event.email.trim(),
        password: event.password,
      );
      final user = credential.user!;
      await user.updateDisplayName(event.name.trim());
      await user.sendEmailVerification();
      emit(AuthEmailVerificationSent(user));
    } on FirebaseAuthException catch (e) {
      emit(AuthError(_mapFirebaseError(e.code)));
    } catch (_) {
      emit(AuthError('An unexpected error occurred. Please try again.'));
    }
  }

  Future<void> _onSignInWithEmail(
    AuthSignInWithEmail event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: event.email.trim(),
        password: event.password,
      );
      final user = credential.user!;
      if (user.emailVerified) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthEmailVerificationRequired(user));
      }
    } on FirebaseAuthException catch (e) {
      emit(AuthError(_mapFirebaseError(e.code)));
    } catch (_) {
      emit(AuthError('An unexpected error occurred. Please try again.'));
    }
  }

  Future<void> _onSignInWithGoogle(
    AuthSignInWithGoogle event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      UserCredential result;
      if (kIsWeb) {
        // Web: use Firebase's built-in popup flow.
        final provider = GoogleAuthProvider();
        result = await _auth.signInWithPopup(provider);
      } else {
        // Mobile: use the google_sign_in package.
        final googleSignIn = _googleSignIn;
        if (googleSignIn == null) {
          emit(AuthError('Google Sign-In is not configured on this platform.'));
          return;
        }
        final account = await googleSignIn.signIn();
        if (account == null) {
          emit(AuthUnauthenticated());
          return;
        }
        final googleAuth = await account.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        result = await _auth.signInWithCredential(credential);
      }
      emit(AuthAuthenticated(result.user!));
    } on FirebaseAuthException catch (e) {
      emit(AuthError(_mapFirebaseError(e.code)));
    } catch (_) {
      emit(AuthError('Google sign-in failed. Please try again.'));
    }
  }

  Future<void> _onSignOut(
    AuthSignOut event,
    Emitter<AuthState> emit,
  ) async {
    try {
      if (!kIsWeb && _googleSignIn != null) {
        await _googleSignIn.signOut();
      }
    } catch (_) {
      // Google sign-out is best-effort.
    }
    await _auth.signOut();
    emit(AuthUnauthenticated());
  }

  Future<void> _onSendPasswordReset(
    AuthSendPasswordReset event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _auth.sendPasswordResetEmail(email: event.email.trim());
      emit(AuthPasswordResetSent());
    } on FirebaseAuthException catch (e) {
      emit(AuthError(_mapFirebaseError(e.code)));
    } catch (_) {
      emit(AuthError('Failed to send reset email. Please try again.'));
    }
  }

  Future<void> _onSendEmailVerification(
    AuthSendEmailVerification event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _auth.currentUser?.sendEmailVerification();
      final user = _auth.currentUser;
      if (user != null) emit(AuthEmailVerificationSent(user));
    } catch (_) {
      emit(AuthError('Failed to send verification email. Try again later.'));
    }
  }

  Future<void> _onReloadUser(
    AuthReloadUser event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _auth.currentUser?.reload();
      final user = _auth.currentUser;
      if (user == null) {
        emit(AuthUnauthenticated());
      } else if (user.emailVerified) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthEmailVerificationRequired(user));
      }
    } catch (_) {
      emit(AuthError('Could not check verification status. Try again.'));
    }
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  String _mapFirebaseError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'email-already-in-use':
        return 'An account already exists with this email. Try signing in.';
      case 'weak-password':
        return 'Password too weak — use at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled. Contact support.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait and try again.';
      case 'network-request-failed':
        return 'No internet connection. Check your network.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}
