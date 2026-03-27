import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/blocs/theme_bloc.dart';
import '/presentation/widgets/accessible_widgets.dart';
import '/blocs/language_cubit.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  bool _notifications = false;
  bool? _localDarkMode;
  String _translatedTitle = 'Preferences';
  String _translatedDarkMode = 'Dark Mode';
  String _translatedDarkModeSubtitle = 'Enable dark theme';
  String _translatedNotifications = 'Notifications';
  String _translatedNotificationsSubtitle = 'Enable push notifications';
  String _translatedLanguage = 'Language';
  
  // Cache translations
  static final Map<String, Map<String, String>> _translationCache = {};

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await context.read<LanguageCubit>().loadLanguage(user.uid);
      await _translateTexts();
    }
    
    final prefs = await SharedPreferences.getInstance();
    final savedNotifications = prefs.getBool('notifications') ?? false;
    if (mounted) {
      setState(() => _notifications = savedNotifications);
    }
  }

  Future<void> _translateTexts() async {
    final cubit = context.read<LanguageCubit>();
    final currentLang = cubit.state;
    
    if (currentLang == 'en') {
      if (mounted) {
        setState(() {
          _translatedTitle = 'Preferences';
          _translatedDarkMode = 'Dark Mode';
          _translatedDarkModeSubtitle = 'Enable dark theme';
          _translatedNotifications = 'Notifications';
          _translatedNotificationsSubtitle = 'Enable push notifications';
          _translatedLanguage = 'Language';
        });
      }
      return;
    }
    
    // Check cache first
    if (_translationCache.containsKey(currentLang)) {
      final cached = _translationCache[currentLang]!;
      if (mounted) {
        setState(() {
          _translatedTitle = cached['title']!;
          _translatedDarkMode = cached['darkMode']!;
          _translatedDarkModeSubtitle = cached['darkModeSubtitle']!;
          _translatedNotifications = cached['notifications']!;
          _translatedNotificationsSubtitle = cached['notificationsSubtitle']!;
          _translatedLanguage = cached['language']!;
        });
      }
      return;
    }
    
    // Translate and cache
    final textsToTranslate = [
      'Preferences',
      'Dark Mode',
      'Enable dark theme',
      'Notifications',
      'Enable push notifications',
      'Language',
    ];
    
    final translated = await Future.wait(
      textsToTranslate.map((text) => cubit.translateText(text)),
    );
    
    // Store in cache
    _translationCache[currentLang] = {
      'title': translated[0],
      'darkMode': translated[1],
      'darkModeSubtitle': translated[2],
      'notifications': translated[3],
      'notificationsSubtitle': translated[4],
      'language': translated[5],
    };
    
    if (mounted) {
      setState(() {
        _translatedTitle = translated[0];
        _translatedDarkMode = translated[1];
        _translatedDarkModeSubtitle = translated[2];
        _translatedNotifications = translated[3];
        _translatedNotificationsSubtitle = translated[4];
        _translatedLanguage = translated[5];
      });
    }
  }

  Future<void> _saveNotifications(bool value) async {
    setState(() => _notifications = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications', value);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.select((ThemeBloc bloc) => bloc.state.isDarkMode);
    final textColor = isDarkMode ? Colors.white : null;

    return Scaffold(
      appBar: AppBar(
        title: AccessibleText(_translatedTitle, style: TextStyle(color: textColor)),
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
                title: AccessibleText(_translatedDarkMode, style: TextStyle(color: textColor)),
                subtitle: AccessibleText(_translatedDarkModeSubtitle, style: TextStyle(color: textColor?.withValues(alpha: 0.7))),
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
                title: AccessibleText(_translatedNotifications, style: TextStyle(color: textColor)),
                subtitle: AccessibleText(_translatedNotificationsSubtitle, style: TextStyle(color: textColor?.withValues(alpha: 0.7))),
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
                    title: AccessibleText(_translatedLanguage, style: TextStyle(color: textColor)),
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
                            await _translateTexts();
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