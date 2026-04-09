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

  // ADD MILEAGE
  Future<void> addMileage(String vehicleId, double mileage) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('vehicles')
        .doc(vehicleId)
        .collection('mileage_logs')
        .add({'mileage': mileage, 'date': FieldValue.serverTimestamp()});
  }

  Stream<double?> getLatestMileage(String vehicleId) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('vehicles')
        .doc(vehicleId)
        .collection('mileage_logs')
        .orderBy('date', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) return null;

          return (snapshot.docs.first['mileage'] as num).toDouble();
        });
  }

  // MILEAGE HISTORY
  Stream<List<Map<String, dynamic>>> getMileageHistory(String vehicleId) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('vehicles')
        .doc(vehicleId)
        .collection('mileage_logs')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return {'id': doc.id, ...doc.data()};
          }).toList();
        });
  }

  // UPDATE MILEAGE HISTORY
  Future<void> updateMileage(
    String vehicleId,
    String logId,
    double mileage,
  ) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('vehicles')
        .doc(vehicleId)
        .collection('mileage_logs')
        .doc(logId)
        .update({'mileage': mileage});
  }

  // DELETE MILEAGE HISTORY
  Future<void> deleteMileage(String vehicleId, String logId) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('vehicles')
        .doc(vehicleId)
        .collection('mileage_logs')
        .doc(logId)
        .delete();
  }
}
