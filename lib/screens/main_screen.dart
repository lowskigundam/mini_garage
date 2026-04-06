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
      body: currentIndex == 0 ? HomeScreen(key: UniqueKey()) : ProfileScreen(),

      floatingActionButton: FloatingActionButton(
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
