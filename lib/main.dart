import 'package:flutter/material.dart';
import 'add_vehicle_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'widgets/vehicle_item.dart';
import 'main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  await Hive.openBox('vehiclesBox');

  runApp(MyApp());
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
  late Box box;

  // Step B2: Vehicle list (state)
  List<Map<String, String>> vehicles = [
    {'name': 'Toyota Camry', 'type': 'Car', 'price': '\$20000'},
    {'name': 'Honda Civic', 'type': 'Car', 'price': '\$18000'},
  ];

  @override
  void initState() {
    super.initState();

    box = Hive.box('vehiclesBox');

    final savedData = box.get('vehicles');

    if (savedData != null) {
      vehicles = List<Map<String, String>>.from(
        (savedData as List).map((item) => Map<String, String>.from(item)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                      setState(() {
                        vehicles[index] = Map<String, String>.from(
                          updatedVehicle,
                        );
                        box.put('vehicles', vehicles);
                      });
                    }
                  },
                  onLongPress: () {
                    setState(() {
                      vehicles.removeAt(index);
                      box.put('vehicles', vehicles);
                    });
                  },
                );
              },
            ),
    );
  }
}
