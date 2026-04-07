import 'package:flutter/material.dart';
import '../models/vehicle.dart';
import '../services/firestore_service.dart';

class VehicleProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<Vehicle> vehicles = [];

  VehicleProvider() {
    listenToVehicles();
  }

  void listenToVehicles() {
    _firestoreService.getVehicles().listen((data) {
      vehicles = data;
      notifyListeners();
    });
  }

  Future<void> addVehicle(Vehicle v) async {
    await _firestoreService.addVehicle(v);
  }

  Future<void> updateVehicle(Vehicle v) async {
    await _firestoreService.updateVehicle(v.id!, v);
  }

  Future<void> deleteVehicle(Vehicle v) async {
    await _firestoreService.deleteVehicle(v.id!);
  }
}
