import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ================= APP PREFERENCES =================
          const _SectionTitle(title: "APP PREFERENCES"),

          const SizedBox(height: 10),

          _SettingsCard(
            children: [
              _SettingsTile(
                icon: Icons.palette_outlined,
                title: "Appearance",
                subtitle: "Light theme",
                trailingText: "Default",
              ),
              _SettingsTile(
                icon: Icons.notifications_outlined,
                title: "Notifications",
                subtitle: "Service reminders",
                trailingText: "On",
              ),
              _SettingsTile(
                icon: Icons.language_outlined,
                title: "Language",
                subtitle: "Application language",
                trailingText: "English",
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ================= VEHICLE SETTINGS =================
          const _SectionTitle(title: "VEHICLE SETTINGS"),

          const SizedBox(height: 10),

          _SettingsCard(
            children: [
              _SettingsTile(
                icon: Icons.speed_outlined,
                title: "Distance unit",
                subtitle: "Mileage measurement",
                trailingText: "Kilometres",
              ),
              _SettingsTile(
                icon: Icons.attach_money,
                title: "Currency",
                subtitle: "Fuel and vehicle prices",
                trailingText: "VND",
              ),
              _SettingsTile(
                icon: Icons.build_outlined,
                title: "Service reminders",
                subtitle: "Reminder before scheduled service",
                trailingText: "3 days",
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ================= DATA =================
          const _SectionTitle(title: "DATA & STORAGE"),

          const SizedBox(height: 10),

          _SettingsCard(
            children: [
              _SettingsTile(
                icon: Icons.cloud_outlined,
                title: "Cloud synchronization",
                subtitle: "Vehicle data stored with Firebase",
                trailingText: "Active",
              ),
              _SettingsTile(
                icon: Icons.storage_outlined,
                title: "App data",
                subtitle: "Mileage, service and gas records",
                trailingText: "Managed",
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ================= ABOUT =================
          const _SectionTitle(title: "ABOUT"),

          const SizedBox(height: 10),

          _SettingsCard(
            children: [
              _SettingsTile(
                icon: Icons.info_outline,
                title: "Mini Garage",
                subtitle: "Vehicle management application",
                trailingText: "v1.0.0",
              ),
              _SettingsTile(
                icon: Icons.school_outlined,
                title: "Graduation project",
                subtitle: "Bachelor thesis demonstration",
                trailingText: "2026",
              ),
              _SettingsTile(
                icon: Icons.privacy_tip_outlined,
                title: "Privacy",
                subtitle: "User data is separated by account",
                trailingText: "Protected",
              ),
            ],
          ),

          const SizedBox(height: 30),

          Center(
            child: Text(
              "Mini Garage • Version 1.0.0",
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        color: Colors.grey[600],
        fontSize: 13,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(children: _addDividers(children)),
    );
  }

  List<Widget> _addDividers(List<Widget> items) {
    final result = <Widget>[];

    for (int i = 0; i < items.length; i++) {
      result.add(items[i]);

      if (i < items.length - 1) {
        result.add(const Divider(height: 1, indent: 64, endIndent: 16));
      }
    }

    return result;
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String trailingText;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailingText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Theme.of(context).colorScheme.primary),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: Container(
          constraints: const BoxConstraints(maxWidth: 95),
          child: Text(
            trailingText,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
