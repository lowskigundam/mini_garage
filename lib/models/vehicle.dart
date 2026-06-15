import 'package:cloud_firestore/cloud_firestore.dart';

class Vehicle {
  final String? id; //Firestore docId
  final String name;
  final String type;
  final double price;
  final int year;
  final String? imagePath;

  DateTime? lastService;
  DateTime? nextService;

  Vehicle({
    this.id,
    required this.name,
    required this.type,
    required this.price,
    required this.year,
    this.imagePath,
    this.lastService,
    this.nextService,
  });

  // 🔹 Convert Vehicle → Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type,
      'price': price,
      'year': year,
      'imagePath': imagePath,
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
      year: (map['year'] as num?)?.toInt() ?? 2022,
      imagePath: map['imagePath'],
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
