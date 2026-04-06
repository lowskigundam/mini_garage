import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/vehicle.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final String uid = FirebaseAuth.instance.currentUser!.uid;

  // 🔹 Get reference to user's vehicles
  CollectionReference get _vehicleRef =>
      _db.collection('users').doc(uid).collection('vehicles');

  // 🔹 ADD VEHICLE
  Future<void> addVehicle(Vehicle v) async {
    await _vehicleRef.add(v.toMap());
  }

  // 🔹 GET VEHICLES (real-time stream)
  Stream<List<Vehicle>> getVehicles() {
    return _vehicleRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Vehicle.fromMap(
          Map<String, dynamic>.from(doc.data() as Map),
          doc.id,
        );
      }).toList();
    });
  }

  // 🔹 DELETE VEHICLE
  Future<void> deleteVehicle(String docId) async {
    await _vehicleRef.doc(docId).delete();
  }

  // 🔹 UPDATE VEHICLE
  Future<void> updateVehicle(String docId, Vehicle v) async {
    await _vehicleRef.doc(docId).update(v.toMap());
  }
}
