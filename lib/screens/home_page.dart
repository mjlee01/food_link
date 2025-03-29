import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 20),
          Text('Home', style: TextStyle(fontSize: 32, color: Colors.green)),
          SizedBox(height: 20),
          Text('This is the Home page', style: TextStyle(fontSize: 18)),
        ],
      ),
    );
  }
}
