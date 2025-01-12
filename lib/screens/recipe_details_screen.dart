// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graduation/core/auth_service.dart';
import 'package:http/http.dart' as http;

class RecipeDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> recipe;
  final Function(Map<String, dynamic>) onSave;

  const RecipeDetailsScreen({
    super.key,
    required this.recipe,
    required this.onSave,
  });

  @override
  State<RecipeDetailsScreen> createState() => _RecipeDetailsScreenState();
}

class _RecipeDetailsScreenState extends State<RecipeDetailsScreen> {
  bool isLiked = false;
  bool isSaved = false;
  late double userRating;

  @override
  void initState() {
    super.initState();
    isLiked = widget.recipe['isLiked'] ?? false;
    isSaved = widget.recipe['isSaved'] ?? false;
    userRating = widget.recipe['userRating'] ?? 0.0;
  }

  Map<String, dynamic> recipeDetails = {
    'ingredients': [],
    'steps': [],
    'nutritionInfo': {},
  };

  Future<void> _toggleSave() async {
    setState(() {
      isSaved = !isSaved;
    });

    try {
      final response = await http.post(
        Uri.parse(
            'http://127.0.0.1:8000/api/recipe/${widget.recipe['id']}/save/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'save': isSaved}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to toggle save');
      }

      if (isSaved) {
        widget.onSave(widget.recipe);
      }
    } catch (e) {
      setState(() {
        isSaved = !isSaved; // Revert on failure
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error toggling save: $e')),
      );
    }
  }

  Future<void> _rateRecipe(double rating) async {
    try {
      setState(() {
        userRating = rating;
      });

      final response = await http.post(
        Uri.parse(
            'http://127.0.0.1:8000/api/recipe/${widget.recipe['id']}/rate/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'rating': rating}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to rate recipe');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You rated this recipe: $rating stars')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error rating recipe: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        title: Text(
          'Recipe Details',
          style: GoogleFonts.lato(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
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
                    "$baseUrl${widget.recipe['image']}" ??
                        "https://theninjacue.com/wp-content/uploads/2024/04/13-erin_hungsberg-0r4a3413-ninjacue-oven-baby-back-ribs-24-768x960.jpg",
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
                        widget.recipe['name'] ?? "Unknown",
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
                          Text(widget.recipe['time'].toString(),
                              style: GoogleFonts.lato(color: Colors.white)),
                          const SizedBox(width: 15),
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 5),
                          Text(
                              '${widget.recipe['average_rating'].toString()} stars',
                              style: GoogleFonts.lato(color: Colors.white)),
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
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
                        onPressed: _toggleSave,
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
                            _rateRecipe(value);
                          }
                        },
                      ),
                      const Text('Rate'),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.lunch_dining,
                          color: Color(0xFF2E7D32), size: 28),
                      const SizedBox(width: 10),
                      Text(
                        'Category',
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
                      widget.recipe['category'] ?? "Unknown",
                      style: GoogleFonts.lato(
                        fontSize: 16,
                        color: Colors.black87,
                        height: 1.5, // Line height for better readability
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.watch_later_outlined,
                          color: Color(0xFF2E7D32), size: 28),
                      const SizedBox(width: 10),
                      Text(
                        'Time',
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
                      widget.recipe['time']?.toString() ??
                          "No creator information available.",
                      style: GoogleFonts.lato(
                        fontSize: 16,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.restaurant_menu,
                          color: Color(0xFF2E7D32), size: 28),
                      const SizedBox(width: 10),
                      Text(
                        'Ingredients',
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
                      widget.recipe['ingredients'] ??
                          "No ingredients provided.",
                      style: GoogleFonts.lato(
                        fontSize: 16,
                        color: Colors.black87,
                        height: 1.5, // Line height for better readability
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.restaurant_sharp,
                          color: Color(0xFF2E7D32), size: 28),
                      const SizedBox(width: 10),
                      Text(
                        'Instructions',
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
                          // ignore: deprecated_member_use
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      widget.recipe['instructions'] ??
                          "No ingredients provided.",
                      style: GoogleFonts.lato(
                        fontSize: 16,
                        color: Colors.black87,
                        height: 1.5, // Line height for better readability
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info,
                          color: Color(0xFF2E7D32), size: 28),
                      const SizedBox(width: 10),
                      Text(
                        'Density',
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
                      widget.recipe['density']?.toString() ??
                          "No density data available.",
                      style: GoogleFonts.lato(
                        fontSize: 16,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
