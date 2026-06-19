import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';

class GasHistoryScreen extends StatelessWidget {
  final String vehicleId;

  const GasHistoryScreen({super.key, required this.vehicleId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Gas History")),

      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: FirestoreService().getGasHistory(vehicleId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final logs = snapshot.data!;

          if (logs.isEmpty) {
            return const Center(child: Text("No gas records yet"));
          }

          return ListView.builder(
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];

              final price = log['price'];
              final date = (log['date'] as Timestamp).toDate();

              return ListTile(
                leading: const Icon(
                  Icons.local_gas_station,
                  color: Colors.green,
                ),
                title: Text("${price.toStringAsFixed(0)} đ"),
                subtitle: Text(date.toLocal().toString().split(' ')[0]),
              );
            },
          );
        },
      ),
    );
  }
}
