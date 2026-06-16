import 'package:flutter/material.dart';
import '../models/vehicle.dart';
import 'package:image_picker/image_picker.dart';

class AddVehicleScreen extends StatefulWidget {
  final Vehicle? vehicle;

  const AddVehicleScreen({super.key, this.vehicle});

  @override
  _AddVehicleScreenState createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  String? imagePath;

  Future<void> pickImage() async {
    final picker = ImagePicker();

    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        imagePath = pickedFile.path;
      });
    }
  }

  final TextEditingController nameController = TextEditingController();
  final TextEditingController typeController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController yearController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.vehicle != null) {
      nameController.text = widget.vehicle!.name;
      typeController.text = widget.vehicle!.type;
      yearController.text = widget.vehicle!.year.toString();
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
              controller: yearController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Manufacture Year'),
            ),
            TextField(
              controller: priceController,
              decoration: InputDecoration(labelText: 'Price'),
            ),

            ElevatedButton(
              onPressed: pickImage,
              child: const Text("Select Vehicle Image"),
            ),

            const SizedBox(height: 10),

            if (imagePath != null)
              const Text(
                "Image Selected ✓",
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),

            const SizedBox(height: 20),

            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final newVehicle = Vehicle(
                  id: widget.vehicle?.id,
                  name: nameController.text,
                  type: typeController.text,
                  year: int.parse(yearController.text),
                  price: double.parse(priceController.text),

                  imagePath: imagePath,
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
