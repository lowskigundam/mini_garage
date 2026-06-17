import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String? id;
  final String vehicleId;

  final String type; // "mileage", "service", "gas"
  final DateTime date;

  // Optional fields depending on type
  final double? value; // mileage
  final double? amount; // gas price
  final String? note; // service note

  Event({
    this.id,
    required this.vehicleId,
    required this.type,
    required this.date,
    this.value,
    this.amount,
    this.note,
  });

  // 🔹 Convert Event → Firestore
  Map<String, dynamic> toMap() {
    return {
      'vehicleId': vehicleId,
      'type': type,
      'date': date,
      'value': value,
      'amount': amount,
      'note': note,
    };
  }

  // 🔹 Convert Firestore → Event
  factory Event.fromMap(Map<String, dynamic> map, String docId) {
    return Event(
      id: docId,
      vehicleId: map['vehicleId'],
      type: map['type'],
      date: (map['date'] as Timestamp).toDate(),
      value: (map['value'] as num?)?.toDouble(),
      amount: (map['amount'] as num?)?.toDouble(),
      note: map['note'],
    );
  }
}
