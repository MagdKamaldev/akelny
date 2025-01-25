// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

const String ip = "172.20.10.2";
const String baseUrl = 'http://$ip:8000';

class AuthService {
  static const String signUpUrl = '$baseUrl/api/signup/';
  static const String signInUrl = '$baseUrl/api/signin/';
  static const String userProfileUrl = '$baseUrl/api/user/';
  static const String updateUserProfileUrl = '$baseUrl/api/user/update/';
  static const String saveRecipeUrl = '$baseUrl/api/save-recipe/';
  static const String getRecipeDetailsUrl = '$baseUrl/api/recipe-detail/';
  static const String recommendedRecipesUrl = '$baseUrl/api/recommendations/';
  static const String getSavedRecipesUrl = '$baseUrl/api/saved-recipes/';
  static const String unsaveRecipeUrl = '$baseUrl/api/unsave-recipe/';
  static const String imageUploadUrl = '$baseUrl/api/image-upload/';
  static const String chatbotUrl = '$baseUrl/api/chatbot/';
  static const String recipesUrl = '$baseUrl/api/recipes/';
  static const String rateRecipeUrl = '$baseUrl/api/recipes/rate/';
  static const String searchRecipesUrl = '$baseUrl/api/search-recipes/';

  final logger = Logger();

  Future<void> signUp(String username, String password, String confirmPass, {String? email, Map<String, String>? additionalData}) async {
    final headers = await _headers();
    final response = await http.post(
      Uri.parse(signUpUrl),
      headers: headers,
      body: jsonEncode({
        'username': username,
        'password': password,
        "password2": confirmPass,
        'email': email,
        if (additionalData != null) ...additionalData,
      }),
    );
    _logResponse(response, 'Sign-Up');
  }

  Future<void> signIn(String usernameOrEmail, String password, BuildContext context) async {
    final headers = await _headers();
    final response = await http.post(
      Uri.parse(signInUrl),
      headers: headers,
      body: jsonEncode({
        'email': usernameOrEmail,
        'password': password,
      }),
    );
    if (_handleResponse(response, 'Sign-In')) {
      String token = jsonDecode(response.body)['access'];
      await saveToken(token);
      Navigator.pushReplacementNamed(context, '/mainNavigation');
    }
  }

