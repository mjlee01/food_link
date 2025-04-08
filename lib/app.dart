import 'package:flutter/material.dart';
import 'package:food_link/utils/theme/theme.dart';
import 'features/login_page.dart';
import 'features/main_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FoodLink extends StatefulWidget {
  const FoodLink({super.key});

  @override
  State<FoodLink> createState() => _FoodLinkState();
}

class _FoodLinkState extends State<FoodLink> {
  bool _isLoading = true;
  Widget _initialScreen = LoginPage();

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      bool rememberMe = prefs.getBool('rememberMe') ?? false;

      if (rememberMe && FirebaseAuth.instance.currentUser != null) {
        _initialScreen = MainScreen();
      }
    } catch (e) {
      print('Error checking auth status: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: FLAppTheme.lightTheme,
      darkTheme: FLAppTheme.darkTheme,
      home:
          _isLoading
              ? Scaffold(body: Center(child: CircularProgressIndicator()))
              : _initialScreen,
    );
  }
}
