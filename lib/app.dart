import 'package:flutter/material.dart';
import 'package:food_link/utils/theme/theme.dart';
import 'features/login_page.dart';

class FoodLink extends StatelessWidget {
  const FoodLink({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: FLAppTheme.lightTheme,
      darkTheme: FLAppTheme.darkTheme,
      // home: const MainScreen(),
      home: LoginPage(),
    );
  }
}
