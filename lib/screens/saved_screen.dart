import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'recipe_details_screen.dart'; // Import the Recipe Details Screen
import '../core/auth_service.dart'; // Import AuthService for backend integration

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedRecipesState();
}

class _SavedRecipesState extends State<SavedScreen> {
  List<Map<String, dynamic>> recipes = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchSavedRecipes();
  }

  Future<void> fetchSavedRecipes() async {
    setState(() {
      isLoading = true; // Start loading
    });
    try {
      final savedRecipes = await AuthService().getSavedRecipes();
      setState(() {
        // Assuming the response is a list of saved recipe objects
        recipes = List<Map<String, dynamic>>.from(savedRecipes.map((item) => item['recipe']));
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch saved recipes: $error')),
      );
    } finally {
      setState(() {
        isLoading = false; // Stop loading
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(), // Show loading indicator
            )
          : recipes.isEmpty
              ? Center(
                  child: Text(
                    'No Saved Recipes available!',
                    style: GoogleFonts.lato(fontSize: 16, color: Colors.black54),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ListView.builder(
                    itemCount: recipes.length,
                    itemBuilder: (context, index) {
                      return _buildRecipeCard(context, recipes[index]);
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: fetchSavedRecipes,
        backgroundColor: Colors.green,
        tooltip: 'Refresh Recipes',
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }

  Widget _buildRecipeCard(BuildContext context, Map<String, dynamic> recipe) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        color: const Color(0xFFF1F8E9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 5,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RecipeDetailsScreen(
                  name: recipe['name'] ?? "Unknown Recipe",
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Recipe Image
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                child: Image.network(
                  recipe['image'] != null
                      ? "$baseUrl${recipe['image']}"
                      : "https://theninjacue.com/wp-content/uploads/2024/04/13-erin_hungsberg-0r4a3413-ninjacue-oven-baby-back-ribs-24-768x960.jpg", // Fallback image
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Recipe Name
                    Text(
                      recipe['name'] ?? "Recipe Name",
                      style: GoogleFonts.lato(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 5),

                    // Category and Rating
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Category
                        Row(
                          children: [
                            const Icon(Icons.category,
                                color: Colors.grey, size: 16),
                            const SizedBox(width: 5),
                            Text(
                              recipe['category'] ?? "Other",
                              style: GoogleFonts.lato(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 5),
                          Text(
                            recipe['average_rating'] != null
                                ? '${double.parse(recipe['average_rating'].toString()).toStringAsFixed(2)} stars'
                                : 'No ratings',
                            style: GoogleFonts.lato(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      ]
                    ),
                    
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
