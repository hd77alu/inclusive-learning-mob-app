import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'preferences_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          // Logout button
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/signup');
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              child: Icon(Icons.person, size: 50),
            ),
            const SizedBox(height: 20),
            Text(
              user?.displayName ?? 'User',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text('Inclusive Learning Member'),
            const SizedBox(height: 30),
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Email'),
              subtitle: Text(user?.email ?? 'No email'),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Preferences'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PreferencesScreen(),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.star),
              title: const Text('My Skills'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.pushNamed(context, '/skills'),
            ),
            const Spacer(),
            // Logout button at bottom
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted) {
                    Navigator.pushReplacementNamed(context, '/signup');
                  }
                },
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.red),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}