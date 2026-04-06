class Vehicle {
  final String name;
  final String type;
  final double price;

  Vehicle({required this.name, required this.type, required this.price});

  Map<String, dynamic> toMap() {
    return {'name': name, 'type': type, 'price': price};
  }

  factory Vehicle.fromMap(Map map) {
    return Vehicle(name: map['name'], type: map['type'], price: map['price']);
  }
}
