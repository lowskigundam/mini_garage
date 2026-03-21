import 'package:flutter/material.dart';

class AddVehicleScreen extends StatefulWidget {
  final Map<String, String>? vehicle;

  AddVehicleScreen({this.vehicle});

  @override
  _AddVehicleScreenState createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  // Step A2: Create controllers
  final TextEditingController nameController = TextEditingController();

  final TextEditingController typeController = TextEditingController();

  final TextEditingController priceController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.vehicle != null) {
      nameController.text = widget.vehicle!['name']!;
      typeController.text = widget.vehicle!['type']!;
      priceController.text = widget.vehicle!['price']!;
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
            // Name input
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Vehicle Name'),
            ),

            // Type input
            TextField(
              controller: typeController,
              decoration: InputDecoration(labelText: 'Type'),
            ),

            // Price input
            TextField(
              controller: priceController,
              decoration: InputDecoration(labelText: 'Price'),
            ),

            SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                // Step A3: Create data map
                final newVehicle = {
                  'name': nameController.text,
                  'type': typeController.text,
                  'price': priceController.text,
                };

                // Step A4: Go back + send data
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
