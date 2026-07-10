import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrOdometerScreen extends StatefulWidget {
  const OcrOdometerScreen({super.key});

  @override
  State<OcrOdometerScreen> createState() => _OcrOdometerScreenState();
}

class _OcrOdometerScreenState extends State<OcrOdometerScreen> {
  final TextEditingController _mileageController = TextEditingController();

  File? _image;
  List<String> _candidates = [];

  bool _isProcessing = false;
  bool _scanCompleted = false;

  @override
  void dispose() {
    _mileageController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();

    final picked = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 100,
    );

    if (picked == null) return;

    final imageFile = File(picked.path);

    setState(() {
      _image = imageFile;
      _candidates = [];
      _scanCompleted = false;
      _isProcessing = true;
    });

    _mileageController.clear();

    await _runOcr(imageFile);
  }

  Future<void> _runOcr(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final textRecognizer = TextRecognizer();

    try {
      final recognizedText = await textRecognizer.processImage(inputImage);

      debugPrint('===== FULL OCR TEXT =====');
      debugPrint(recognizedText.text);
      debugPrint('=========================');

      final candidates = <String>{};

      for (final block in recognizedText.blocks) {
        for (final line in block.lines) {
          debugPrint('OCR LINE: ${line.text}');

          // Common OCR mistakes in digital displays.
          final normalizedText = line.text
              .toUpperCase()
              .replaceAll('O', '0')
              .replaceAll('I', '1')
              .replaceAll('L', '1')
              .replaceAll('S', '5')
              .replaceAll('B', '8');

          // This helps when OCR reads an odometer as "120 629".
          final joinedDigits = normalizedText.replaceAll(RegExp(r'[^0-9]'), '');

          if (_isPossibleOdometer(joinedDigits)) {
            candidates.add(joinedDigits);
          }

          // Also keep individual numeric groups.
          final matches = RegExp(r'\d+').allMatches(normalizedText);

          for (final match in matches) {
            final value = match.group(0);

            if (value != null && _isPossibleOdometer(value)) {
              candidates.add(value);
            }
          }
        }
      }

      final sortedCandidates = candidates.toList()
        ..sort((a, b) {
          // Longer numbers are generally more likely to be odometer values.
          final lengthComparison = b.length.compareTo(a.length);

          if (lengthComparison != 0) {
            return lengthComparison;
          }

          return b.compareTo(a);
        });

      if (!mounted) return;

      setState(() {
        _candidates = sortedCandidates;
        _scanCompleted = true;
        _isProcessing = false;

        // Suggest the best candidate, but do not save it automatically.
        if (sortedCandidates.isNotEmpty) {
          _mileageController.text = sortedCandidates.first;
        }
      });
    } catch (error) {
      debugPrint('OCR ERROR: $error');

      if (!mounted) return;

      setState(() {
        _candidates = [];
        _scanCompleted = true;
        _isProcessing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'The image could not be scanned. You can enter the mileage manually.',
          ),
        ),
      );
    } finally {
      await textRecognizer.close();
    }
  }

  bool _isPossibleOdometer(String value) {
    // Supports most 4–8 digit odometers.
    return value.length >= 4 &&
        value.length <= 8 &&
        int.tryParse(value) != null;
  }

  void _selectCandidate(String candidate) {
    setState(() {
      _mileageController.text = candidate;
    });
  }

  void _confirmMileage() {
    FocusScope.of(context).unfocus();

    final value = _mileageController.text.trim();
    final mileage = double.tryParse(value);

    if (mileage == null || mileage < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid mileage value.')),
      );
      return;
    }

    // Returns the confirmed value to the previous screen.
    Navigator.pop(context, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Odometer')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Move close to the dashboard and keep only the odometer '
              'display clearly visible. After scanning, verify or correct '
              'the detected value before confirming.',
              style: TextStyle(fontSize: 14),
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isProcessing ? null : _pickImage,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Take Photo'),
            ),
          ),

          const SizedBox(height: 20),

          if (_image != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(_image!, height: 240, fit: BoxFit.contain),
            ),

          if (_image != null) const SizedBox(height: 20),

          if (_isProcessing) ...[
            const Center(child: CircularProgressIndicator()),
            const SizedBox(height: 12),
            const Center(child: Text('Reading odometer...')),
          ],

          if (!_isProcessing && _scanCompleted && _candidates.isEmpty) ...[
            const Text(
              'No reliable odometer value was detected.',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Take another photo or enter the mileage manually below.',
            ),
          ],

          if (!_isProcessing && _candidates.isNotEmpty) ...[
            const Text(
              'Detected suggestions',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _candidates.map((candidate) {
                return ActionChip(
                  label: Text(candidate),
                  avatar: const Icon(Icons.speed, size: 18),
                  onPressed: () => _selectCandidate(candidate),
                );
              }).toList(),
            ),
          ],

          const SizedBox(height: 24),

          TextField(
            controller: _mileageController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'Mileage',
              hintText: 'Enter or correct the detected mileage',
              suffixText: 'km',
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _confirmMileage,
              child: const Text('Use This Mileage'),
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            'The OCR result is only a suggestion. Always verify the '
            'number before saving it.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
