import 'package:flutter/material.dart';
import '../models/vehicle.dart';
import 'add_vehicle_screen.dart';
import 'package:provider/provider.dart';
import '../providers/vehicle_provider.dart';
import '../services/firestore_service.dart';
import 'mileage_history_screen.dart';

class VehicleDetailScreen extends StatelessWidget {
  final Vehicle vehicle;

  const VehicleDetailScreen({super.key, required this.vehicle});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<VehicleProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(vehicle.name),

        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () async {
              final updatedVehicle = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddVehicleScreen(vehicle: vehicle),
                ),
              );

              if (updatedVehicle != null) {
                provider.updateVehicle(updatedVehicle);
                Navigator.pop(context); // go back after edit
              }
            },
          ),
        ],
      ),

      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // BASIC INFO
            Text("Type: ${vehicle.type}", style: TextStyle(fontSize: 16)),

            SizedBox(height: 8),

            Text("Price: ${vehicle.price}", style: TextStyle(fontSize: 16)),

            SizedBox(height: 20),

            // 🔥 ACTION BUTTONS
            ElevatedButton(
              onPressed: () async {
                final controller = TextEditingController();

                final result = await showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text("Enter Mileage"),
                      content: TextField(
                        controller: controller,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(hintText: "e.g. 45230"),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context, controller.text);
                          },
                          child: Text("Save"),
                        ),
                      ],
                    );
                  },
                );

                if (result != null) {
                  final mileage = double.tryParse(result);

                  if (mileage == null) return;

                  final service = FirestoreService();

                  // 🔥 GET CURRENT MILEAGE
                  final currentMileage = await service
                      .getLatestMileage(vehicle.id!)
                      .first;

                  // 🛑 VALIDATION
                  if (currentMileage != null && mileage < currentMileage) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Mileage cannot be lower than current ($currentMileage km)",
                        ),
                      ),
                    );
                    return;
                  }

                  // ✅ SAVE IF VALID
                  await service.addMileage(vehicle.id!, mileage);

                  final remaining = await service.getRemainingOilDistance(
                    vehicle.id!,
                  );

                  if (remaining != null && remaining <= 300) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text("Oil Change Alert"),
                        content: Text(
                          remaining <= 0
                              ? "You need to change oil NOW!"
                              : "Only ${remaining.toStringAsFixed(0)} km left before oil change",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text("OK"),
                          ),
                        ],
                      ),
                    );
                  }

                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text("Mileage added")));
                }
              },
              child: Text("Add Mileage"),
            ),

            SizedBox(height: 10),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        MileageHistoryScreen(vehicleId: vehicle.id!),
                  ),
                );
              },
              child: Text("View History"),
            ),

            SizedBox(height: 20),

            FutureBuilder<double?>(
              future: FirestoreService().calculateAverageDailyDistance(
                vehicle.id!,
              ),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Text("Avg: Not enough data");
                }

                return Text(
                  "Avg daily: ${snapshot.data!.toStringAsFixed(1)} km/day",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),

            SizedBox(height: 10),

            FutureBuilder<double?>(
              future: FirestoreService().getRemainingOilDistance(vehicle.id!),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Text("Oil: Not enough data");
                }

                final remaining = snapshot.data!;

                if (remaining <= 0) {
                  return const Text(
                    "⚠️ Oil change required NOW",
                    style: TextStyle(color: Colors.red),
                  );
                }

                if (remaining <= 300) {
                  return Text(
                    "⚠️ Oil change soon: ${remaining.toStringAsFixed(0)} km left",
                    style: const TextStyle(color: Colors.orange),
                  );
                }

                return Text(
                  "Oil change in ${remaining.toStringAsFixed(0)} km",
                  style: const TextStyle(color: Colors.green),
                );
              },
            ),

            SizedBox(height: 10),

            ElevatedButton(
              onPressed: () async {
                final controller = TextEditingController();

                final result = await showDialog(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: Text("Enter Gas Price"),
                    content: TextField(
                      controller: controller,
                      keyboardType: TextInputType.number,
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () =>
                            Navigator.pop(dialogContext, controller.text),
                        child: Text("Save"),
                      ),
                    ],
                  ),
                );

                if (result != null) {
                  final price = double.tryParse(result);
                  if (price == null) return;

                  await FirestoreService().addGas(vehicle.id!, price);

                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text("Gas record added")));
                }
              },
              child: Text("Add Gas Record"),
            ),
          ],
        ),
      ),
    );
  }
}
