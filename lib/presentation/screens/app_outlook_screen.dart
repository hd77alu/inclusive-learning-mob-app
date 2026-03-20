import 'package:flutter/material.dart';

class OutlookScreen extends StatelessWidget {
  const OutlookScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () => Navigator.pushNamed(context, '/signup'),
          child: const Text('Get Started'),
        ),
      ),
    );
  }
}
