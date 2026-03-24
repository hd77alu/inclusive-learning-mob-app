import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/session_model.dart';
import '../data/services/firestore_service.dart';

// ── Events ────────────────────────────────────────────────────────────────
abstract class SessionEvent {}

class LoadUserSessions extends SessionEvent {
  final SessionStatus? statusFilter;
  LoadUserSessions({this.statusFilter});
}

class LoadUpcomingSessions extends SessionEvent {}

class LoadPastSessions extends SessionEvent {}

class BookSession extends SessionEvent {
  final Session session;
  BookSession(this.session);
}

class CancelSession extends SessionEvent {
  final String sessionId;
  final String mentorId;
  CancelSession(this.sessionId, this.mentorId);
}

class UpdateSessionStatus extends SessionEvent {
  final String sessionId;
  final String mentorId;
  final SessionStatus status;
  UpdateSessionStatus(this.sessionId, this.mentorId, this.status);
}

class CheckAvailability extends SessionEvent {
  final String mentorId;
  final DateTime date;
  final String timeSlot;
  CheckAvailability(this.mentorId, this.date, this.timeSlot);
}

// ── States ────────────────────────────────────────────────────────────────
abstract class SessionState {}

class SessionsInitial extends SessionState {}

class SessionsLoading extends SessionState {}

class SessionsLoaded extends SessionState {
  final List<Session> sessions;
  SessionsLoaded(this.sessions);
}

class SessionBooking extends SessionState {}

class SessionBooked extends SessionState {
  final String sessionId;
  final Session session;
  SessionBooked(this.sessionId, this.session);
}

class SessionCancelled extends SessionState {
  final String sessionId;
  SessionCancelled(this.sessionId);
}

class SessionAvailabilityChecked extends SessionState {
  final bool isAvailable;
  final String mentorId;
  final DateTime date;
  final String timeSlot;
  SessionAvailabilityChecked(this.isAvailable, this.mentorId, this.date, this.timeSlot);
}

class SessionError extends SessionState {
  final String message;
  SessionError(this.message);
}

// ── BLoC ──────────────────────────────────────────────────────────────────
class SessionBloc extends Bloc<SessionEvent, SessionState> {
  final FirestoreService firestoreService;

  SessionBloc(this.firestoreService) : super(SessionsInitial()) {
    on<LoadUserSessions>(_onLoadUserSessions);
    on<LoadUpcomingSessions>(_onLoadUpcomingSessions);
    on<LoadPastSessions>(_onLoadPastSessions);
    on<BookSession>(_onBookSession);
    on<CancelSession>(_onCancelSession);
    on<UpdateSessionStatus>(_onUpdateSessionStatus);
    on<CheckAvailability>(_onCheckAvailability);
  }

  Future<void> _onLoadUserSessions(
      LoadUserSessions event, Emitter<SessionState> emit) async {
    emit(SessionsLoading());
    try {
      final sessions = await firestoreService.getUserSessions(status: event.statusFilter);
      emit(SessionsLoaded(sessions));
    } catch (e) {
      emit(SessionError('Failed to load sessions: ${e.toString()}'));
    }
  }

  Future<void> _onLoadUpcomingSessions(
      LoadUpcomingSessions event, Emitter<SessionState> emit) async {
    emit(SessionsLoading());
    try {
      final sessions = await firestoreService.getUpcomingSessions();
      emit(SessionsLoaded(sessions));
    } catch (e) {
      emit(SessionError('Failed to load upcoming sessions: ${e.toString()}'));
    }
  }

  Future<void> _onLoadPastSessions(
      LoadPastSessions event, Emitter<SessionState> emit) async {
    emit(SessionsLoading());
    try {
      final sessions = await firestoreService.getPastSessions();
      emit(SessionsLoaded(sessions));
    } catch (e) {
      emit(SessionError('Failed to load past sessions: ${e.toString()}'));
    }
  }

  Future<void> _onBookSession(
      BookSession event, Emitter<SessionState> emit) async {
    emit(SessionBooking());
    try {
      // Check availability first
      final isAvailable = await firestoreService.checkTimeSlotAvailability(
        event.session.mentorId,
        event.session.date,
        event.session.timeSlot,
      );

      if (!isAvailable) {
        emit(SessionError('This time slot is no longer available. Please choose another time.'));
        return;
      }

      // Book the session
      final sessionId = await firestoreService.createSession(event.session);
      final bookedSession = event.session.copyWith(id: sessionId);
      emit(SessionBooked(sessionId, bookedSession));
    } catch (e) {
      emit(SessionError('Failed to book session: ${e.toString()}'));
    }
  }

  Future<void> _onCancelSession(
      CancelSession event, Emitter<SessionState> emit) async {
    try {
      await firestoreService.cancelSession(event.sessionId, event.mentorId);
      emit(SessionCancelled(event.sessionId));
      // Reload sessions after cancellation
      add(LoadUserSessions());
    } catch (e) {
      emit(SessionError('Failed to cancel session: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateSessionStatus(
      UpdateSessionStatus event, Emitter<SessionState> emit) async {
    try {
      await firestoreService.updateSessionStatus(
        event.sessionId,
        event.mentorId,
        event.status,
      );
      // Reload sessions after status update
      add(LoadUserSessions());
    } catch (e) {
      emit(SessionError('Failed to update session status: ${e.toString()}'));
    }
  }

  Future<void> _onCheckAvailability(
      CheckAvailability event, Emitter<SessionState> emit) async {
    try {
      final isAvailable = await firestoreService.checkTimeSlotAvailability(
        event.mentorId,
        event.date,
        event.timeSlot,
      );
      emit(SessionAvailabilityChecked(isAvailable, event.mentorId, event.date, event.timeSlot));
    } catch (e) {
      emit(SessionError('Failed to check availability: ${e.toString()}'));
    }
  }
}
