import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graduation/main.dart';
import '../core/auth_service.dart'; // Import the AuthService

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const EditProfileScreen({super.key, required this.userData});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController usernameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController addressController;
  late TextEditingController dietaryPreferencesController;
  late TextEditingController allergiesController;
  late TextEditingController cookingSkillLevelController;

  final AuthService authService = AuthService(); // Initialize AuthService
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    usernameController = TextEditingController(text: widget.userData['username']);
    emailController = TextEditingController(text: widget.userData['email']);
    phoneController = TextEditingController(text: widget.userData['phone_number']);
    addressController = TextEditingController(text: widget.userData['address']);
    dietaryPreferencesController =
        TextEditingController(text: widget.userData['dietary_preferences']);
    allergiesController = TextEditingController(text: widget.userData['allergies']);
    cookingSkillLevelController =
        TextEditingController(text: widget.userData['cooking_skill_level']);
  }

  // Save updated data to the backend
  Future<void> _saveChanges() async {
    setState(() {
      isLoading = true;
    });

    final updatedData = {
      'username': usernameController.text,
      'email': emailController.text,
      'phone_number': phoneController.text,
      'address': addressController.text,
      'dietary_preferences': dietaryPreferencesController.text,
      'allergies': allergiesController.text,
      'cooking_skill_level': cookingSkillLevelController.text,
    };

   
      await authService.updateUserData(updatedData,context);
      setState(() {
        isLoading = false;
      });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField('UserName', usernameController),
            const SizedBox(height: 10),
            _buildTextField('Email', emailController, keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 10),
            _buildTextField('Phone', phoneController, keyboardType: TextInputType.phone),
            const SizedBox(height: 10),
            _buildTextField('Address', addressController, maxLines: 3),
            const SizedBox(height: 10),
            _buildTextField('Dietary Preferences', dietaryPreferencesController, maxLines: 3),
            const SizedBox(height: 10),
            _buildTextField('Allergies', allergiesController, maxLines: 3),
            const SizedBox(height: 10),
            _buildTextField('Cooking Skill Level', cookingSkillLevelController),
            const SizedBox(height: 20),
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
              onPressed: _saveChanges,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
         hoverColor: customGreen,
        labelText: label,
        border: const OutlineInputBorder(),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: customGreen, width: 2.0),
      ),
      ),
    );
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    dietaryPreferencesController.dispose();
    allergiesController.dispose();
    cookingSkillLevelController.dispose();
    super.dispose();
  }
}
