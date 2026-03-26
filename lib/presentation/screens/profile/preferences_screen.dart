import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/blocs/theme_bloc.dart';
import '/presentation/widgets/accessible_widgets.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  bool _notifications = false;
  String _language = 'English';
  bool? _localDarkMode;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notifications = prefs.getBool('notifications') ?? false;
      _language = prefs.getString('language') ?? 'English';
    });
  }

  Future<void> _saveNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    final success = await prefs.setBool('notifications', value);
    if (mounted && success) {
      setState(() => _notifications = value);
    }
  }

  Future<void> _saveLanguage(String value) async {
    final prefs = await SharedPreferences.getInstance();
    final success = await prefs.setString('language', value);
    if (mounted && success) {
      setState(() => _language = value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.select((ThemeBloc bloc) => bloc.state.isDarkMode);
    final textColor = isDarkMode ? Colors.white : null;
    
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
            SwitchListTile(
              title: AccessibleText('Dark Mode', style: TextStyle(color: textColor)),
              subtitle: AccessibleText('Enable dark theme', style: TextStyle(color: textColor?.withValues(alpha: 0.7))),
              value: _localDarkMode ?? isDarkMode,
              onChanged: (value) {
                setState(() => _localDarkMode = value);
                context.read<ThemeBloc>().add(ToggleTheme(value));
              },
              secondary: Icon(Icons.dark_mode, color: textColor),
            ),
            SwitchListTile(
              title: AccessibleText('Notifications', style: TextStyle(color: textColor)),
              subtitle: AccessibleText('Enable push notifications', style: TextStyle(color: textColor?.withValues(alpha: 0.7))),
              value: _notifications,
              onChanged: _saveNotifications,
              secondary: Icon(Icons.notifications, color: textColor),
            ),
            ListTile(
              leading: Icon(Icons.language, color: textColor),
              title: AccessibleText('Language', style: TextStyle(color: textColor)),
              subtitle: AccessibleText(_language, style: TextStyle(color: textColor)),
                  trailing: DropdownButton<String>(
                    value: _language,
                    dropdownColor: isDarkMode ? const Color(0xFF112324) : null,
                style: TextStyle(color: textColor),
                items: const [
                  DropdownMenuItem(value: 'English', child: Text('English')),
                  DropdownMenuItem(value: 'French', child: Text('French')),
                  DropdownMenuItem(value: 'Kinyarwanda', child: Text('Kinyarwanda')),
                ],
                    onChanged: (value) {
                      if (value != null) _saveLanguage(value);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
  }
}
