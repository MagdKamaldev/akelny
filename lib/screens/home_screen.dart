// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graduation/core/auth_service.dart';
import 'package:graduation/screens/camera_screen.dart';
import 'package:graduation/screens/recipe_details_screen.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave;

  const HomeScreen({super.key, required this.onSave});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> recipes = [];
  List<Map<String, dynamic>> displayedRecipes = [];
  String searchText = '';
  String selectedCategory = 'All';
  double selectedRating = 0.0;
  bool isLoading = true;
  final AuthService authService = AuthService(); // AuthService instance

  @override
  void initState() {
    super.initState();
    _fetchRecipes();
  }

  Future<void> _fetchRecipes() async {
    try {
      final fetchedRecipes = await authService.fetchRecipes();
      setState(() {
        recipes = fetchedRecipes;
        displayedRecipes = List.from(recipes);
        isLoading = false;
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch recipes: $error')),
      );
    }
  }

  void _applyFilters() {
    setState(() {
      displayedRecipes = recipes.where((recipe) {
        final matchesSearchText =
            recipe['title'].toLowerCase().contains(searchText.toLowerCase());
        final matchesCategory =
            selectedCategory == 'All' || recipe['category'] == selectedCategory;
        final matchesRating = recipe['rating'] >= selectedRating;

        return matchesSearchText && matchesCategory && matchesRating;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (DragEndDetails details) {
        if (details.primaryVelocity! < 0) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CameraScreen()),
          );
        }
      },
      child: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search and Filter Section
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        TextField(
                          onChanged: (value) {
                            setState(() {
                              searchText = value;
                              _applyFilters();
                            });
                          },
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: searchText.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      setState(() {
                                        searchText = '';
                                        _applyFilters();
                                      });
                                    },
                                  )
                                : null,
                            hintText: 'Search recipes...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        DropdownButton<String>(
                          isExpanded: true,
                          value: selectedCategory,
                          items: ['All', 'Arabic', 'Italian', 'Asian', 'Other']
                              .map(
                                  (String category) => DropdownMenuItem<String>(
                                        value: category,
                                        child: Text(category),
                                      ))
                              .toList(),
                          onChanged: (String? value) {
                            setState(() {
                              selectedCategory = value!;
                              _applyFilters();
                            });
                          },
                        ),
                        const SizedBox(height: 10),
                        DropdownButton<double>(
                          isExpanded: true,
                          value: selectedRating,
                          items: [
                            DropdownMenuItem<double>(
                              value: 0.0,
                              child: const Text('All Ratings'),
                            ),
                            DropdownMenuItem<double>(
                              value: 5.0,
                              child: const Text('5 stars'),
                            ),
                            DropdownMenuItem<double>(
                              value: 4.0,
                              child: const Text('4 stars and up'),
                            ),
                            DropdownMenuItem<double>(
                              value: 3.0,
                              child: const Text('3 stars and up'),
                            ),
                            DropdownMenuItem<double>(
                              value: 2.0,
                              child: const Text('2 stars and up'),
                            ),
                            DropdownMenuItem<double>(
                              value: 1.0,
                              child: const Text('1 star and up'),
                            ),
                          ],
                          onChanged: (double? value) {
                            setState(() {
                              selectedRating = value!;
                              _applyFilters();
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: displayedRecipes.isEmpty
                        ? Center(
                            child: Text(
                              'No recipes found.',
                              style: GoogleFonts.lato(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: displayedRecipes.length,
                            itemBuilder: (context, index) {
                              final recipe = displayedRecipes[index];
                              return _buildRecipeCard(context, recipe);
                            },
                          ),
                  ),
                ],
              ),
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
                name: recipe["name"],
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
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(15)),
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
                        // Rating
                        Row(
                          children: [
                            const Icon(Icons.star,
                                color: Colors.amber, size: 16),
                            const SizedBox(width: 5),
                            Text(
                              recipe['rating'] != null
                                  ? '${recipe['rating']} stars'
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
