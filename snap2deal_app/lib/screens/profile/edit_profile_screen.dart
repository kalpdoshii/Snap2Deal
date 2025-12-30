import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/red_theme.dart';
import '../../core/services/user_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  String phone = "";
  bool loading = false;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      nameController.text = prefs.getString("userName") ?? "";
      emailController.text = prefs.getString("userEmail") ?? "";
      phone = prefs.getString("userPhone") ?? "";
    });
  }

  Future<void> saveProfile() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Name is required")),
      );
      return;
    }

    setState(() => loading = true);

    final success = await UserService.updateProfile(
      name: name,
      email: email.isEmpty ? null : email,
    );

    setState(() => loading = false);

    if (success && context.mounted) {
      final prefs = await SharedPreferences.getInstance();
      prefs.setString("userName", name);

      if (email.isNotEmpty) {
        prefs.setString("userEmail", email);
      } else {
        prefs.remove("userEmail");
      }

      Navigator.pop(context); // go back to profile
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update profile")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: RedTheme.primaryRed,
        title: const Text("Edit Profile"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 👤 NAME
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Full Name *",
              ),
            ),

            const SizedBox(height: 16),

            // 📧 EMAIL
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: "Email (Optional)",
              ),
            ),

            const SizedBox(height: 16),

            // 📱 PHONE (READ ONLY)
            TextField(
              enabled: false,
              decoration: InputDecoration(
                labelText: "Mobile Number",
                hintText: phone,
              ),
            ),

            const Spacer(),

            // 🔴 SAVE BUTTON
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: RedTheme.primaryRed,
                ),
                onPressed: loading ? null : saveProfile,
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Save Changes",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
