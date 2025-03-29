import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 20),
          Text(
            'Food Hub',
            style: TextStyle(fontSize: 32, color: Colors.green),
          ),
          SizedBox(height: 20),
          Text('This is the Food Hub page', style: TextStyle(fontSize: 18)),
        ],
      ),
    );
  }
}
