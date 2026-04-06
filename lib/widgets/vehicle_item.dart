import 'package:flutter/material.dart';
import '../models/vehicle.dart';

class VehicleItem extends StatelessWidget {
  final Vehicle vehicle;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const VehicleItem({
    super.key,
    required this.vehicle,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;
    if (vehicle.type == 'Car') {
      icon = Icons.directions_car;
    } else if (vehicle.type == 'Bike') {
      icon = Icons.two_wheeler;
    } else {
      icon = Icons.directions;
    }

    Color color;
    if (vehicle.type == 'Car') {
      color = Colors.blue;
    } else if (vehicle.type == 'Bike') {
      color = Colors.orange;
    } else {
      color = Colors.grey;
    }

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 6),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: color.withOpacity(0.2),
            child: Icon(icon, color: color),
          ),
          title: Text(
            vehicle.name,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          subtitle: Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text(
              '${vehicle.type} • ${vehicle.price}',
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
          ),
          trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          onTap: onTap,
          onLongPress: onLongPress,
        ),
      ),
    );
  }
}
