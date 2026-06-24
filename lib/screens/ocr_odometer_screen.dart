import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrOdometerScreen extends StatefulWidget {
  const OcrOdometerScreen({super.key});

  @override
  State<OcrOdometerScreen> createState() => _OcrOdometerScreenState();
}

class _OcrOdometerScreenState extends State<OcrOdometerScreen> {
  File? _image;
  List<String> detectedNumbers = [];

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera);

    if (picked == null) return;

    setState(() {
      _image = File(picked.path);
    });

    runOCR(File(picked.path));
  }

  Future<void> runOCR(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final textRecognizer = TextRecognizer();

    final recognizedText = await textRecognizer.processImage(inputImage);

    List<String> numbers = [];

    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        final text = line.text;

        final matches = RegExp(r'\d+').allMatches(text);

        for (var m in matches) {
          final value = m.group(0)!;

          // 🔥 FILTER: only keep long numbers (likely odometer)
          if (value.length >= 5) {
            numbers.add(value);
          }
        }
      }
    }

    // 🔥 Pick BEST candidate (longest number)
    numbers.sort((a, b) => b.length.compareTo(a.length));

    setState(() {
      detectedNumbers = numbers;
    });

    textRecognizer.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan Odometer")),

      body: Column(
        children: [
          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: pickImage,
            child: const Text("📷 Take Photo"),
          ),

          const SizedBox(height: 20),

          if (_image != null) Image.file(_image!, height: 200),

          const SizedBox(height: 20),

          const Text("Detected numbers:"),

          Expanded(
            child: ListView.builder(
              itemCount: detectedNumbers.length,
              itemBuilder: (context, index) {
                final number = detectedNumbers[index];

                return ListTile(
                  title: Text(number),
                  onTap: () {
                    Navigator.pop(context, number); // return selected number
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
