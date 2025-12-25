import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Snap2Deal"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "Nearby Deals",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          Card(
            child: ListTile(
              title: const Text("Spice Route Restaurant"),
              subtitle: const Text("Buy 2 Get 1 Free"),
              trailing: ElevatedButton(
                onPressed: () {},
                child: const Text("Scan"),
              ),
            ),
          ),

          Card(
            child: ListTile(
              title: const Text("Beauty Retail"),
              subtitle: const Text("₹150 OFF on ₹500"),
              trailing: ElevatedButton(
                onPressed: () {},
                child: const Text("Scan"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
