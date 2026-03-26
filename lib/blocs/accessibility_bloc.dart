import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/models/accessibility_model.dart';
import '../data/services/accessibility_service.dart';
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
abstract class AccessibilityState {
  final AccessibilityService service;
  AccessibilityState(this.service);
}

class AccessibilityInitial extends AccessibilityState {
  AccessibilityInitial() : super(AccessibilityService.defaultMode);
}

class AccessibilityLoading extends AccessibilityState {
  AccessibilityLoading(super.service);
}

class AccessibilityLoaded extends AccessibilityState {
  final AccessibilityPreference? preference;
  final String? pendingSelection;

  AccessibilityLoaded({
    required AccessibilityService service,
    this.preference,
    this.pendingSelection,
  }) : super(service);

  String? get effectiveMode => pendingSelection ?? preference?.selectedMode;

  AccessibilityLoaded copyWith({
    AccessibilityService? service,
    AccessibilityPreference? preference,
    String? pendingSelection,
  }) {
    return AccessibilityLoaded(
      service: service ?? this.service,
      preference: preference ?? this.preference,
      pendingSelection: pendingSelection ?? this.pendingSelection,
    );
  }
}

class AccessibilitySaving extends AccessibilityState {
  final String mode;
  AccessibilitySaving(super.service, this.mode);
}

class AccessibilitySaved extends AccessibilityState {
  final String mode;
  final bool showSuccessMessage;
  AccessibilitySaved(super.service, this.mode, {this.showSuccessMessage = false});
}

class AccessibilityError extends AccessibilityState {
  final String message;
  AccessibilityError(super.service, this.message);
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
    emit(AccessibilityLoading(state.service));
    try {
      final pref = await firestoreService.getAccessibilityPreference();
      final service = pref != null
          ? AccessibilityService(pref.selectedMode)
          : AccessibilityService.defaultMode;
      emit(AccessibilityLoaded(service: service, preference: pref));
    } catch (e) {
      emit(AccessibilityLoaded(
        service: AccessibilityService.defaultMode,
        preference: null,
      ));
    }
  }

  void _onSelect(SelectAccessibilityMode event, Emitter<AccessibilityState> emit) {
    final current = state;
    if (current is AccessibilityLoaded) {
      emit(current.copyWith(pendingSelection: event.mode));
    } else {
      emit(AccessibilityLoaded(
        service: state.service,
        pendingSelection: event.mode,
      ));
    }
  }

  Future<void> _onSave(
      SaveAccessibilityPreference event, Emitter<AccessibilityState> emit) async {
    final current = state;
    emit(AccessibilitySaving(state.service, event.mode));
    try {
      await firestoreService.saveAccessibilityPreference(event.mode);
      final newService = AccessibilityService(event.mode);
      emit(AccessibilitySaved(newService, event.mode, showSuccessMessage: true));
    } catch (e) {
      if (current is AccessibilityLoaded) {
        emit(current);
      } else {
        emit(AccessibilityLoaded(service: state.service));
      }
      emit(AccessibilityError(state.service, 'Failed to save preference. Please try again.'));
    }
  }
}