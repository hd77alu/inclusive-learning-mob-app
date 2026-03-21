import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/mentor_model.dart';
import '../data/services/firestore_service.dart';

// ── Events ──
abstract class MentorshipEvent {}

class LoadMentors extends MentorshipEvent {}

class ToggleBookmark extends MentorshipEvent {
  final String mentorId;
  final bool isCurrentlyBookmarked;
  ToggleBookmark(this.mentorId, {required this.isCurrentlyBookmarked});
}

// ── States ──
abstract class MentorshipState {}

class MentorshipInitial extends MentorshipState {}

class MentorshipLoading extends MentorshipState {}

class MentorshipLoaded extends MentorshipState {
  final List<Mentor> mentors;
  final Set<String> bookmarkedIds;
  MentorshipLoaded(this.mentors, this.bookmarkedIds);
}

class MentorshipError extends MentorshipState {}

// ── BLoC ──
class MentorshipBloc extends Bloc<MentorshipEvent, MentorshipState> {
  final FirestoreService firestoreService;

  MentorshipBloc(this.firestoreService) : super(MentorshipInitial()) {
    on<LoadMentors>((event, emit) async {
      emit(MentorshipLoading());
      try {
        final mentors = await firestoreService.getMentors();
        final bookmarkedIds = await firestoreService.getBookmarkedMentorIds();
        emit(MentorshipLoaded(mentors, bookmarkedIds));
      } catch (e) {
        emit(MentorshipError());
      }
    });

    on<ToggleBookmark>((event, emit) async {
      final current = state;
      if (current is! MentorshipLoaded) return;

      // Optimistic UI update
      final updated = Set<String>.from(current.bookmarkedIds);
      if (event.isCurrentlyBookmarked) {
        updated.remove(event.mentorId);
      } else {
        updated.add(event.mentorId);
      }
      emit(MentorshipLoaded(current.mentors, updated));

      try {
        if (event.isCurrentlyBookmarked) {
          await firestoreService.removeBookmark(event.mentorId);
        } else {
          await firestoreService.bookmarkMentor(event.mentorId);
        }
      } catch (e) {
        // Revert on failure
        emit(MentorshipLoaded(current.mentors, current.bookmarkedIds));
      }
    });
  }
}