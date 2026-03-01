import 'package:flutter/material.dart';
import 'App_Outlook_Screen.dart';
import 'sign_up_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const OutlookScreen(),
        '/signup': (context) => const SignUpScreen(),
      },
    );
  }
}
