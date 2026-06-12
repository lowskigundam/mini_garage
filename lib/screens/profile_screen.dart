import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),

      body: ListView(
        padding: const EdgeInsets.all(16),

        children: [
          // ACCOUNT CARD
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),

            child: ListTile(
              leading: const Icon(Icons.person),

              title: const Text(
                "Account",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              subtitle: Text(user?.email ?? "No email"),
            ),
          ),

          const SizedBox(height: 12),

          // SETTINGS CARD
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),

            child: ListTile(
              leading: const Icon(Icons.settings),

              title: const Text(
                "Settings",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              subtitle: const Text("Coming soon"),

              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Settings coming soon")),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // LOGOUT CARD
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),

            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),

              title: const Text(
                "Logout",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),

              onTap: () async {
                await FirebaseAuth.instance.signOut();
              },
            ),
          ),
        ],
      ),
    );
  }
}
