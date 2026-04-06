import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/vehicle.dart';

class VehicleProvider extends ChangeNotifier {
  List<Vehicle> vehicles = [];

  final Box box = Hive.box('vehiclesBox');

  VehicleProvider() {
    loadVehicles();
  }

  void loadVehicles() {
    final savedData = box.get('vehicles');

    if (savedData != null) {
      vehicles = (savedData as List)
          .map((item) => Vehicle.fromMap(item))
          .toList();
    }

    notifyListeners();
  }

  void addVehicle(Vehicle v) {
    vehicles.add(v);
    box.put('vehicles', vehicles.map((v) => v.toMap()).toList());
    notifyListeners();
  }

  void updateVehicle(int index, Vehicle v) {
    vehicles[index] = v;
    box.put('vehicles', vehicles.map((v) => v.toMap()).toList());
    notifyListeners();
  }

  void deleteVehicle(int index) {
    vehicles.removeAt(index);
    box.put('vehicles', vehicles.map((v) => v.toMap()).toList());
    notifyListeners();
  }
}
