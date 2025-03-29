import 'package:flutter/material.dart';

class ScanPage extends StatelessWidget {
  const ScanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 20),
          Text('Scan', style: TextStyle(fontSize: 32, color: Colors.green)),
          SizedBox(height: 20),
          Text('This is the Scan page', style: TextStyle(fontSize: 18)),
        ],
      ),
    );
  }
}
