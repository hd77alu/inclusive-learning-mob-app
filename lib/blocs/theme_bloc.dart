import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Events
abstract class ThemeEvent {}

class LoadTheme extends ThemeEvent {}

class ToggleTheme extends ThemeEvent {
  final bool isDark;
  ToggleTheme(this.isDark);
}

// States
abstract class ThemeState {
  final bool isDarkMode;
  const ThemeState(this.isDarkMode);
}

class ThemeInitial extends ThemeState {
  const ThemeInitial() : super(false);
}

class ThemeLoaded extends ThemeState {
  const ThemeLoaded(super.isDarkMode);
}

// BLoC
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  SharedPreferences? _prefs;

  ThemeBloc() : super(const ThemeInitial()) {
    on<LoadTheme>(_onLoad);
    on<ToggleTheme>(_onToggle);
    add(LoadTheme());
  }

  Future<void> _onLoad(LoadTheme event, Emitter<ThemeState> emit) async {
    _prefs = await SharedPreferences.getInstance();
    final isDark = _prefs!.getBool('darkMode') ?? false;
    emit(ThemeLoaded(isDark));
  }

  void _onToggle(ToggleTheme event, Emitter<ThemeState> emit) {
    emit(ThemeLoaded(event.isDark));
    _prefs?.setBool('darkMode', event.isDark);
  }
}
