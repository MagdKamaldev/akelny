import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graduation/core/auth_service.dart';
import 'package:graduation/screens/recipe_details_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  String? _selectedCategory;
  double? _selectedRating;
  String? _selectedSortBy;
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;

  final List<String> _categories = [
    'Italian',
    'Mexican',
    'Chinese',
    'Indian',
    'Japanese',
    'American',
    'Other',
  ];

  final List<String> _sortOptions = [
    'newest',
    'oldest',
    'rating_high',
    'rating_low',
  ];

  Future<void> _performSearch() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final results = await AuthService().searchRecipes(
        keyword: _searchController.text,
        category: _selectedCategory,
        rating: _selectedRating,
        sortBy: _selectedSortBy,
      );
      setState(() {
        _searchResults = results;
      });
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
        foregroundColor: Colors.white,
        title: const Text('Search Recipes',style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Input
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Keyword',
                hintText: 'e.g., Chicken',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Category Dropdown
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: _categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // Rating Slider
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Minimum Rating'),
                Slider(
                  activeColor: Colors.green,
                  value: _selectedRating ?? 0.0,
                  min: 0.0,
                  max: 5.0,
                  divisions: 5,
                  label: _selectedRating?.toStringAsFixed(1),
                  onChanged: (value) {
                    setState(() {
                      _selectedRating = value;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Sort By Dropdown
            DropdownButtonFormField<String>(
              value: _selectedSortBy,
              decoration: const InputDecoration(
                labelText: 'Sort By',
                border: OutlineInputBorder(),
              ),
              items: _sortOptions.map((option) {
                return DropdownMenuItem(
                  value: option,
                  child: Text(option.replaceAll('_', ' ')),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSortBy = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // Search Button
            ElevatedButton(
              onPressed: _performSearch,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Search'),
            ),
            const SizedBox(height: 16),

            // Loading Indicator
            if (_isLoading) const CircularProgressIndicator(),

            // Search Results
            Expanded(
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final recipe = _searchResults[index];
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