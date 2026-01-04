import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:snap2deal_app/screens/main/main_screen.dart';
import 'package:snap2deal_app/core/services/auth_service.dart'; // adjust import

class OtpScreenPremium extends StatefulWidget {
  final String phone;
  final String name;
  final String? email;

  const OtpScreenPremium({
    super.key,
    required this.phone,
    required this.name,
    this.email,
  });

  @override
  State<OtpScreenPremium> createState() => _OtpScreenPremiumState();
}

class _OtpScreenPremiumState extends State<OtpScreenPremium> {
  final List<TextEditingController> controllers =
      List.generate(6, (_) => TextEditingController());

  final List<FocusNode> focusNodes =
      List.generate(6, (_) => FocusNode());

  String get otp =>
      controllers.map((c) => c.text).join();

  @override
  void dispose() {
    for (final c in controllers) {
      c.dispose();
    }
    for (final f in focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🌄 BACKGROUND
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

          // ✨ BLUR
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(color: Colors.black.withOpacity(0.1)),
          ),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 40),

                const Text(
                  "Membership Adda",
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Exclusive offline deals near you",
                  style: TextStyle(color: Colors.white70),
                ),

                const SizedBox(height: 40),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2ECE6),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "We've sent a 6-digit OTP to",
                          style: TextStyle(color: Colors.black54),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "+91 ${widget.phone}",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold),
                        ),

                        const SizedBox(height: 28),
                        const Text(
                          "Enter OTP",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 12),

                        // 🔢 OTP BOXES
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: List.generate(6, (i) {
                            return SizedBox(
                              width: 45,
                              height: 55,
                              child: AnimatedContainer(
                                duration:
                                    const Duration(milliseconds: 200),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: focusNodes[i].hasFocus
                                          ? Colors.orange
                                              .withOpacity(0.4)
                                          : Colors.black12,
                                      blurRadius: 8,
                                    )
                                  ],
                                ),
                                child: TextField(
                                  controller: controllers[i],
                                  focusNode: focusNodes[i],
                                  maxLength: 1,
                                  keyboardType:
                                      TextInputType.number,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  decoration: const InputDecoration(
                                    counterText: "",
                                    border: InputBorder.none,
                                  ),
                                  onChanged: (v) {
                                    if (v.isNotEmpty && i < 5) {
                                      FocusScope.of(context)
                                          .requestFocus(
                                              focusNodes[i + 1]);
                                    }
                                  },
                                ),
                              ),
                            );
                          }),
                        ),

                        const SizedBox(height: 30),

                        // 🔥 VERIFY BUTTON
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
                              borderRadius:
                                  BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.orange
                                      .withOpacity(0.4),
                                  blurRadius: 18,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Colors.transparent,
                                shadowColor:
                                    Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(30),
                                ),
                              ),
                              onPressed: () async {
                                if (otp.length != 6) {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            "Enter 6-digit OTP")),
                                  );
                                  return;
                                }

                                final result =
                                    await AuthService.verifyOtp(
                                  widget.phone,
                                  otp,
                                  widget.name,
                                  widget.email,
                                );

                                if (context.mounted) {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            const MainScreen()),
                                  );
                                }
                              },
                              child: const Text(
                                "Verify & Continue →",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        Center(
                          child: TextButton(
                            onPressed: () =>
                                Navigator.pop(context),
                            child: const Text(
                              "Change phone number",
                              style:
                                  TextStyle(color: Colors.black54),
                            ),
                          ),
                        ),
                      ],
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
}
