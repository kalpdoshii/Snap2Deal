import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snap2deal_app/screens/home/home_screen.dart';
import '../../core/services/auth_service.dart';

class OtpScreen extends StatelessWidget {
  final String phone;
  OtpScreen({required this.phone, super.key});

  final otpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verify OTP")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Enter OTP",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final result =
                    await AuthService.verifyOtp(phone, otpController.text);

                if (result != null) {
                  final prefs = await SharedPreferences.getInstance();
                  prefs.setString("userId", result["user"]["_id"]);

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const HomeScreen(),
                    ),
                  );
                }
              },
              child: const Text("Verify"),
            ),
          ],
        ),
      ),
    );
  }
}
