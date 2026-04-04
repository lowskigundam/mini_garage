import 'package:flutter/material.dart';
import 'main.dart'; // HomeScreen
import 'profile_screen.dart';
import 'add_vehicle_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: currentIndex == 0 ? HomeScreen(key: UniqueKey()) : ProfileScreen(),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddVehicleScreen()),
          );

          if (result != null) {
            final box = Hive.box('vehiclesBox');

            // get current list
            final List current = box.get('vehicles', defaultValue: []);

            // add new vehicle
            current.add(result);

            // save back to Hive
            box.put('vehicles', current);
          }

          setState(() {}); // rebuild UI
        },
        child: Icon(Icons.add),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 8,

        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.home),
              onPressed: () {
                setState(() => currentIndex = 0);
              },
            ),

            SizedBox(width: 40), // space for FAB

            IconButton(
              icon: Icon(Icons.person),
              onPressed: () {
                setState(() => currentIndex = 1);
              },
            ),
          ],
        ),
      ),
    );
  }
}