  Future<Map<String, dynamic>> getRecipeDetails(String name) async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse("$getRecipeDetailsUrl$name/"),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (_handleResponse(response, 'Fetch Recipe Details')) {
      return Map<String, dynamic>.from(jsonDecode(response.body));
    }
    throw Exception("Failed to fetch recipe details.");
  }

  Future<Map<String, dynamic>> getUserData() async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse(userProfileUrl),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (_handleResponse(response, 'Fetch User Data')) {
      return Map<String, dynamic>.from(jsonDecode(response.body));
    }
    throw Exception("Failed to fetch user data.");
  }

  Future<void> updateUserData(Map<String, dynamic> updatedData, BuildContext context) async {
    final headers = await _headers();
    final response = await http.put(
      Uri.parse(updateUserProfileUrl),
      headers: headers,
      body: jsonEncode(updatedData),
    );
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
      Navigator.pushReplacementNamed(context, '/mainNavigation');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile')),
      );
    }
  }

  Future<List<Map<String, dynamic>>> getRecommendedRecipes() async {
    final headers = await _headers();
    final response = await http.get(
      Uri.parse(recommendedRecipesUrl),
      headers: headers,
    );
    if (_handleResponse(response, 'Fetch Recommended Recipes')) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    }
    throw Exception("Failed to fetch recommended recipes.");
  }

  Future<void> saveRecipe(String name, BuildContext context) async {
    final headers = await _headers();
    final response = await http.post(
      Uri.parse(saveRecipeUrl),
      headers: headers,
      body: jsonEncode({
        "recipe_name": name,
      }),
    );
    if (_handleResponse(response, 'Save recipe')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saved successfully')),
      );
    }
  }

  Future<List<Map<String, dynamic>>> getSavedRecipes() async {
    final token = await getToken();
    final response = await http.get(
      Uri.parse(getSavedRecipesUrl),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (_handleResponse(response, 'Fetch Saved Recipes')) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    }
    throw Exception("Failed to fetch saved recipes.");
  }

  Future<void> unsaveRecipe(String recipeName, BuildContext context) async {
    final token = await getToken();
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json; charset=UTF-8',
    };

    final response = await http.delete(
      Uri.parse(unsaveRecipeUrl),
      headers: headers,
      body: jsonEncode({'name': recipeName}),
    );

    if (_handleResponse(response, 'Unsave Recipe')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Unsaved successfully")),
      );
    } else {
      throw Exception("Failed to unsave recipe.");
    }
  }

  Future<Map<String, dynamic>> uploadImage(File file) async {
    final token = await getToken();
    final request = http.MultipartRequest('POST', Uri.parse(imageUploadUrl))
      ..headers['Authorization'] = 'Bearer $token'
      ..files.add(await http.MultipartFile.fromPath('image', file.path));
    final response = await request.send();
    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      return jsonDecode(responseBody);
    }
    throw Exception("Failed to upload image.");
  }

  Future<void> saveToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> logOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  Future<List<Map<String, dynamic>>> fetchRecipes() async {
    final response = await http.get(Uri.parse(recipesUrl));
    if (_handleResponse(response, 'Fetch Recipes')) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    }
    return [];
  }

  Future<void> rateRecipe(String name, double rating, BuildContext context) async {
    final token = await getToken();
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json; charset=UTF-8',
    };

    final response = await http.post(
      Uri.parse(rateRecipeUrl),
      headers: headers,
      body: jsonEncode({
        'name': name,
        'rating': rating,
      }),
    );

    if (_handleResponse(response, 'Rate Recipe')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Rated successfully")),
      );
    } else {
      throw Exception("Failed to rate recipe.");
    }
  }

  // Search Recipes
  Future<List<Map<String, dynamic>>> searchRecipes({
    String? keyword,
    String? category,
    double? rating,
    String? sortBy,
  }) async {
    final token = await getToken();
    final headers = {
      'Authorization': 'Bearer $token',
    };

    // Build query parameters
    final queryParams = {
      if (keyword != null) 'keyword': keyword,
      if (category != null) 'category': category,
      if (rating != null) 'rating': rating.toString(),
      if (sortBy != null) 'sort_by': sortBy,
    };

    final response = await http.get(
      Uri.parse(searchRecipesUrl).replace(queryParameters: queryParams),
      headers: headers,
    );

    if (_handleResponse(response, 'Search Recipes')) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    }
    throw Exception("Failed to fetch search results.");
  }

  // Centralized response handling
  bool _handleResponse(http.Response response, String action) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      logger.i("$action successful.");
      return true;
    } else {
      logger.e("$action failed: ${response.body}");
      return false;
    }
  }

  Future<void> createRecipe(Map<String, dynamic> recipeData, BuildContext context) async {
  final token = await getToken();
  final headers = {
    'Authorization': 'Bearer $token',
    'Content-Type': 'application/json; charset=UTF-8',
  };

  final response = await http.post(
    Uri.parse('$baseUrl/api/create-recipe/'),
    headers: headers,
    body: jsonEncode(recipeData),
  );

  if (_handleResponse(response, 'Create Recipe')) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Recipe created successfully!')),
    );
    Navigator.pop(context); // Return to the previous screen
  } else {
    throw Exception("Failed to create recipe.");
  }
}

  // Centralized headers generation
  Future<Map<String, String>> _headers({bool isJsonType = true}) async {
    final token = await getToken();
    final headers = <String, String>{};
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    if (isJsonType) {
      headers['Content-Type'] = 'application/json; charset=UTF-8';
    }
    return headers;
  }

  // Helper method to log responses
  void _logResponse(http.Response response, String action) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      logger.i("$action successful.");
    } else {
      logger.e("$action failed. Status code: ${response.statusCode}. Error: ${response.body}");
    }
  }
}