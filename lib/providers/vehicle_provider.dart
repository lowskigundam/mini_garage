import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class VehicleProvider extends ChangeNotifier {
  List<Map<String, String>> vehicles = [];

  final Box box = Hive.box('vehiclesBox');

  VehicleProvider() {
    loadVehicles();
  }

  void loadVehicles() {
    final data = box.get('vehicles');

    if (data != null) {
      vehicles = List<Map<String, String>>.from(
        (data as List).map((item) => Map<String, String>.from(item)),
      );
    }

    notifyListeners();
  }

  void addVehicle(Map<String, String> vehicle) {
    vehicles.add(vehicle);
    box.put('vehicles', vehicles);
    notifyListeners();
  }

  void updateVehicle(int index, Map<String, String> vehicle) {
    vehicles[index] = vehicle;
    box.put('vehicles', vehicles);
    notifyListeners();
  }

  void deleteVehicle(int index) {
    vehicles.removeAt(index);
    box.put('vehicles', vehicles);
    notifyListeners();
  }
}
