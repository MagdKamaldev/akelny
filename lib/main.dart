import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/splash_screen.dart';
import 'screens/signin_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/main_navigation_page.dart';
import 'screens/leftover_management_screen.dart';
import 'screens/chatbot_screen.dart'; // Import Chatbot Screen
import 'screens/edit_profile_screen.dart'; // Import Edit Profile Screen
String? token = "";
const int primaryColorValue = 0xFF2E7D32;
Map<int, Color> colorSwatch = {
  50: Color(0xFFE8F5E9),
  100: Color(0xFFC8E6C9),
  200: Color(0xFFA5D6A7),
  300: Color(0xFF81C784),
  400: Color(0xFF66BB6A),
  500: Color(primaryColorValue),
  600: Color(0xFF43A047),
  700: Color(0xFF388E3C),
  800: Color(0xFF2E7D32),
  900: Color(0xFF1B5E20),
};

final MaterialColor customGreen = MaterialColor(primaryColorValue, colorSwatch);
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  token =  prefs.getString('auth_token');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aklny',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: customGreen,
        primaryColor: const Color(0xFF2E7D32),
        scaffoldBackgroundColor: Colors.white,
        textTheme: GoogleFonts.latoTextTheme(
          Theme.of(context).textTheme,
        ).copyWith(
          displayLarge: GoogleFonts.lato(
            fontSize: 32.0,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          titleLarge: GoogleFonts.lato(
            fontSize: 18.0,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          bodyMedium: GoogleFonts.lato(
            fontSize: 16.0,
            color: Colors.black87,
          ),
          bodySmall: GoogleFonts.lato(
            fontSize: 14.0,
            color: Colors.grey,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2E7D32),
            foregroundColor: Colors.white,
            textStyle: GoogleFonts.lato(
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
        ),
        iconTheme: const IconThemeData(
          color: Color(0xFF2E7D32),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade100,
          contentPadding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide.none,
          ),
          hintStyle: GoogleFonts.lato(
            fontSize: 14.0,
            color: Colors.grey,
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/signin': (context) => const SignInScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/mainNavigation': (context) => const MainNavigationPage(), // Main navigation hub
        '/leftoverManagement': (context) => const LeftoverManagementScreen(), // Leftover Management
        '/chatbot': (context) => WebSocketTestScreen(), // Chatbot Screen
        '/editProfile': (context) => EditProfileScreen(
          userData: {
            'username': 'JohnDoe',
            'email': 'johndoe@example.com',
            'firstName': 'John',
            'lastName': 'Doe',
            'phoneNumber': '123456789',
            'address': '123 Street, City',
            'dietaryPreferences': 'Vegetarian',
            'allergies': 'None',
            'cookingSkillLevel': 'Intermediate',
            'dateOfBirth': '1990-01-01',
          },
        ), // Pass sample user data
      },
    );
  }
}
