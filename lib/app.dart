import 'package:flutter/material.dart';
import 'package:food_link/utils/theme/theme.dart';

class FoodLink extends StatelessWidget {
  const FoodLink({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.system,
      theme: FLAppTheme.lightTheme,
      darkTheme: FLAppTheme.darkTheme,
      home: Scaffold(
        body: Center(
          child: Text('Hello World'),
        ),
      ),
    );
  }
}