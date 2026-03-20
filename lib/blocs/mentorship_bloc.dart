import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/mentor_model.dart';
import '../data/services/firestore_service.dart';

// ── Events ────────────────────────────────────────────────────────────────────
abstract class MentorshipEvent {}

class LoadMentors extends MentorshipEvent {}

class FilterMentors extends MentorshipEvent {
  final String filter; // 'All' | 'Sign Language' | 'Braille'
  FilterMentors(this.filter);
}

class ToggleBookmark extends MentorshipEvent {
  final String userId;
  final String mentorId;
  final bool isBookmarked;
  ToggleBookmark(this.userId, this.mentorId, {required this.isBookmarked});
}

// ── States ────────────────────────────────────────────────────────────────────
abstract class MentorshipState {}

class MentorshipLoading extends MentorshipState {}

class MentorshipLoaded extends MentorshipState {
  final List<MentorModel> mentors;
  final List<String> bookmarkedIds;
  final String selectedFilter;

  MentorshipLoaded(this.mentors, this.bookmarkedIds,
      {this.selectedFilter = 'All'});
}

class MentorshipError extends MentorshipState {
  final String message;
  MentorshipError(this.message);
}

// ── BLoC ──────────────────────────────────────────────────────────────────────
class MentorshipBloc extends Bloc<MentorshipEvent, MentorshipState> {
  final FirestoreService _service;
  final String userId;

  StreamSubscription<List<MentorModel>>? _mentorSub;
  StreamSubscription<List<String>>? _bookmarkSub;

  List<MentorModel> _allMentors = [];
  final List<String> _bookmarks = [];
  String _filter = 'All';

  MentorshipBloc(this._service, this.userId) : super(MentorshipLoading()) {
    on<LoadMentors>(_onLoad);
    on<FilterMentors>(_onFilter);
    on<ToggleBookmark>(_onToggleBookmark);
  }

  void _onLoad(LoadMentors event, Emitter<MentorshipState> emit) async {
    emit(MentorshipLoading());
    await emit.forEach<List<MentorModel>>(
      _service.getMentors(),
      onData: (mentors) {
        _allMentors = mentors;
        return MentorshipLoaded(
          _filtered(),
          List.from(_bookmarks),
          selectedFilter: _filter,
        );
      },
      onError: (e, s) => MentorshipError(e.toString()),
    );
  }

  void _onFilter(FilterMentors event, Emitter<MentorshipState> emit) {
    _filter = event.filter;
    emit(MentorshipLoaded(
      _filtered(),
      List.from(_bookmarks),
      selectedFilter: _filter,
    ));
  }

  void _onToggleBookmark(
      ToggleBookmark event, Emitter<MentorshipState> emit) async {
    try {
      if (event.isBookmarked) {
        await _service.removeBookmark(event.userId, event.mentorId);
        _bookmarks.remove(event.mentorId);
      } else {
        await _service.bookmarkMentor(event.userId, event.mentorId);
        _bookmarks.add(event.mentorId);
      }
      emit(MentorshipLoaded(
        _filtered(),
        List.from(_bookmarks),
        selectedFilter: _filter,
      ));
    } catch (e) {
      emit(MentorshipError(e.toString()));
    }
  }

  List<MentorModel> _filtered() {
    if (_filter == 'All') return List.from(_allMentors);
    return _allMentors
        .where((m) =>
            m.tags.any((t) => t.toLowerCase() == _filter.toLowerCase()) ||
            m.specialty.toLowerCase().contains(_filter.toLowerCase()))
        .toList();
  }

  @override
  Future<void> close() {
    _mentorSub?.cancel();
    _bookmarkSub?.cancel();
    return super.close();
  }
}
