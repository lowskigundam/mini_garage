import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceHistoryScreen extends StatelessWidget {
  final String vehicleId;

  const ServiceHistoryScreen({super.key, required this.vehicleId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Service History")),

      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: FirestoreService().getServiceHistory(vehicleId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final logs = snapshot.data!;

          if (logs.isEmpty) {
            return const Center(child: Text("No service history yet"));
          }

          return ListView.builder(
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];

              final type = log['type'];
              final date = (log['date'] as Timestamp).toDate();

              return Dismissible(
                key: Key(log['id']), // IMPORTANT: unique key

                direction: DismissDirection.endToStart, // swipe right → left
                // 🔴 red delete background
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),

                // 🧠 delete logic
                onDismissed: (_) async {
                  await FirestoreService().deleteServiceLog(
                    vehicleId,
                    log['id'],
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Service log deleted')),
                  );
                },

                // 👇 your ORIGINAL tile goes here
                child: ListTile(
                  leading: Icon(
                    type == "last" ? Icons.build : Icons.schedule,
                    color: type == "last" ? Colors.blue : Colors.orange,
                  ),
                  title: Text(
                    type == "last" ? "Last Service" : "Next Service Scheduled",
                  ),
                  subtitle: Text(date.toLocal().toString().split(' ')[0]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
