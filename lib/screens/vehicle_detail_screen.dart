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
                  final mileage = double.parse(result);

                  final service = FirestoreService();

                  await service.addMileage(vehicle.id!, mileage);

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
          ],
        ),
      ),
    );
  }
}
