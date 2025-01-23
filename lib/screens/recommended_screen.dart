import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graduation/core/auth_service.dart';
import 'package:graduation/screens/recipe_details_screen.dart';

class RecommendedRecipes extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave;
  const RecommendedRecipes({super.key, required this.onSave});

  @override
  State<RecommendedRecipes> createState() => _RecommendedRecipesState();
}

class _RecommendedRecipesState extends State<RecommendedRecipes> {
  List<Map<String, dynamic>> recipes = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchRecommendedRecipes();
  }

  Future<void> fetchRecommendedRecipes() async {
    try {
      final recommendedRecipes = await AuthService().getRecommendedRecipes();
      setState(() {
        recipes = recommendedRecipes;
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch recommendedRecipes: $error')),
      );
    }
  }
  @override
  Widget build(BuildContext context) {


    return recipes.isEmpty
        ? Center(
      child: Text(
        'No recommended Recipes available !',
        style: GoogleFonts.lato(fontSize: 16, color: Colors.black54),
      ),
    )
        : ListView.builder(
      itemCount: recipes.length,
      itemBuilder: (context, index) {
        return _buildRecipeCard(context, recipes[index]);
      },
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
               name: recipe['name'],
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
                    ? "$baseUrl${recipe['image']}" :
                    "https://theninjacue.com/wp-content/uploads/2024/04/13-erin_hungsberg-0r4a3413-ninjacue-oven-baby-back-ribs-24-768x960.jpg", // Fallback image
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
                          const Icon(Icons.category, color: Colors.grey, size: 16),
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
                      // Rating
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 5),
                          Text(
                            recipe['average_rating'] != null
                                ? '${recipe['average_rating']} stars'
                                : 'No ratings',
                            style: GoogleFonts.lato(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Action Buttons (Like and Save)
                 
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
