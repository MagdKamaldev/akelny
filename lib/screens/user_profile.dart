import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/auth_service.dart';
import 'edit_profile_screen.dart';

class UserProfilePage extends StatefulWidget {
  final Map<String, String>? userData;
  final Function(Map<String, String>) onEditProfile;

  const UserProfilePage({
    super.key,
    required this.userData,
    required this.onEditProfile,
  });

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final AuthService authService = AuthService();
  late Future<bool> _fetchUserDataFuture;
  Map<String, dynamic>? userData;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchUserDataFuture = fetchUserData(); // Cache the future
  }

  Future<bool> fetchUserData() async {
    try {
      final data = await authService.getUserData();
      setState(() {
        userData = data;
      });
      return true;
    } catch (error) {
      setState(() {
        errorMessage = 'Failed to fetch user data. Please try again.';
      });
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
        future: _fetchUserDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || errorMessage != null) {
            return buildErrorWidget(context);
          } else {
            return buildProfileWidget(context);
          }
        },
      
    );
  }

  Widget buildProfileWidget(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Profile Picture and Welcome
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage: userData!['profile_picture'] != null
                      ? NetworkImage(userData!['profile_picture']!)
                      : const AssetImage('assets/profile.png') as ImageProvider,
                ),
                const SizedBox(height: 16),
                Text(
                  'Welcome, ${userData!['username']}!',
                  style: GoogleFonts.lato(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  userData!['email'] ?? '',
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // User Information Section
          Card(
            color: const Color(0xFFF1F8E9),
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Personal Information',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(),
                  for (var field in [
                    {'title': 'Phone Number', 'key': 'phone_number'},
                    {'title': 'Address', 'key': 'address'},
                    {'title': 'Dietary Preferences', 'key': 'dietary_preferences'},
                    {'title': 'Allergies', 'key': 'allergies'},
                    {'title': 'Cooking Skill Level', 'key': 'cooking_skill_level'},
                    {'title': 'Date of Birth', 'key': 'date_of_birth'},
                  ])
                    _buildInfoRow(field['title']!, userData![field['key']!]),
                ],
              ),
            ),
          ),

          // Update Profile Button
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () async {
              final updatedData = await Navigator.push<Map<String, String>>(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfileScreen(userData: userData!),
                ),
              );
              if (updatedData != null) {
                widget.onEditProfile(updatedData);
              }
            },
            icon: const Icon(Icons.edit,color: Colors.grey,),
            label: const Text('Edit Profile'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title:',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value ?? 'Not available',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildErrorWidget(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[400],
          ),
          const SizedBox(height: 16),
          Text(
            errorMessage ?? 'An unknown error occurred.',
            style: GoogleFonts.lato(
              fontSize: 18,
              color: Colors.red[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _fetchUserDataFuture = fetchUserData();
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
