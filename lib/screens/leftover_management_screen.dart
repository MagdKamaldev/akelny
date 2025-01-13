import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:graduation/main.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class LeftoverReportScreen extends StatefulWidget {
  const LeftoverReportScreen({Key? key}) : super(key: key);

  @override
  _LeftoverReportScreenState createState() => _LeftoverReportScreenState();
}

class _LeftoverReportScreenState extends State<LeftoverReportScreen> {
  File? _selectedImage;
  bool _isLoading = false;
  List<dynamic>? _report;

  // Function to pick an image
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _report = null; // Clear previous report
      });
    }
  }

  // Function to upload the image and get the response
  Future<void> _uploadImage() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image first')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('http://0.0.0.0:8000/api/generate-leftover-report/'),
      );
      request.headers.addAll(
        {'Authorization': 'Bearer $token'}
      );
      request.files.add(
        await http.MultipartFile.fromPath('image', _selectedImage!.path),
      );

      final response = await request.send();

      print(response.statusCode);

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        setState(() {
          _report = jsonDecode(responseData)['reports'];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to fetch report')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leftover Report'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Image picker
            GestureDetector(
              onTap: _pickImage,
              child: _selectedImage != null
                  ? Image.file(_selectedImage!, height: 200, width: double.infinity, fit: BoxFit.cover)
                  : Container(
                      height: 200,
                      width: double.infinity,
                      color: Colors.grey[200],
                      child: const Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
                    ),
            ),
            const SizedBox(height: 20),

            // Upload button
            ElevatedButton.icon(
              onPressed: _uploadImage,
              icon: const Icon(Icons.upload),
              label: const Text('Upload Image'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),

            const SizedBox(height: 20),

            // Loading indicator
            if (_isLoading)
              const CircularProgressIndicator(),

            // Report display
            if (_report != null && !_isLoading)
              Expanded(
                child: ListView.builder(
                  itemCount: _report!.length,
                  itemBuilder: (context, index) {
                    final item = _report![index];
                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['name'] ?? 'Unknown',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text('Weight: ${item['weight_in_grams']} g'),
                            Text('Calories: ${item['calories']}'),
                            Text('Fats: ${item['fats']}'),
                            Text('Carbs: ${item['carbs']}'),
                            Text('Protein: ${item['protein']}'),
                            const SizedBox(height: 8),
                            Text(
                              'Ingredients: ${item['ingredients']}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
