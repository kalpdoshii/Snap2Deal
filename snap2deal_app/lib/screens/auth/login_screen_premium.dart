import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:snap2deal_app/core/services/auth_service.dart';
import 'package:snap2deal_app/screens/auth/otp_screen_premium.dart';

class LoginScreenPremium extends StatelessWidget {
  LoginScreenPremium({super.key});

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🌄 BACKGROUND IMAGE / GRADIENT
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF7A3E00),
                  Color(0xFF2B1B0E),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // ✨ BLUR OVERLAY
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              color: Colors.black.withOpacity(0.1),
            ),
          ),

          // 🧾 CONTENT
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 40),

                // 🔥 BRAND
                const Text(
                  "Snap2Deal",
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Exclusive offline deals near you",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 40),

                // 🪟 GLASS CARD
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2ECE6),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label("Full Name *"),
                          _inputField(
                            controller: nameController,
                            hint: "Enter your name",
                            icon: Icons.person_outline,
                          ),

                          const SizedBox(height: 16),

                          _label("Email (Optional)"),
                          _inputField(
                            controller: emailController,
                            hint: "Enter email address",
                            icon: Icons.mail_outline,
                          ),

                          const SizedBox(height: 16),

                          _label("Mobile Number *"),
                          _inputField(
                            controller: phoneController,
                            hint: "+91 Enter mobile number",
                            icon: Icons.phone_outlined,
                            keyboard: TextInputType.phone,
                          ),

                          const SizedBox(height: 28),

                          // 🔥 SEND OTP BUTTON
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFF9800),
                                    Color(0xFFE53935),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.orange.withOpacity(0.4),
                                    blurRadius: 18,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                onPressed: () async {
  final name = nameController.text.trim();
  final phone = phoneController.text.trim();
  final email = emailController.text.trim();

  // 🔴 VALIDATION
  if (name.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Name is required")),
    );
    return;
  }

  if (!RegExp(r'^[0-9]{10}$').hasMatch(phone)) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Enter valid 10-digit phone number")),
    );
    return;
  }

  if (email.isNotEmpty &&
      !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Enter valid email")),
    );
    return;
  }

  // 🔁 CALL YOUR EXISTING SEND OTP API
  final success = await AuthService.sendOtp(phone);

  if (success && context.mounted) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OtpScreenPremium(
          phone: phone,
          name: name,
          email: email.isEmpty ? null : email,
        ),
      ),
    );
  }
},

                                child: const Text(
                                  "Send OTP  →",
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // 📜 FOOTER LINKS
                          const Center(
                            child: Text(
                              "Terms of Service     Privacy Policy",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black45,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🔤 LABEL
  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  // ✏ INPUT FIELD
  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboard = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.black45),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
