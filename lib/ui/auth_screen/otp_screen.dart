import 'dart:math' as math;
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/controller/otp_controller.dart';
import 'package:customer/model/user_model.dart';
import 'package:customer/themes/app_colors.dart';
import 'package:customer/ui/auth_screen/information_screen.dart';
import 'package:customer/ui/auth_screen/dummay_screen.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../dashboard_screen.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX<OtpController>(
        init: OtpController(),
        builder: (controller) {
          return Scaffold(
            backgroundColor: AppColors.moroccoBackground,
            body: Stack(
              children: [
                // Moroccan Pattern Background
                Positioned.fill(
                  child: CustomPaint(
                    painter: MoroccanPatternPainter(),
                  ),
                ),
                SafeArea(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        // Logo
                        Hero(
                          tag: 'app_logo',
                          child: Image.asset(
                            "assets/images/splash_image.png",
                            width: 170,
                            fit: BoxFit.contain,
                          ),
                        ),

                        // Verify OTP Text
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [
                              AppColors.moroccoRed,
                              AppColors.moroccoGreen
                            ],
                          ).createShader(bounds),
                          child: Text(
                            "Verify OTP".tr,
                            style: GoogleFonts.outfit(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Text.rich(
                            textAlign: TextAlign.center,
                            TextSpan(
                              text: "Enter the code sent to\n".tr,
                              style: GoogleFonts.outfit(
                                color: Colors.grey.shade600,
                                fontSize: 16,
                              ),
                              children: [
                                TextSpan(
                                  text: controller.countryCode.value +
                                      controller.phoneNumber.value,
                                  style: GoogleFonts.poppins(
                                    color: AppColors.moroccoRed,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Main Card
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 32),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(40),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                            border: Border.all(
                                color: AppColors.moroccoGreen.withOpacity(0.1)),
                          ),
                          child: Column(
                            children: [
                              // OTP Input
                              PinCodeTextField(
                                length: 6,
                                appContext: context,
                                keyboardType: TextInputType.phone,
                                pinTheme: PinTheme(
                                  fieldHeight: 45,
                                  fieldWidth: 40,
                                  activeColor:
                                      AppColors.moroccoGreen.withOpacity(0.2),
                                  selectedColor: AppColors.moroccoRed,
                                  inactiveColor: Colors.grey.shade200,
                                  activeFillColor: Colors.white,
                                  inactiveFillColor: Colors.grey.shade50,
                                  selectedFillColor: Colors.white,
                                  shape: PinCodeFieldShape.box,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                enableActiveFill: true,
                                cursorColor: AppColors.moroccoRed,
                                textStyle: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.moroccoGreen,
                                ),
                                controller: controller.otpController,
                                onCompleted: (v) async {},
                                onChanged: (value) {},
                              ),
                              const SizedBox(height: 40),

                              // Verify OTP Button
                              SizedBox(
                                width: double.infinity,
                                height: 55,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    if (controller
                                            .otpController.value.text.length ==
                                        6) {
                                      ShowToastDialog.showLoader(
                                          "Verify OTP".tr);

                                      PhoneAuthCredential credential =
                                          PhoneAuthProvider.credential(
                                              verificationId: controller
                                                  .verificationId.value,
                                              smsCode: controller
                                                  .otpController.value.text);
                                      await FirebaseAuth.instance
                                          .signInWithCredential(credential)
                                          .then((value) async {
                                        if (value
                                            .additionalUserInfo!.isNewUser) {
                                          UserModel userModel = UserModel();
                                          userModel.id = value.user!.uid;
                                          userModel.countryCode =
                                              controller.countryCode.value;
                                          userModel.phoneNumber =
                                              controller.phoneNumber.value;
                                          userModel.loginType =
                                              Constant.phoneLoginType;

                                          ShowToastDialog.closeLoader();
                                          Get.to(const InformationScreen(),
                                              arguments: {
                                                "userModel": userModel,
                                              });
                                        } else {
                                          await FireStoreUtils
                                                  .userExitCustomerOrDriverRole(
                                                      value.user!.uid)
                                              .then((userExit) async {
                                            ShowToastDialog.closeLoader();
                                            if (userExit == '') {
                                              UserModel userModel = UserModel();
                                              userModel.id = value.user!.uid;
                                              userModel.countryCode =
                                                  controller.countryCode.value;
                                              userModel.phoneNumber =
                                                  controller.phoneNumber.value;
                                              userModel.loginType =
                                                  Constant.phoneLoginType;

                                              ShowToastDialog.closeLoader();
                                              Get.to(const InformationScreen(),
                                                  arguments: {
                                                    "userModel": userModel,
                                                  });
                                            } else if (userExit ==
                                                Constant.currentUserType) {
                                              UserModel? userModel =
                                                  await FireStoreUtils
                                                      .getUserProfile(
                                                          value.user!.uid);
                                              if (userModel != null) {
                                                if (userModel.isActive ==
                                                    true) {
                                                  Get.offAll(
                                                      const DashBoardScreen());
                                                /*  Get.offAll(
                                                      const DummayScreen(),
                                                      arguments: {
                                                        'userModel': userModel
                                                      });*/
                                                } else {
                                                  await FirebaseAuth.instance
                                                      .signOut();
                                                  ShowToastDialog.showToast(
                                                      "This user is disable please contact administrator"
                                                          .tr);
                                                }
                                              }
                                            } else {
                                              await FirebaseAuth.instance
                                                  .signOut();
                                              ShowToastDialog.showToast(
                                                  'This mobile number is already registered with a different role.'
                                                      .tr);
                                            }
                                          });
                                        }
                                      }).catchError((error) {
                                        ShowToastDialog.closeLoader();
                                        ShowToastDialog.showToast(
                                            "Code is Invalid".tr);
                                      });
                                    } else {
                                      ShowToastDialog.showToast(
                                          "Please Enter Valid OTP".tr);
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.moroccoRed,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    elevation: 5,
                                    shadowColor:
                                        AppColors.moroccoRed.withOpacity(0.5),
                                  ),
                                  child: Text(
                                    "Verify OTP".tr,
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Footer
                        Text(
                          "Didn't receive code?".tr,
                          style: GoogleFonts.poppins(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                        // const SizedBox(height: 8),
                        // TextButton(
                        //   onPressed: () {
                        //     // resend logic
                        //     ShowToastDialog.showToast("Coming Soon".tr);
                        //   },
                        //   child: Text(
                        //     "Resend OTP".tr,
                        //     style: GoogleFonts.poppins(
                        //       color: AppColors.moroccoGreen,
                        //       fontSize: 16,
                        //       fontWeight: FontWeight.bold,
                        //     ),
                        //   ),
                        // ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }
}

class MoroccanPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.moroccoGreen.withOpacity(0.02)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    const double patternSize = 100.0;

    for (double x = -patternSize / 2;
        x < size.width + patternSize;
        x += patternSize) {
      for (double y = -patternSize / 2;
          y < size.height + patternSize;
          y += patternSize) {
        _drawEightPointStar(canvas, Offset(x, y), patternSize * 0.4, paint);
      }
    }

    // Add some corner decorations
    final cornerPaint = Paint()
      ..color = AppColors.moroccoRed.withOpacity(0.04)
      ..style = PaintingStyle.fill;

    Path cornerPath = Path();
    cornerPath.moveTo(0, 0);
    cornerPath.lineTo(80, 0);
    cornerPath.quadraticBezierTo(40, 40, 0, 80);
    cornerPath.close();

    canvas.drawPath(cornerPath, cornerPaint);

    canvas.save();
    canvas.translate(size.width, size.height);
    canvas.rotate(math.pi);
    canvas.drawPath(cornerPath, cornerPaint);
    canvas.restore();
  }

  void _drawEightPointStar(
      Canvas canvas, Offset center, double radius, Paint paint) {
    Path path = Path();
    for (int i = 0; i < 8; i++) {
      double angle = i * math.pi / 4;
      double x = center.dx + radius * math.cos(angle);
      double y = center.dy + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }

      double nextAngle = (i + 0.5) * math.pi / 4;
      double nextX = center.dx + (radius * 0.7) * math.cos(nextAngle);
      double nextY = center.dy + (radius * 0.7) * math.sin(nextAngle);
      path.lineTo(nextX, nextY);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
