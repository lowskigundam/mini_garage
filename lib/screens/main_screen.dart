import 'package:flutter/material.dart';
import 'profile_screen.dart';
import 'add_vehicle_screen.dart';
import 'package:provider/provider.dart';
import '../providers/vehicle_provider.dart';
import 'home_screen.dart';

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
      body: IndexedStack(
        index: currentIndex,
        children: [
          HomeScreen(),
          Center(child: Text("Stats coming soon")),
          Container(), // placeholder for FAB
          ProfileScreen(),
        ],
      ),

      bottomNavigationBar: Container(
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // HOME
            IconButton(
              icon: Icon(
                Icons.home,
                color: currentIndex == 0 ? Colors.black : Colors.grey,
              ),
              onPressed: () {
                setState(() => currentIndex = 0);
              },
            ),

            // STATS
            IconButton(
              icon: Icon(
                Icons.bar_chart,
                color: currentIndex == 1 ? Colors.black : Colors.grey,
              ),
              onPressed: () {
                setState(() => currentIndex = 1);
              },
            ),

            // ADD VEHICLE (NOW NORMAL TAB)
            IconButton(
              icon: Icon(Icons.directions_car, color: Colors.black),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddVehicleScreen()),
                );

                if (result != null) {
                  final provider = Provider.of<VehicleProvider>(
                    context,
                    listen: false,
                  );
                  provider.addVehicle(result);
                }
              },
            ),

            // PROFILE
            IconButton(
              icon: Icon(
                Icons.person,
                color: currentIndex == 3 ? Colors.black : Colors.grey,
              ),
              onPressed: () {
                setState(() => currentIndex = 3);
              },
            ),
          ],
        ),
      ),
    );
  }
}
