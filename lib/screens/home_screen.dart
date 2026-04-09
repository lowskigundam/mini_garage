import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/vehicle_provider.dart';
import 'add_vehicle_screen.dart';
import '../widgets/vehicle_card.dart';
import 'vehicle_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<VehicleProvider>(context);
    final vehicles = provider.vehicles;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // HEADER
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "My Vehicles",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      "${vehicles.length} vehicles registered",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),

                Stack(
                  children: [
                    const Icon(Icons.notifications, size: 28),

                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Text(
                          "1",
                          style: TextStyle(color: Colors.white, fontSize: 10),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // LIST
          Expanded(
            child: vehicles.isEmpty
                ? const Center(
                    child: Text(
                      'No vehicles yet 🚗',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 100),
                    itemCount: vehicles.length,
                    itemBuilder: (context, index) {
                      final v = vehicles[index];

                      return VehicleCard(
                        vehicle: v,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  VehicleDetailScreen(vehicle: v),
                            ),
                          );
                        },
                        onLongPress: () {
                          provider.deleteVehicle(v);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
