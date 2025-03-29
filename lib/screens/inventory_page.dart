import 'package:flutter/material.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 20),
          Text('Inventory', style: TextStyle(fontSize: 32, color: Colors.green)),
          SizedBox(height: 20),
          Text('This is the Inventory page', style: TextStyle(fontSize: 18)),
        ],
      ),
    );
  }
}
