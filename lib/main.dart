import 'package:flutter/material.dart';
import 'add_vehicle_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';

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
    return MaterialApp(title: 'Mini Garage', home: HomeScreen());
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

      body: ListView.builder(
        itemCount: vehicles.length,

        itemBuilder: (context, index) {
          final v = vehicles[index];

          return Card(
            margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),

            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.shade100,
                  child: Icon(Icons.directions_car, color: Colors.blue),
                ),

                title: Text(
                  v['name']!,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                subtitle: Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text(
                    '${v['type']} • ${v['price']}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                ),

                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey,
                ),

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
              ),
            ),
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        elevation: 4,
        onPressed: () async {
          // Step B3: Open Add Screen
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddVehicleScreen()),
          );

          // Step B4: Add new vehicle
          if (result != null) {
            setState(() {
              vehicles.add(Map<String, String>.from(result));
              box.put('vehicles', vehicles);
            });
          }
        },

        child: Icon(Icons.add, size: 28),
      ),
    );
  }
}
