import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/vehicle_provider.dart';
import '../widgets/vehicle_item.dart';
import 'add_vehicle_screen.dart';

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
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blue,
        title: const Text(
          'Mini Garage',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: vehicles.isEmpty
          ? const Center(
              child: Text(
                'No vehicles yet 🚗',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 80),
              itemCount: vehicles.length,
              itemBuilder: (context, index) {
                final v = vehicles[index];

                return VehicleItem(
                  vehicle: v,
                  onTap: () async {
                    final updatedVehicle = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddVehicleScreen(vehicle: v),
                      ),
                    );

                    if (updatedVehicle != null) {
                      provider.updateVehicle(updatedVehicle);
                    }
                  },
                  onLongPress: () {
                    provider.deleteVehicle(v);
                  },
                );
              },
            ),
    );
  }
}
