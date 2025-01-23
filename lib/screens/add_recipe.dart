import 'package:flutter/material.dart';
import 'package:graduation/core/auth_service.dart';

class CreateRecipeScreen extends StatefulWidget {
  const CreateRecipeScreen({Key? key}) : super(key: key);

  @override
  _CreateRecipeScreenState createState() => _CreateRecipeScreenState();
}

class _CreateRecipeScreenState extends State<CreateRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _servingSizeController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _fatsController = TextEditingController();
  final _carbsController = TextEditingController();
  final _proteinController = TextEditingController();
  final _timeController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _densityController = TextEditingController();

  // List of predefined categories
  final List<String> _categories = [
    'Italian',
    'Mexican',
    'Chinese',
    'Indian',
    'Japanese',
    'American',
    'Other',
  ];

  String? _selectedCategory; // Selected category

  Future<void> _submitRecipe() async {
    if (_formKey.currentState!.validate()) {
      final recipeData = {
        "name": _nameController.text,
        "category": _selectedCategory, // Use selected category
        "serving_size": _servingSizeController.text,
        "calories": _caloriesController.text,
        "fats": _fatsController.text,
        "carbs": _carbsController.text,
        "protein": _proteinController.text,
        "time": int.parse(_timeController.text),
        "ingredients": _ingredientsController.text,
        "instructions": _instructionsController.text,
        "density": _densityController.text,
      };

      try {
        await AuthService().createRecipe(recipeData, context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Recipe',style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Name
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(), // Add border
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Category Dropdown
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(), // Add border
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value; // Update selected category
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a category';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Serving Size
              TextFormField(
                controller: _servingSizeController,
                decoration: InputDecoration(
                  labelText: 'Serving Size',
                  border: OutlineInputBorder(), // Add border
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a serving size';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Calories
              TextFormField(
                controller: _caloriesController,
                decoration: InputDecoration(
                  labelText: 'Calories',
                  border: OutlineInputBorder(), // Add border
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter calories';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Fats
              TextFormField(
                controller: _fatsController,
                decoration: InputDecoration(
                  labelText: 'Fats',
                  border: OutlineInputBorder(), // Add border
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter fats';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Carbs
              TextFormField(
                controller: _carbsController,
                decoration: InputDecoration(
                  labelText: 'Carbs',
                  border: OutlineInputBorder(), // Add border
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter carbs';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Protein
              TextFormField(
                controller: _proteinController,
                decoration: InputDecoration(
                  labelText: 'Protein',
                  border: OutlineInputBorder(), // Add border
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter protein';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Time
              TextFormField(
                controller: _timeController,
                decoration: InputDecoration(
                  labelText: 'Time (minutes)',
                  border: OutlineInputBorder(), // Add border
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter time';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Ingredients
              TextFormField(
                controller: _ingredientsController,
                decoration: InputDecoration(
                  labelText: 'Ingredients',
                  border: OutlineInputBorder(), // Add border
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter ingredients';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Instructions
              TextFormField(
                controller: _instructionsController,
                decoration: InputDecoration(
                  labelText: 'Instructions',
                  border: OutlineInputBorder(), // Add border
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter instructions';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Density
              TextFormField(
                controller: _densityController,
                decoration: InputDecoration(
                  labelText: 'Density',
                  border: OutlineInputBorder(), // Add border
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter density';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Submit Button
              ElevatedButton(
                onPressed: _submitRecipe,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Create Recipe'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}