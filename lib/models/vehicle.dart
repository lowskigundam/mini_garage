class Vehicle {
  final String? id; // 🔥 Firestore docId
  final String name;
  final String type;
  final double price;

  Vehicle({
    this.id,
    required this.name,
    required this.type,
    required this.price,
  });

  // 🔹 Convert Vehicle → Firestore
  Map<String, dynamic> toMap() {
    return {'name': name, 'type': type, 'price': price};
  }

  // 🔹 Convert Firestore → Vehicle
  factory Vehicle.fromMap(Map<String, dynamic> map, String docId) {
    return Vehicle(
      id: docId,
      name: map['name'] ?? '',
      type: map['type'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
    );
  }
}
