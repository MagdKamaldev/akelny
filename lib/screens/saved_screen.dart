import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'recipe_details_screen.dart'; // Import the Recipe Details Screen
import '../core/auth_service.dart'; // Import AuthService for backend integration

class SavedScreen extends StatefulWidget {
  final List<Map<String, dynamic>> savedRecipes;
  final void Function(Map<String, dynamic>) onUnsave;
  final void Function(Map<String, dynamic>) onSave;

  const SavedScreen({
    super.key,
    required this.savedRecipes,
    required this.onUnsave,
    required this.onSave,
  });

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  final AuthService _authService = AuthService(); // Initialize AuthService
  late List<Map<String, dynamic>> savedRecipes;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    savedRecipes = widget.savedRecipes; // Initialize with provided recipes
    _fetchSavedRecipes();
  }

  // Fetch saved recipes from the backend
  Future<void> _fetchSavedRecipes() async {
    try {
      final recipes = await _authService.getSavedRecipes();
      setState(() {
        savedRecipes = recipes;
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch saved recipes: $error')),
      );
    }
  }

  // Remove recipe from saved list and update backend
  Future<void> _unsaveRecipe(Map<String, dynamic> recipe) async {
    try {
      await _authService.unsaveRecipe(recipe['id']);
      setState(() {
        savedRecipes.remove(recipe);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recipe removed from saved successfully')),
      );
      widget.onUnsave(recipe); // Notify parent about unsave
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to unsave recipe: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return savedRecipes.isEmpty
        ? Center(
      child: Text(
        "No saved recipes yet.",
        style: GoogleFonts.lato(fontSize: 16, color: Colors.black54),
      ),
    )
        : ListView.builder(
      itemCount: savedRecipes.length,
      itemBuilder: (context, index) {
        final recipe = savedRecipes[index];
        return _buildSavedRecipeCard(context, recipe);
      },
    );
  }

  Widget _buildSavedRecipeCard(BuildContext context, Map<String, dynamic> recipe) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 5,
        child: ListTile(
          leading: Image.network(
            recipe['image'],
            width: 50,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.image_not_supported),
          ),
          title: Text(recipe['title']),
          subtitle: Text('Time: ${recipe['time']}'),
          onTap: () {
            // Navigate to Recipe Details Screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RecipeDetailsScreen(
                  recipe: recipe,
                  onSave: widget.onSave, // Notify parent after save action
                ),
              ),
            );
          },
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _unsaveRecipe(recipe), // Remove recipe
          ),
        ),
      ),
    );
  }
}
