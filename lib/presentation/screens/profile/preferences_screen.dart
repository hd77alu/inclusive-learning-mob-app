import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/blocs/theme_bloc.dart';
import '/presentation/widgets/accessible_widgets.dart';
import '../../../blocs/language_cubit.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  bool _notifications = false;
  bool? _localDarkMode;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    // You can keep SharedPreferences for notifications if you want
    // Language will now be managed by LanguageCubit
  }

  Future<void> _saveNotifications(bool value) async {
    // Your existing notification save logic
    // ...
    setState(() => _notifications = value);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.select((ThemeBloc bloc) => bloc.state.isDarkMode);
    final textColor = isDarkMode ? Colors.white : null;

    // Get current language from LanguageCubit
    final currentLangCode = context.watch<LanguageCubit>().state;

    return Scaffold(
      appBar: AppBar(
        title: AccessibleText('Preferences', style: TextStyle(color: textColor)),
        backgroundColor: isDarkMode ? const Color(0xFF112324) : null,
        iconTheme: isDarkMode ? const IconThemeData(color: Colors.white) : null,
      ),
      body: Container(
        color: isDarkMode ? const Color(0xFF112324) : null,
        child: ListView(
          children: [
            // Dark Mode
            Semantics(
              toggled: _localDarkMode ?? isDarkMode,
              label: 'Dark Mode, ${(_localDarkMode ?? isDarkMode) ? "enabled" : "disabled"}',
              hint: 'Double tap to toggle dark theme',
              child: SwitchListTile(
                title: AccessibleText('Dark Mode', style: TextStyle(color: textColor)),
                subtitle: AccessibleText('Enable dark theme', style: TextStyle(color: textColor?.withValues(alpha: 0.7))),
                value: _localDarkMode ?? isDarkMode,
                onChanged: (value) {
                  setState(() => _localDarkMode = value);
                  context.read<ThemeBloc>().add(ToggleTheme(value));
                },
                secondary: Icon(Icons.dark_mode, color: textColor),
              ),
            ),

            // Notifications
            Semantics(
              toggled: _notifications,
              label: 'Notifications, ${_notifications ? "enabled" : "disabled"}',
              hint: 'Double tap to toggle push notifications',
              child: SwitchListTile(
                title: AccessibleText('Notifications', style: TextStyle(color: textColor)),
                subtitle: AccessibleText('Enable push notifications', style: TextStyle(color: textColor?.withValues(alpha: 0.7))),
                value: _notifications,
                onChanged: _saveNotifications,
                secondary: Icon(Icons.notifications, color: textColor),
              ),
            ),

            // ==================== LANGUAGE SELECTOR ====================
            Semantics(
              label: 'Language selector',
              hint: 'Tap to change app language',
              child: BlocBuilder<LanguageCubit, String>(
                builder: (context, currentLang) {
                  final langName = _getLanguageName(currentLang);

                  return ListTile(
                    leading: Icon(Icons.language, color: textColor),
                    title: AccessibleText('Language', style: TextStyle(color: textColor)),
                    subtitle: AccessibleText(langName, style: TextStyle(color: textColor)),
                    trailing: DropdownButton<String>(
                      value: currentLang,
                      dropdownColor: isDarkMode ? const Color(0xFF112324) : null,
                      style: TextStyle(color: textColor),
                      items: const [
                        DropdownMenuItem(value: 'en', child: Text('English')),
                        DropdownMenuItem(value: 'rw', child: Text('Kinyarwanda')),
                        DropdownMenuItem(value: 'fr', child: Text('Français')),
                      ],
                      onChanged: (newLangCode) async {
                        if (newLangCode != null && newLangCode != currentLang) {
                          final user = FirebaseAuth.instance.currentUser;
                          if (user != null) {
                            await context.read<LanguageCubit>().changeLanguage(
                                  newLangCode,
                                  user.uid,
                                );
                          }
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'en':
        return 'English';
      case 'rw':
        return 'Kinyarwanda';
      case 'fr':
        return 'Français';
      default:
        return 'English';
    }
  }
}