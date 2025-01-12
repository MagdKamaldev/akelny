// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

const String baseUrl = 'http://0.0.0.0:8000';
// 192.168.1.9

class AuthService {
  static const String signUpUrl = '$baseUrl/api/signup/';
  static const String signInUrl = '$baseUrl/api/signin/';
  static const String userProfileUrl = '$baseUrl/api/user/';
  static const String updateUserProfileUrl = '$baseUrl/api/user/update/';
  static const String saveRecipeUrl = '$baseUrl/api/recipes/';
  static const String recommendedRecipesUrl = '$baseUrl/api/recommendations/';
  static const String getSavedRecipesUrl = '$baseUrl/api/saved-recipes/';
  static const String unsaveRecipeUrl = '$baseUrl/api/unsave-recipe/';
  static const String imageUploadUrl = '$baseUrl/api/image-upload/';
  static const String chatbotUrl = '$baseUrl/api/chatbot/';
  static const String recipesUrl = '$baseUrl/api/recipes/';  // For fetching all recipes

  final logger = Logger();

  Future<void> signUp(String username, String password, {String? email, Map<String, String>? additionalData}) async {
    final headers = await _headers();
    final response = await http.post(
      Uri.parse(signUpUrl),
      headers: headers,
      body: jsonEncode({
        'username': username,
        'password': password,
        'email': email,
        if (additionalData != null) ...additionalData,
      }),
    );
    _logResponse(response, 'Sign-Up');
  }

  Future<void> signIn(String usernameOrEmail, String password,BuildContext context) async {
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

  Future<void> updateUserData(Map<String, dynamic> updatedData,BuildContext context) async {
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

  Future<List<Map<String, dynamic>>> getRecommendedRecipes() async{
    final token = await getToken();
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

  Future<void> saveRecipe(Map<String, dynamic> recipeData, File imageFile) async {
    final token = await getToken();
    final request = http.MultipartRequest('POST', Uri.parse(saveRecipeUrl))
      ..headers['Authorization'] = 'Bearer $token'
      ..fields.addAll(recipeData.map((key, value) => MapEntry(key, value.toString())))
      ..files.add(await http.MultipartFile.fromPath('image', imageFile.path));
    final response = await request.send();
    if (response.statusCode == 201) {
      logger.i("Recipe saved successfully.");
    } else {
      logger.e("Failed to save recipe. Status code: ${response.statusCode}");
      throw Exception("Failed to save recipe.");
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

  Future<void> unsaveRecipe(String recipeId) async {
    final token = await getToken();
    final response = await http.delete(
      Uri.parse('$unsaveRecipeUrl$recipeId/'),
      headers: {'Authorization': 'Bearer $token'},
    );
    _logResponse(response, 'Unsave Recipe');
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

  Future<String> sendMessageToChatbot(String message) async {
    final token = await getToken();
    final headers = await _headers();
    final response = await http.post(
      Uri.parse(chatbotUrl),
      headers: headers,
      body: jsonEncode({'message': message}),
    );
    if (_handleResponse(response, 'Chatbot Interaction')) {
      return jsonDecode(response.body)['response'];
    }
    throw Exception("Failed to communicate with the chatbot.");
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

  // New method to fetch all recipes
  Future<List<Map<String, dynamic>>> fetchRecipes() async {
    final response = await http.get(Uri.parse(recipesUrl),);
    if (_handleResponse(response, 'Fetch Recipes')) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    }
    return [];
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
