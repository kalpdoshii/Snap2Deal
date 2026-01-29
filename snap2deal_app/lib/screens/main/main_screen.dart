import 'package:flutter/material.dart';
import 'package:snap2deal_app/screens/home/home_screen_premium.dart';
import 'package:snap2deal_app/screens/home/vendor_premium_screen.dart';
import 'package:snap2deal_app/screens/profile/profile_screen_premium.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  String vendorCategory = "All";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeScreenPremium(
            onCategoryTap: (category) {
              setState(() {
                vendorCategory = category;
                _currentIndex = 1; // switch to Vendors tab
              });
            },
          ),
          VendorsScreen(initialCategory: vendorCategory),
          const ProfileScreenPremium(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: "Vendors"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
