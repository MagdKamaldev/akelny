import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:graduation/main.dart';
import '../core/auth_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  // Additional controllers
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController dietaryPreferencesController =
      TextEditingController();
  final TextEditingController allergiesController = TextEditingController();
  final TextEditingController cookingSkillLevelController =
      TextEditingController();
  final TextEditingController dateOfBirthController = TextEditingController();

  final AuthService authService = AuthService();
  bool isLoading = false;
  String? passwordError; // Holds the error message for password mismatch

  @override
  void initState() {
    super.initState();

    // Add listener to check password confirmation in real-time
    confirmPasswordController.addListener(() {
      if (passwordController.text != confirmPasswordController.text) {
        setState(() {
          passwordError = "Passwords do not match";
        });
      } else {
        setState(() {
          passwordError = null;
        });
      }
    });
  }

  Future<void> signUp() async {
    if (_validateInputs()) {
      setState(() {
        isLoading = true;
      });

      try {
        await authService.signUp(
          usernameController.text,
          passwordController.text,
          confirmPasswordController.text,
          email: emailController.text.isNotEmpty ? emailController.text : null,
          additionalData: {
            'first_name': firstNameController.text,
            'last_name': lastNameController.text,
            'phone_number': phoneNumberController.text,
            'address': addressController.text,
            'dietary_preferences': dietaryPreferencesController.text,
            'allergies': allergiesController.text,
            'cooking_skill_level': cookingSkillLevelController.text,
            'date_of_birth': dateOfBirthController.text,
          },
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Account created successfully! Please sign in.')),
        );

        Navigator.pushReplacementNamed(context, '/signin');
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  bool _validateInputs() {
    if (usernameController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return false;
    }
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                const SizedBox(height: 80),
                Center(
                  child: Hero(
                    tag: 'app-logo',
                    child: Image.asset(
                      'assets/logo.png',
                      width: 100,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Create an Account',
                  style: GoogleFonts.lato(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),

                // Username
                _buildTextField('Username', usernameController),
                const SizedBox(height: 10),

                // Email
                _buildTextField('Email', emailController),
                const SizedBox(height: 10),

                // Password
                _buildTextField('Password', passwordController,
                    obscureText: true),
                const SizedBox(height: 10),

                // Confirm Password
                _buildTextField(
                  'Confirm Password',
                  confirmPasswordController,
                  obscureText: true,
                  errorText:
                      passwordError, // Show error if passwords do not match
                ),
                const SizedBox(height: 10),

                // Additional fields
                _buildTextField('First Name', firstNameController),
                const SizedBox(height: 10),
                _buildTextField('Last Name', lastNameController),
                const SizedBox(height: 10),
                _buildTextField('Phone Number', phoneNumberController,
                    keyboardType: TextInputType.phone),
                const SizedBox(height: 10),
                _buildTextField('Address', addressController, maxLines: 3),
                const SizedBox(height: 10),
                _buildTextField(
                    'Dietary Preferences', dietaryPreferencesController,
                    maxLines: 3),
                const SizedBox(height: 10),
                _buildTextField('Allergies', allergiesController, maxLines: 3),
                const SizedBox(height: 10),
                _buildTextField(
                    'Cooking Skill Level', cookingSkillLevelController),
                const SizedBox(height: 10),
                _buildTextField('Date of Birth', dateOfBirthController,
                    readOnly: true, onTap: () async {
                  final DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (pickedDate != null) {
                    dateOfBirthController.text =
                        pickedDate.toLocal().toString().split(' ')[0];
                  }
                }),
                const SizedBox(height: 20),

                // Sign-Up Button
                ElevatedButton(
                  onPressed: isLoading ? null : signUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Sign Up'),
                ),
                const SizedBox(height: 20),

                // Navigation to Sign-In Screen
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/signin');
                  },
                  child: Text(
                    'Already have an account? Sign In',
                    style: GoogleFonts.lato(color: const Color(0xFF2E7D32)),
                  ),
                ),
              ],
            ),
          ),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
    String? errorText,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLines: maxLines,
      readOnly: readOnly,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        errorText: errorText, // Display error if provided
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
    passwordController.dispose();
    confirmPasswordController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    phoneNumberController.dispose();
    addressController.dispose();
    dietaryPreferencesController.dispose();
    allergiesController.dispose();
    cookingSkillLevelController.dispose();
    dateOfBirthController.dispose();
    super.dispose();
  }
}
