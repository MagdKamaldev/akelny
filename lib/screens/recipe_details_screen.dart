import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graduation/core/auth_service.dart';

class RecipeDetailsScreen extends StatefulWidget {
  final String name;

  const RecipeDetailsScreen({
    super.key,
    required this.name,
  });

  @override
  State<RecipeDetailsScreen> createState() => _RecipeDetailsScreenState();
}

class _RecipeDetailsScreenState extends State<RecipeDetailsScreen> {
  Map<String, dynamic>? recipe;
  bool isSaved = false;
  double userRating = 0.0;

  @override
  void initState() {
    super.initState();
    fetchRecipeDetails();
  }

  Future<void> fetchRecipeDetails() async {
    try {
      final data = await AuthService().getRecipeDetails(widget.name);
      setState(() {
        recipe = data;
        isSaved = data["is_saved"] ?? false; // Initialize isSaved from API
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch recipe: $error')),
      );
    }
  }

  Future<void> toggleSaveRecipe() async {
    try {
      if (isSaved) {
        await AuthService().unsaveRecipe(recipe!['name'],context);
      } else {
        await AuthService().saveRecipe(recipe!['name'], context);
      }
      setState(() {
        isSaved = !isSaved; // Toggle the save state
        recipe!["is_saved"] = isSaved; // Update recipe data
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update save status: $error')),
      );
    }
  }

  void rateRecipe(double rating,String name,BuildContext context) {
    AuthService().rateRecipe(name, rating, context);
    setState(() {
      userRating = rating;
    });
  }

  Widget buildSection({
    required String title,
    required String content,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon ?? Icons.info, color: const Color(0xFF2E7D32), size: 28),
              const SizedBox(width: 10),
              Text(
                title,
                style: GoogleFonts.lato(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2E7D32),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F8E9),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              content,
              style: GoogleFonts.lato(
                fontSize: 16,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        title: Text(
          'Recipe Details',
          style: GoogleFonts.lato(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: recipe == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Recipe Image and Title
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.network(
                          recipe!['image'] != null
                              ? "$baseUrl${recipe!['image']}"
                              : "https://theninjacue.com/wp-content/uploads/2024/04/13-erin_hungsberg-0r4a3413-ninjacue-oven-baby-back-ribs-24-768x960.jpg",
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        bottom: 10,
                        left: 10,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              recipe!['name'] ?? "Unknown",
                              style: GoogleFonts.lato(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                const Icon(Icons.timer,
                                    color: Colors.white, size: 16),
                                const SizedBox(width: 5),
                                Text(
                                  recipe!['time'].toString(),
                                  style: GoogleFonts.lato(color: Colors.white),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Like, Save, and Rate Buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            IconButton(
                              icon: Icon(
                                isSaved ? Icons.bookmark : Icons.bookmark_border,
                                color: const Color(0xFF2E7D32),
                              ),
                              onPressed: toggleSaveRecipe,
                            ),
                            const Text('Save'),
                          ],
                        ),
                        Column(
                          children: [
                            DropdownButton<double>(
                              value: userRating,
                              items: List.generate(6, (index) => index.toDouble())
                                  .map((rating) {
                                return DropdownMenuItem(
                                  value: rating,
                                  child: Text('$rating stars'),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  rateRecipe(value,recipe!['name'],context);
                                }
                              },
                            ),
                            const Text('Rate'),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Display sections
                  buildSection(
                    title: "Category",
                    content: recipe!['category'] ?? "Unknown",
                    icon: Icons.category,
                  ),
                  buildSection(
                    title: "Rating",
                    content: recipe!['rate'] ?? "Unknown",
                    icon: Icons.star,
                  ),
                  buildSection(
                    title: "Serving Size",
                    content: recipe!['serving_size'] ?? "Not provided",
                    icon: Icons.people,
                  ),
                  buildSection(
                    title: "Calories",
                    content: "${recipe!['calories']} kcal",
                    icon: Icons.local_fire_department,
                  ),
                  buildSection(
                    title: "Fats",
                    content: "${recipe!['fats']} g",
                    icon: Icons.opacity,
                  ),
                  buildSection(
                    title: "Carbohydrates",
                    content: "${recipe!['carbs']} g",
                    icon: Icons.cake,
                  ),
                  buildSection(
                    title: "Protein",
                    content: "${recipe!['protein']} g",
                    icon: Icons.fitness_center,
                  ),
                  buildSection(
                    title: "Ingredients",
                    content:
                        recipe!['ingredients'] ?? "No ingredients provided.",
                    icon: Icons.restaurant_menu,
                  ),
                  buildSection(
                    title: "Instructions",
                    content:
                        recipe!['instructions'] ?? "No instructions provided.",
                    icon: Icons.menu_book,
                  ),
                ],
              ),
            ),
    );
  }
}