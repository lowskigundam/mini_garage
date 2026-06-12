import 'package:flutter/material.dart';
import '../models/vehicle.dart';

class AddVehicleScreen extends StatefulWidget {
  final Vehicle? vehicle;

  const AddVehicleScreen({super.key, this.vehicle});

  @override
  _AddVehicleScreenState createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  DateTime? lastService;
  DateTime? nextService;

  Future<void> pickDate(BuildContext context, bool isLastService) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isLastService) {
          lastService = picked;
        } else {
          nextService = picked;
        }
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

            SizedBox(height: 10),

            ElevatedButton(
              onPressed: () => pickDate(context, true),
              child: Text(
                lastService == null
                    ? "Select Last Service Date"
                    : "Last Service: ${lastService!.toLocal().toString().split(' ')[0]}",
              ),
            ),

            SizedBox(height: 10),

            ElevatedButton(
              onPressed: () => pickDate(context, false),
              child: Text(
                nextService == null
                    ? "Select Next Service Date"
                    : "Next Service: ${nextService!.toLocal().toString().split(' ')[0]}",
              ),
            ),

            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final newVehicle = Vehicle(
                  id: widget.vehicle?.id,
                  name: nameController.text,
                  type: typeController.text,
                  year: int.parse(yearController.text),
                  price: double.parse(priceController.text),

                  lastService: lastService,
                  nextService: nextService,
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
