import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../app.dart';
import '../login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  static Future<void> signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();

      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('rememberMe', false);
      } catch (prefError) {
        print('Error with SharedPreferences during logout: $prefError');
      }

      // Navigate back to login screen
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error signing out: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 20),
          Text('Profile', style: TextStyle(fontSize: 32, color: Colors.green)),
          SizedBox(height: 20),
          Text('This is the Home page', style: TextStyle(fontSize: 18)),
          SizedBox(height: 40),

          ElevatedButton(
            onPressed: () {
              signOut(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red, // Button color
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'Log Out',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
