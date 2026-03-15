import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/course_model.dart';
import '../models/course_progress_model.dart';
import '../services/firestore_service.dart';

// ── Events ────────────────────────────────────────────────────────────────
abstract class DiscoverEvent {}

class LoadCourses extends DiscoverEvent {}

class ToggleCourseBookmark extends DiscoverEvent {
  final String courseId;
  final bool isCurrentlyBookmarked;
  ToggleCourseBookmark(this.courseId, {required this.isCurrentlyBookmarked});
}

class UpdateProgress extends DiscoverEvent {
  final String courseId;
  final double progress;
  UpdateProgress(this.courseId, this.progress);
}

class FilterCourses extends DiscoverEvent {
  final String category;
  FilterCourses(this.category);
}

class SearchCourses extends DiscoverEvent {
  final String query;
  SearchCourses(this.query);
}

// ── States ────────────────────────────────────────────────────────────────
abstract class DiscoverState {}

class DiscoverInitial extends DiscoverState {}

class DiscoverLoading extends DiscoverState {}

class DiscoverLoaded extends DiscoverState {
  final List<Course> allCourses;
  final List<Course> filteredCourses;
  final Map<String, CourseProgress> progressMap;
  final String selectedCategory;
  final String searchQuery;

  DiscoverLoaded({
    required this.allCourses,
    required this.filteredCourses,
    required this.progressMap,
    required this.selectedCategory,
    required this.searchQuery,
  });

  DiscoverLoaded copyWith({
    List<Course>? allCourses,
    List<Course>? filteredCourses,
    Map<String, CourseProgress>? progressMap,
    String? selectedCategory,
    String? searchQuery,
  }) {
    return DiscoverLoaded(
      allCourses: allCourses ?? this.allCourses,
      filteredCourses: filteredCourses ?? this.filteredCourses,
      progressMap: progressMap ?? this.progressMap,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class DiscoverError extends DiscoverState {
  final String message;
  DiscoverError(this.message);
}

// ── BLoC ──────────────────────────────────────────────────────────────────
class DiscoverBloc extends Bloc<DiscoverEvent, DiscoverState> {
  final FirestoreService firestoreService;

  DiscoverBloc(this.firestoreService) : super(DiscoverInitial()) {
    on<LoadCourses>(_onLoadCourses);
    on<ToggleCourseBookmark>(_onToggleBookmark);
    on<UpdateProgress>(_onUpdateProgress);
    on<FilterCourses>(_onFilter);
    on<SearchCourses>(_onSearch);
  }

  Future<void> _onLoadCourses(LoadCourses event, Emitter<DiscoverState> emit) async {
    emit(DiscoverLoading());
    try {
      final courses = await firestoreService.getCourses();
      final progress = await firestoreService.getUserCourseProgress();
      final loaded = DiscoverLoaded(
        allCourses: courses,
        filteredCourses: courses,
        progressMap: progress,
        selectedCategory: 'All',
        searchQuery: '',
      );
      emit(loaded);
    } catch (e) {
      emit(DiscoverError('Failed to load courses: $e'));
    }
  }

  Future<void> _onToggleBookmark(ToggleCourseBookmark event, Emitter<DiscoverState> emit) async {
    final current = state;
    if (current is! DiscoverLoaded) return;

    // Optimistic update
    final updatedMap = Map<String, CourseProgress>.from(current.progressMap);
    final existing = updatedMap[event.courseId];
    if (existing != null) {
      updatedMap[event.courseId] = existing.copyWith(isBookmarked: !event.isCurrentlyBookmarked);
    } else {
      updatedMap[event.courseId] = CourseProgress(
        courseId: event.courseId,
        progress: 0.0,
        isBookmarked: true,
        lastAccessedAt: DateTime.now(),
      );
    }
    emit(current.copyWith(progressMap: updatedMap));

    try {
      await firestoreService.toggleCourseBookmark(event.courseId, event.isCurrentlyBookmarked);
    } catch (e) {
      // Revert
      emit(current);
      emit(DiscoverError('Failed to update bookmark'));
    }
  }

  Future<void> _onUpdateProgress(UpdateProgress event, Emitter<DiscoverState> emit) async {
    final current = state;
    if (current is! DiscoverLoaded) return;

    final updatedMap = Map<String, CourseProgress>.from(current.progressMap);
    final existing = updatedMap[event.courseId];
    final newProgress = CourseProgress(
      courseId: event.courseId,
      progress: event.progress,
      isBookmarked: existing?.isBookmarked ?? false,
      lastAccessedAt: DateTime.now(),
    );
    updatedMap[event.courseId] = newProgress;
    emit(current.copyWith(progressMap: updatedMap));

    try {
      await firestoreService.updateCourseProgress(newProgress);
    } catch (_) {
      emit(current);
    }
  }

  void _onFilter(FilterCourses event, Emitter<DiscoverState> emit) {
    final current = state;
    if (current is! DiscoverLoaded) return;
    final filtered = _applyFilters(
      current.allCourses,
      event.category,
      current.searchQuery,
    );
    emit(current.copyWith(filteredCourses: filtered, selectedCategory: event.category));
  }

  void _onSearch(SearchCourses event, Emitter<DiscoverState> emit) {
    final current = state;
    if (current is! DiscoverLoaded) return;
    final filtered = _applyFilters(
      current.allCourses,
      current.selectedCategory,
      event.query,
    );
    emit(current.copyWith(filteredCourses: filtered, searchQuery: event.query));
  }

  List<Course> _applyFilters(List<Course> courses, String category, String query) {
    return courses.where((c) {
      final matchCat = category == 'All' || c.category == category;
      final matchQuery = query.isEmpty ||
          c.title.toLowerCase().contains(query.toLowerCase()) ||
          c.description.toLowerCase().contains(query.toLowerCase()) ||
          c.category.toLowerCase().contains(query.toLowerCase());
      return matchCat && matchQuery;
    }).toList();
  }
}