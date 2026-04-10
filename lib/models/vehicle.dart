import 'package:cloud_firestore/cloud_firestore.dart';

class Vehicle {
  final String? id; // 🔥 Firestore docId
  final String name;
  final String type;
  final double price;

  DateTime? lastService;
  DateTime? nextService;

  Vehicle({
    this.id,
    required this.name,
    required this.type,
    required this.price,
    this.lastService,
    this.nextService,
  });

  // 🔹 Convert Vehicle → Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type,
      'price': price,
      'lastService': lastService,
      'nextService': nextService,
    };
  }

  // 🔹 Convert Firestore → Vehicle
  factory Vehicle.fromMap(Map<String, dynamic> map, String docId) {
    return Vehicle(
      id: docId,
      name: map['name'] ?? '',
      type: map['type'] ?? '',
      price: (map['price'] ?? 0).toDouble(),

      lastService: map['lastService'] != null
          ? (map['lastService'] as Timestamp).toDate()
          : null,

      nextService: map['nextService'] != null
          ? (map['nextService'] as Timestamp).toDate()
          : null,
    );
  }
}
