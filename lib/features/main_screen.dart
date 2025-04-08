import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'Recipie/recipe_view.dart' show RecipePage;
import 'home/home_view.dart';
import 'inventory/inventory_view.dart';
import 'scan/scan_view.dart';
import 'foodhub/foodhub_view.dart';
import 'package:food_link/utils/constants/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';
import 'profile/profile_view.dart';
import 'foodhub/chat/chat_list.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    InventoryPage(),
    ScanPage(),
    FoodHubPage(),
    // NotificationsPage(),
    RecipePage(),
    ScanPage(),
    FoodHubPage(),
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
      icon: const Icon(Icons.food_bank_outlined),
      title: const Text("Recipes"),
      selectedColor: Colors.green,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Link', style: TextStyle(color: FLColors.white)),
        backgroundColor: FLColors.primary,
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.notifications, color: FLColors.white),
          //   onPressed: () {},
          // ),
          IconButton(
            icon: const Icon(Icons.chat, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChatsListPage()),
              );
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.person, color: FLColors.white),
            onSelected: (String result) async {
              if (result == 'logout') {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: 'logout',
                  child: Row(
                    spacing: 8,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,

                    children: [
                      const Icon(Icons.logout, color: FLColors.error),
                      const Text(
                        'Logout',
                        style: TextStyle(
                          color: FLColors.error,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ];
            },
            offset: Offset(0, 40),
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
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
