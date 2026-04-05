import 'package:flutter/material.dart';
import 'add_vehicle_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'widgets/vehicle_item.dart';
import 'main_screen.dart';
import 'package:provider/provider.dart';
import 'vehicle_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox('vehiclesBox');

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    ChangeNotifierProvider(create: (_) => VehicleProvider(), child: MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Mini Garage', home: MainScreen());
  }
}

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

        title: Text(
          'Mini Garage',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),

        centerTitle: true,
      ),

      body: vehicles.isEmpty
          ? Center(
              child: Text(
                'No vehicles yet 🚗',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.only(top: 8, bottom: 80),

              itemCount: vehicles.length,

              itemBuilder: (context, index) {
                final v = vehicles[index];

                return VehicleItem(
                  vehicle: v,
                  onTap: () async {
                    final updatedVehicle = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AddVehicleScreen(vehicle: vehicles[index]),
                      ),
                    );

                    if (updatedVehicle != null) {
                      provider.updateVehicle(index, updatedVehicle);
                    }
                  },
                  onLongPress: () {
                    provider.deleteVehicle(index);
                  },
                );
              },
            ),
    );
  }
}
