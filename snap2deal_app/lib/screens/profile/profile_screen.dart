import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.deepPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Gold Member",
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text("Active • Expires in 23 days"),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Savings
          Card(
            child: ListTile(
              leading: const Icon(Icons.savings),
              title: const Text("Your Savings"),
              subtitle: const Text("₹1,450 saved"),
            ),
          ),

          // History
          Card(
            child: ListTile(
              leading: const Icon(Icons.history),
              title: const Text("Redemption History"),
              onTap: () {
                // Next step: history list
              },
            ),
          ),

          // Logout
          Card(
            child: ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();

                Navigator.popUntil(context, (route) => route.isFirst);
              },
            ),
          ),
        ],
      ),
    );
  }
}
