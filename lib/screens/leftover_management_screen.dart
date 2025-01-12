import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LeftoverManagementScreen extends StatefulWidget {
  const LeftoverManagementScreen({super.key});

  @override
  LeftoverManagementScreenState createState() =>
      LeftoverManagementScreenState();
}

class LeftoverManagementScreenState extends State<LeftoverManagementScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;
  Map<String, dynamic>? _recipeSuggestions; // Store API response here
  bool _isLoading = false;

  // Function to pick an image from the gallery or camera
  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (!mounted) return;
    if (image != null) {
      setState(() {
        _selectedImage = image;
        _recipeSuggestions = null; // Clear previous suggestions
      });
    }
  }

  // Function to send the image to the ML model API
  Future<void> _getRecipeSuggestions() async {
    if (_selectedImage == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select an image first!")),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Replace with your ML model API endpoint
      final Uri apiUrl = Uri.parse('https://your-api-endpoint.com/predict');
      final request = http.MultipartRequest('POST', apiUrl);

      // Add the image file to the request
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        _selectedImage!.path,
      ));

      // Send the request
      final response = await request.send();
      final responseData = await http.Response.fromStream(response);

      if (response.statusCode == 200) {
        // Parse the response JSON
        setState(() {
          _recipeSuggestions = json.decode(responseData.body);
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to get recipe suggestions.")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("An error occurred. Please try again.")),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Manage your leftovers efficiently!',
            style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // Display selected image or placeholder
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey, width: 1.0),
              ),
              child: _selectedImage == null
                  ? const Center(
                child: Text(
                  "No image selected",
                  style: TextStyle(fontSize: 16),
                ),
              )
                  : ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(_selectedImage!.path),
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Buttons for picking images
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.camera),
                icon: const Icon(Icons.camera_alt),
                label: const Text("Camera"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.gallery),
                icon: const Icon(Icons.photo_library),
                label: const Text("Gallery"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Get Recipe Suggestions button
          ElevatedButton(
            onPressed: _isLoading ? null : _getRecipeSuggestions,
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text("Get Recipe Suggestions"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              padding: const EdgeInsets.symmetric(vertical: 15),
              textStyle:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 20),

          // Display recipe suggestions
          if (_recipeSuggestions != null)
            Expanded(
              child: ListView(
                children: [
                  Text(
                    "Suggested Recipe:",
                    style: GoogleFonts.lato(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...(_recipeSuggestions!['ingredients'] as List<dynamic>).map(
                        (ingredient) => ListTile(
                      leading: const Icon(Icons.check_circle,
                          color: Color(0xFF2E7D32)),
                      title: Text(ingredient['name']),
                      subtitle:
                      Text("Quantity: ${ingredient['quantity']}"),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
