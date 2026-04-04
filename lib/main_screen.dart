import 'package:flutter/material.dart';
import 'main.dart'; // HomeScreen
import 'profile_screen.dart';
import 'add_vehicle_screen.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;

  final screens = [HomeScreen(), ProfileScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[currentIndex],

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddVehicleScreen()),
          );
          setState(() {}); // refresh after adding
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
