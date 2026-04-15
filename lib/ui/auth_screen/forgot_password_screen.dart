import 'package:country_code_picker/country_code_picker.dart';
import 'package:customer/controller/forgot_password_controller.dart';
import 'package:customer/themes/app_colors.dart';
import 'package:customer/ui/auth_screen/login_screen.dart';
import 'package:customer/utils/DarkThemeProvider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _backgroundController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final bool isDark = themeChange.getThem();

    return GetBuilder<ForgotPasswordController>(
        init: ForgotPasswordController(),
        builder: (controller) {
          return Scaffold(
            backgroundColor: isDark
                ? AppColors.darkBackground
                : AppColors.moroccoBackground,
            body: Stack(
              children: [
         /*       Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _backgroundController,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: ModernMoroccanPainter(
                          scrollOffset: _backgroundController.value,
                          isDark: isDark,
                        ),
                      );
                    },
                  ),
                ),*/

                // Back Button
             /*   SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 24.0, top: 20),
                    child: IconButton(
                      onPressed: () => Get.back(),
                      icon: Icon(
                        Icons.arrow_back_ios_new,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                ),*/

                // Main Content
                SafeArea(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 60),
                            ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [
                                  AppColors.moroccoRed,
                                  AppColors.moroccoGreen
                                ],
                              ).createShader(bounds),
                              child: Text(
                                "Forgot Password".tr,
                                style: GoogleFonts.outfit(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.5,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Set your new password in minutes".tr,
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: isDark ? Colors.white60 : Colors.black45,
                              ),
                            ),
                            const SizedBox(height: 48),

                            // Glass Card
                            _buildGlassCard(context, isDark, controller),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  Widget _buildGlassCard(BuildContext context, bool isDark,
      ForgotPasswordController controller) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.black.withOpacity(0.05),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Obx(() {
        if (!controller.isOtpSent.value) {
          // STEP 1: Enter Phone
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Phone Number".tr,
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppColors.moroccoText,
                ),
              ),
              const SizedBox(height: 20),
              _buildPhoneField(controller, isDark),
              const SizedBox(height: 32),
              _buildPrimaryButton(
                "Send OTP".tr,
                () {
                  controller.sendOtp();
                },
              ),
            ],
          );
        } else if (!controller.isOtpVerified.value) {
          // STEP 2: Verify OTP
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Verify OTP".tr,
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppColors.moroccoText,
                ),
              ),
              const SizedBox(height: 20),
              PinCodeTextField(
                length: 6,
                appContext: context,
                keyboardType: TextInputType.number,
                controller: controller.otpController.value,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(15),
                  fieldHeight: 50,
                  fieldWidth: 40,
                  inactiveColor:
                      isDark ? Colors.white12 : Colors.black.withOpacity(0.05),
                  selectedColor: AppColors.moroccoRed,
                  activeColor: AppColors.moroccoGreen,
                  inactiveFillColor:
                      isDark ? Colors.black26 : Colors.grey.withOpacity(0.05),
                  selectedFillColor: isDark ? Colors.white10 : Colors.white,
                  activeFillColor: isDark ? Colors.white10 : Colors.white,
                ),
                enableActiveFill: true,
                cursorColor: AppColors.moroccoRed,
                textStyle: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                onChanged: (value) {},
              ),
              const SizedBox(height: 32),
              _buildPrimaryButton(
                "Verify Code".tr,
                () {
                  controller.verifyOtp();
                },
              ),
              const SizedBox(height: 12),
             /* TextButton(
                  onPressed: () {
                    controller.isOtpSent.value = false;
                  },
                  child: Text("Change phone number?".tr,
                      style:
                          GoogleFonts.outfit(color: AppColors.moroccoGreen))),*/
            ],
          );
        } else {
          // STEP 3: Reset Password
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "New Password".tr,
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppColors.moroccoText,
                ),
              ),
              const SizedBox(height: 20),
              _buildTextField(controller.newPasswordController.value,
                  "New Password".tr, isDark,
                  isPassword: true),
              const SizedBox(height: 16),
              _buildTextField(controller.confirmPasswordController.value,
                  "Confirm Password".tr, isDark,
                  isPassword: true),
              const SizedBox(height: 32),
              _buildPrimaryButton(
                "Reset Password".tr,
                () {
                  controller.resetPassword();
                },
              ),
            ],
          );
        }
      }),
    );
  }

  Widget _buildPhoneField(ForgotPasswordController controller, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.black26 : Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color:
              isDark ? Colors.white10 : AppColors.moroccoGreen.withOpacity(0.5),
        ),
      ),
      child: TextFormField(
        keyboardType: TextInputType.number,
        controller: controller.phoneNumberController.value,
        style: GoogleFonts.outfit(
            color: isDark ? Colors.white : AppColors.moroccoGreen),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
          prefixIcon: CountryCodePicker(
            onChanged: (value) {
              controller.countryCode.value = value.dialCode.toString();
            },
            dialogBackgroundColor: isDark
                ? AppColors.moroccoGreen.withOpacity(0.6)
                : AppColors.background,
            initialSelection: controller.countryCode.value,
            textStyle: GoogleFonts.outfit(
              color: isDark ? Colors.white70 : AppColors.moroccoGreen,
              fontWeight: FontWeight.w600,
            ),
            showFlagMain: true,
            flagDecoration:
                BoxDecoration(borderRadius: BorderRadius.circular(4)),
          ),
          border: InputBorder.none,
          hintText: "6/7 XX XX XX XX".tr,
          hintStyle: GoogleFonts.outfit(
              color: isDark ? Colors.white30 : Colors.black26),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String hint, bool isDark,
      {bool isPassword = false, bool isNumber = false}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.black26 : Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color:
              isDark ? Colors.white10 : AppColors.moroccoGreen.withOpacity(0.5),
        ),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: GoogleFonts.outfit(
            color: isDark ? Colors.white : AppColors.moroccoGreen),
        decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
          border: InputBorder.none,
          hintText: hint,
          hintStyle: GoogleFonts.outfit(
              color: isDark ? Colors.white30 : Colors.black26),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton(String title, VoidCallback onTap) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.moroccoRed.withOpacity(0.9),
            AppColors.moroccoRed.withOpacity(0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: Text(
          title,
          style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
