import 'package:customer/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

class DummayScreen extends StatelessWidget {
  const DummayScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Circle with Sparkles
              Center(
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.moroccoRed.withOpacity(0.1),
                  ),
                  child: Center(
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFE94D43), // Vivid Red
                            Color(0xFFA62A22), // Deep Red
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x40A62A22),
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          )
                        ],
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        color: Colors.white,
                        size: 50,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 50),

              // Title
              Text(
                "Coming Soon".tr,
                style: GoogleFonts.outfit(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2D2D2D),
                ),
              ),
              const SizedBox(height: 16),

              // Subtitle
              Text(
                "We're crafting something amazing for you.\nThis feature will be live soon!"
                    .tr,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 60),

              // Button
              SizedBox(
                width: 180,
                child: OutlinedButton(
                  onPressed: () {
                    Get.back();
                  },
                  style: OutlinedButton.styleFrom(
                    side:
                        const BorderSide(color: Color(0xFFA62A22), width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    "Stay Tuned".tr,
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFA62A22),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
