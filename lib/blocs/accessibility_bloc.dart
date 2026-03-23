import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/accessibility_model.dart';
import '../data/services/firestore_service.dart';

// ── Events ────────────────────────────────────────────────────────────────
abstract class AccessibilityEvent {}

class LoadAccessibilityPreference extends AccessibilityEvent {}

class SelectAccessibilityMode extends AccessibilityEvent {
  final String mode;
  SelectAccessibilityMode(this.mode);
}

class SaveAccessibilityPreference extends AccessibilityEvent {
  final String mode;
  SaveAccessibilityPreference(this.mode);
}

// ── States ────────────────────────────────────────────────────────────────
abstract class AccessibilityState {}

class AccessibilityInitial extends AccessibilityState {}

class AccessibilityLoading extends AccessibilityState {}

class AccessibilityLoaded extends AccessibilityState {
  final AccessibilityPreference? preference;
  final String? pendingSelection;

  AccessibilityLoaded({this.preference, this.pendingSelection});

  String? get effectiveMode => pendingSelection ?? preference?.selectedMode;

  AccessibilityLoaded copyWith({
    AccessibilityPreference? preference,
    String? pendingSelection,
  }) {
    return AccessibilityLoaded(
      preference: preference ?? this.preference,
      pendingSelection: pendingSelection ?? this.pendingSelection,
    );
  }
}

class AccessibilitySaving extends AccessibilityState {
  final String mode;
  AccessibilitySaving(this.mode);
}

class AccessibilitySaved extends AccessibilityState {
  final String mode;
  AccessibilitySaved(this.mode);
}

class AccessibilityError extends AccessibilityState {
  final String message;
  AccessibilityError(this.message);
}

// ── BLoC ──────────────────────────────────────────────────────────────────
class AccessibilityBloc extends Bloc<AccessibilityEvent, AccessibilityState> {
  final FirestoreService firestoreService;

  AccessibilityBloc(this.firestoreService) : super(AccessibilityInitial()) {
    on<LoadAccessibilityPreference>(_onLoad);
    on<SelectAccessibilityMode>(_onSelect);
    on<SaveAccessibilityPreference>(_onSave);
  }

  Future<void> _onLoad(
      LoadAccessibilityPreference event, Emitter<AccessibilityState> emit) async {
    emit(AccessibilityLoading());
    try {
      final pref = await firestoreService.getAccessibilityPreference();
      emit(AccessibilityLoaded(preference: pref));
    } catch (e) {
      emit(AccessibilityLoaded(preference: null));
    }
  }

  void _onSelect(SelectAccessibilityMode event, Emitter<AccessibilityState> emit) {
    final current = state;
    if (current is AccessibilityLoaded) {
      emit(current.copyWith(pendingSelection: event.mode));
    } else {
      emit(AccessibilityLoaded(pendingSelection: event.mode));
    }
  }

  Future<void> _onSave(
      SaveAccessibilityPreference event, Emitter<AccessibilityState> emit) async {
    final current = state;
    emit(AccessibilitySaving(event.mode));
    try {
      await firestoreService.saveAccessibilityPreference(event.mode);
      emit(AccessibilitySaved(event.mode));
    } catch (e) {
      if (current is AccessibilityLoaded) {
        emit(current);
      } else {
        emit(AccessibilityLoaded());
      }
      emit(AccessibilityError('Failed to save preference. Please try again.'));
    }
  }
}