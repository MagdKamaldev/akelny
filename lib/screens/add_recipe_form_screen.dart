import 'dart:io'; // Import the dart:io library
import 'package:flutter/material.dart';
import '../core/auth_service.dart'; // Import AuthService for backend integration

class AddRecipeFormScreen extends StatefulWidget {
  final String imagePath;

  const AddRecipeFormScreen({super.key, required this.imagePath});

  @override
  _AddRecipeFormScreenState createState() => _AddRecipeFormScreenState();
}

class _AddRecipeFormScreenState extends State<AddRecipeFormScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController ratingController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController ingredientsController = TextEditingController();
  final TextEditingController stepsController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final AuthService authService = AuthService(); // Initialize AuthService
  bool isLoading = false;

  Future<void> _saveRecipe() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        isLoading = true;
      });

      final recipeData = {
        'name': nameController.text,
        'category': categoryController.text,
        'rating': double.tryParse(ratingController.text) ?? 0.0,
        'time': int.tryParse(timeController.text) ?? 0,
        'ingredients': ingredientsController.text,
        'steps': stepsController.text,
      };

      try {
        // Call AuthService to save the recipe data
        await authService.saveRecipe(recipeData, File(widget.imagePath));

        // Show confirmation message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recipe saved successfully!')),
        );

        // Navigate back
        Navigator.pop(context);
      } catch (error) {
        // Handle errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save recipe: $error')),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Recipe Details'),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display the image
              Center(
                child: Image.file(
                  File(widget.imagePath),
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 20),

              // Recipe Name
              _buildTextField(
                controller: nameController,
                label: 'Recipe Name',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a recipe name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Category
              _buildTextField(
                controller: categoryController,
                label: 'Category',
              ),
              const SizedBox(height: 20),

              // Rating
              _buildTextField(
                controller: ratingController,
                label: 'Rating',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a rating';
                  }
                  final rating = double.tryParse(value);
                  if (rating == null || rating < 0 || rating > 5) {
                    return 'Please enter a rating between 0 and 5';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Cooking Time
              _buildTextField(
                controller: timeController,
                label: 'Cooking Time (mins)',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter cooking time';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Ingredients
              _buildTextField(
                controller: ingredientsController,
                label: 'Ingredients',
                maxLines: 5,
              ),
              const SizedBox(height: 20),

              // Steps
              _buildTextField(
                controller: stepsController,
                label: 'Steps',
                maxLines: 5,
              ),
              const SizedBox(height: 20),

              // Save Button
              ElevatedButton(
                onPressed: isLoading ? null : _saveRecipe,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Save Recipe'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: validator,
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    categoryController.dispose();
    ratingController.dispose();
    timeController.dispose();
    ingredientsController.dispose();
    stepsController.dispose();
    super.dispose();
  }
}
