import 'package:flutter/material.dart';
import '../models/vehicle.dart';

class AddVehicleScreen extends StatefulWidget {
  final Vehicle? vehicle;

  const AddVehicleScreen({super.key, this.vehicle});

  @override
  _AddVehicleScreenState createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController typeController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.vehicle != null) {
      nameController.text = widget.vehicle!.name;
      typeController.text = widget.vehicle!.type;
      priceController.text = widget.vehicle!.price.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.vehicle == null ? 'Add Vehicle' : 'Edit Vehicle'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Vehicle Name'),
            ),
            TextField(
              controller: typeController,
              decoration: InputDecoration(labelText: 'Type'),
            ),
            TextField(
              controller: priceController,
              decoration: InputDecoration(labelText: 'Price'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final newVehicle = Vehicle(
                  id: widget.vehicle?.id,
                  name: nameController.text,
                  type: typeController.text,
                  price: double.parse(priceController.text),
                );

                Navigator.pop(context, newVehicle);
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
