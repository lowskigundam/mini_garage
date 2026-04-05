class Vehicle {
  final String name;
  final double price;

  Vehicle({required this.name, required this.price});

  Map<String, dynamic> toMap() {
    return {'name': name, 'price': price};
  }

  factory Vehicle.fromMap(Map map) {
    return Vehicle(name: map['name'], price: map['price']);
  }
}
