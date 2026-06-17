import 'package:flutter/material.dart';
import '../models/vehicle.dart';
import 'add_vehicle_screen.dart';
import 'package:provider/provider.dart';
import '../providers/vehicle_provider.dart';
import '../services/firestore_service.dart';
import 'mileage_history_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        // ✅ important for long UI
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Price: ${vehicle.price}", style: TextStyle(fontSize: 16)),

              SizedBox(height: 20),

              // ===================== SERVICE =====================
              const Text(
                "SERVICE",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              SizedBox(height: 10),

              FutureBuilder<Map<String, dynamic>?>(
                future: FirestoreService().getLatestService(
                  vehicle.id!,
                  "last",
                ),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Text("No last service");
                  }

                  final data = snapshot.data!;
                  final date = (data['date'] as Timestamp).toDate();

                  return Text(
                    "Last service: ${date.toLocal().toString().split(' ')[0]}",
                  );
                },
              ),

              SizedBox(height: 8),

              FutureBuilder<Map<String, dynamic>?>(
                future: FirestoreService().getLatestService(
                  vehicle.id!,
                  "next",
                ),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Text("No next service scheduled");
                  }

                  final data = snapshot.data!;
                  final date = (data['date'] as Timestamp).toDate();

                  return Text(
                    "Next service: ${date.toLocal().toString().split(' ')[0]}",
                  );
                },
              ),

              SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );

                    if (picked != null) {
                      await FirestoreService().addServiceLog(
                        vehicle.id!,
                        "last",
                        picked,
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Last service updated")),
                      );
                    }
                  },
                  child: Text("Update Last Service"),
                ),
              ),

              SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );

                    if (picked != null) {
                      await FirestoreService().addServiceLog(
                        vehicle.id!,
                        "next",
                        picked,
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Next service updated")),
                      );
                    }
                  },
                  child: Text("Update Next Service"),
                ),
              ),

              // ===================== MILEAGE =====================
              SizedBox(height: 30),

              const Text(
                "MILEAGE",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final controller = TextEditingController();

                    final result = await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text("Enter Mileage"),
                        content: TextField(
                          controller: controller,
                          keyboardType: TextInputType.number,
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(context, controller.text),
                            child: Text("Save"),
                          ),
                        ],
                      ),
                    );

                    if (result != null) {
                      final mileage = double.tryParse(result);
                      if (mileage == null) return;

                      final service = FirestoreService();

                      final currentMileage = await service
                          .getLatestMileage(vehicle.id!)
                          .first;

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

                      await service.addMileage(vehicle.id!, mileage);

                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text("Mileage added")));
                    }
                  },
                  child: Text("Add Mileage"),
                ),
              ),

              SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
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
              ),

              SizedBox(height: 15),

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
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  );
                },
              ),

              // ===================== MAINTENANCE =====================
              SizedBox(height: 30),

              const Text(
                "MAINTENANCE",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

              // ===================== GAS =====================
              SizedBox(height: 30),

              const Text(
                "GAS",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
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

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Gas record added")),
                      );
                    }
                  },
                  child: Text("Add Gas Record"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
