import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class MileageHistoryScreen extends StatelessWidget {
  final String vehicleId;

  const MileageHistoryScreen({super.key, required this.vehicleId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mileage History")),
      body: StreamBuilder(
        stream: FirestoreService().getMileageHistory(vehicleId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final logs = snapshot.data!;

          if (logs.isEmpty) {
            return const Center(child: Text("No history yet"));
          }

          return ListView.builder(
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];

              return ListTile(
                title: Text("${log['mileage']} km"),
                subtitle: Text(
                  log['date'] != null
                      ? log['date'].toDate().toString()
                      : "No date",
                ),

                // ✏️ EDIT (tap)
                onTap: () async {
                  final controller = TextEditingController(
                    text: log['mileage'].toString(),
                  );

                  final result = await showDialog(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: const Text("Edit Mileage"),
                      content: TextField(
                        controller: controller,
                        keyboardType: TextInputType.number,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: const Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(dialogContext, controller.text);
                          },
                          child: const Text("Save"),
                        ),
                      ],
                    ),
                  );

                  if (result != null) {
                    final newMileage = double.tryParse(result);
                    if (newMileage == null) return;

                    print("Updating mileage: $newMileage"); // DEBUG!

                    await FirestoreService().updateMileage(
                      vehicleId,
                      log['id'],
                      newMileage,
                    );
                  }
                },

                // 🗑 DELETE (long press)
                onLongPress: () async {
                  await FirestoreService().deleteMileage(vehicleId, log['id']);
                },
              );
            },
          );
        },
      ),
    );
  }
}
