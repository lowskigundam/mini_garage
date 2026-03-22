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
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Mini Garage', home: HomeScreen());
  }
}

class HomeScreen extends StatefulWidget {
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
      appBar: AppBar(title: Text('Mini Garage')),

      body: ListView.builder(
        itemCount: vehicles.length,

        itemBuilder: (context, index) {
          final v = vehicles[index];

          return Card(
            margin: EdgeInsets.all(10),

            child: ListTile(
              title: Text(v['name']!),

              subtitle: Text('${v['type']} - ${v['price']}'),

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
                    vehicles[index] = Map<String, String>.from(updatedVehicle);
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
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
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

        child: Icon(Icons.add),
      ),
    );
  }
}
