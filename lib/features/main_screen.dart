import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'home/home_view.dart';
import 'inventory/inventory_view.dart';
import 'scan/scan_view.dart';
import 'foodhub/foodhub_view.dart';
import 'profile/profile_view.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    SearchPage(),
    FavoritesPage(),
    NotificationsPage(),
    ProfilePage(),
  ];

  final _navBarItems = [
    SalomonBottomBarItem(
      icon: const Icon(Icons.home),
      title: const Text("Home"),
      selectedColor: Colors.green,
    ),
    SalomonBottomBarItem(
      icon: const Icon(Icons.inventory_2_outlined),
      title: const Text("Inventory"),
      selectedColor: Colors.green,
    ),
    SalomonBottomBarItem(
      icon: const Icon(Icons.camera_alt_outlined),
      title: const Text("Scan"),
      selectedColor: Colors.green,
    ),
    SalomonBottomBarItem(
      icon: const Icon(Icons.share),
      title: const Text("Food Hub"),
      selectedColor: Colors.green,
    ),
    SalomonBottomBarItem(
      icon: const Icon(Icons.person),
      title: const Text("Profile"),
      selectedColor: Colors.green,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Link'),
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        color: Colors.grey[200], // Change this to your preferred color
        child: SalomonBottomBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: _navBarItems,
          // Optional customization
          itemShape: const StadiumBorder(),
          itemPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          margin: const EdgeInsets.all(20),
          curve: Curves.easeOutQuint,
        ),
      ),
    );
  }
}