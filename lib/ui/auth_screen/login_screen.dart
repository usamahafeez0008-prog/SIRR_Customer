import 'dart:io';
import 'dart:math' as math;
import 'package:country_code_picker/country_code_picker.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/controller/login_controller.dart';
import 'package:customer/model/user_model.dart';
import 'package:customer/themes/app_colors.dart';
import 'package:customer/ui/auth_screen/dummay_screen.dart';
import 'package:customer/ui/auth_screen/information_screen.dart';
import 'package:customer/ui/terms_and_condition/terms_and_condition_screen.dart';
import 'package:customer/utils/DarkThemeProvider.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../utils/notification_service.dart';
import '../dashboard_screen.dart';
import 'login_with_password_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetX<LoginController>(
        init: LoginController(),
        builder: (controller) {
          final themeChange = Provider.of<DarkThemeProvider>(context);
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
                        // Logo
                        Hero(
                          tag: 'app_logo',
                          child: Image.asset(
                            "assets/images/splash_image.png",
                            width: 170,
                            fit: BoxFit.contain,
                          ),
                        ),

                        // Welcome Back Text
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [
                              AppColors.moroccoRed,
                              AppColors.moroccoGreen
                            ],
                          ).createShader(bounds),
                          child: Text(
                            "Welcome Back".tr,
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
                          "We are happy to have you back".tr,
                          style: GoogleFonts.outfit(
                            color: Colors.grey.shade600,
                            fontSize: 16,
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
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Register with Phone".tr,
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Phone Input
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: AppColors.moroccoGreen
                                          .withOpacity(0.3)),
                                ),
                                child: Row(
                                  children: [
                                    CountryCodePicker(
                                      onChanged: (value) {
                                        controller.countryCode.value =
                                            value.dialCode.toString();
                                      },
                                      padding: EdgeInsets.zero,
                                      searchStyle: GoogleFonts.poppins(),
                                      dialogTextStyle: GoogleFonts.poppins(),
                                      textStyle: GoogleFonts.poppins(
                                        color: AppColors.moroccoGreen,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      dialogBackgroundColor: AppColors
                                          .moroccoGreen
                                          .withOpacity(0.6),
                                      initialSelection:
                                          controller.countryCode.value,
                                      showCountryOnly: false,
                                      showOnlyCountryWhenClosed: false,
                                      alignLeft: false,
                                    ),
                                    Expanded(
                                      child: TextFormField(
                                        controller:
                                            controller.phoneNumberController,
                                        keyboardType: TextInputType.number,
                                        style: GoogleFonts.poppins(
                                            color: AppColors.moroccoGreen),
                                        decoration: InputDecoration(
                                          hintText: "6/7 XX XX XX XX".tr,
                                          hintStyle: GoogleFonts.poppins(
                                              color: Colors.grey.shade400),
                                          border: InputBorder.none,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 16),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 32),

                              // Get OTP Button
                              SizedBox(
                                width: double.infinity,
                                height: 55,
                                child: ElevatedButton(
                                  onPressed: () => controller.sendCode(),
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
                                    "Get OTP".tr,
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 16),
                              InkWell(
                                onTap: () {
                                  Get.to(() => const LoginWithPasswordScreen());
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Container(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      textAlign: TextAlign.right,
                                      "Already Have An Account! Login".tr,
                                      style: GoogleFonts.poppins(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.moroccoGreen,
                                        //decoration: TextDecoration.underline,
                                        decorationColor: AppColors.moroccoRed,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 40),

                              // Quick Login Divider
                              Row(
                                children: [
                                  Expanded(
                                      child: Divider(
                                          color: AppColors.moroccoGreen)),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    child: Text(
                                      "Continue with".tr,
                                      style: GoogleFonts.poppins(
                                        color: AppColors.moroccoGreen,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                      child: Divider(
                                          color: AppColors.moroccoGreen)),
                                ],
                              ),
                              const SizedBox(height: 30),

                              // Social Logins
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildSocialButton(
                                    onTap: () async {
                                      ShowToastDialog.showLoader(
                                          "Please wait".tr);
                                      await controller
                                          .signInWithGoogle()
                                          .then((value) async {
                                        ShowToastDialog.closeLoader();
                                        if (value != null) {
                                          if (value
                                              .additionalUserInfo!.isNewUser) {
                                            UserModel userModel = UserModel();
                                            userModel.id = value.user!.uid;
                                            userModel.email = value.user!.email;
                                            userModel.fullName =
                                                value.user!.displayName;
                                            userModel.profilePic =
                                                value.user!.photoURL;
                                            userModel.loginType =
                                                Constant.googleLoginType;

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
                                                UserModel userModel =
                                                    UserModel();
                                                userModel.id = value.user!.uid;
                                                userModel.email =
                                                    value.user!.email;
                                                userModel.fullName =
                                                    value.user!.displayName;
                                                userModel.profilePic =
                                                    value.user!.photoURL;
                                                userModel.loginType =
                                                    Constant.googleLoginType;

                                                ShowToastDialog.closeLoader();
                                                Get.to(
                                                    const InformationScreen(),
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
                                                    String token =
                                                        await NotificationService
                                                            .getToken();
                                                    userModel.fcmToken = token;
                                                    await FireStoreUtils
                                                        .updateUser(userModel);
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
                                                    'This account is already registered with a different role.'
                                                        .tr);
                                              }
                                            });
                                          }
                                        }
                                      });
                                    },
                                    child: Image.asset(
                                        'assets/icons/ic_google.png'),
                                  ),
                                  const SizedBox(width: 20),
                                  _buildSocialButton(
                                    onTap: () {
                                      ShowToastDialog.showToast(
                                          "Coming Soon".tr);
                                    },
                                    child: const Icon(
                                      Icons.facebook,
                                      color: Color(0xFF1877F2),
                                      size: 35,
                                    ),
                                  ),
                                  if (Platform.isIOS) ...[
                                    const SizedBox(width: 20),
                                    _buildSocialButton(
                                      onTap: () async {
                                        ShowToastDialog.showLoader(
                                            "Please wait".tr);
                                        await controller
                                            .signInWithApple()
                                            .then((value) async {
                                          ShowToastDialog.closeLoader();

                                          if (value != null) {
                                            Map<String, dynamic> map = value;
                                            AuthorizationCredentialAppleID
                                                appleCredential =
                                                map['appleCredential'];
                                            UserCredential userCredential =
                                                map['userCredential'];

                                            if (userCredential
                                                .additionalUserInfo!
                                                .isNewUser) {
                                              UserModel userModel = UserModel();
                                              userModel.id =
                                                  userCredential.user!.uid;
                                              userModel.profilePic =
                                                  userCredential.user!.photoURL;
                                              userModel.loginType =
                                                  Constant.appleLoginType;
                                              userModel.email = userCredential
                                                  .additionalUserInfo!
                                                  .profile!['email'];
                                              userModel.fullName =
                                                  "${appleCredential.givenName} ${appleCredential.familyName}";

                                              ShowToastDialog.closeLoader();
                                              Get.to(const InformationScreen(),
                                                  arguments: {
                                                    "userModel": userModel,
                                                  });
                                            } else {
                                              await FireStoreUtils
                                                      .userExitCustomerOrDriverRole(
                                                          userCredential
                                                              .user!.uid)
                                                  .then((userExit) async {
                                                ShowToastDialog.closeLoader();
                                                if (userExit == '') {
                                                  UserModel userModel =
                                                      UserModel();
                                                  userModel.id =
                                                      userCredential.user!.uid;
                                                  userModel.profilePic =
                                                      userCredential
                                                          .user!.photoURL;
                                                  userModel.loginType =
                                                      Constant.appleLoginType;
                                                  userModel.email =
                                                      userCredential
                                                          .additionalUserInfo!
                                                          .profile!['email'];
                                                  userModel.fullName =
                                                      "${appleCredential.givenName} ${appleCredential.familyName}";

                                                  ShowToastDialog.closeLoader();
                                                  Get.to(
                                                      const InformationScreen(),
                                                      arguments: {
                                                        "userModel": userModel,
                                                      });
                                                } else if (userExit ==
                                                    Constant.currentUserType) {
                                                  UserModel? userModel =
                                                      await FireStoreUtils
                                                          .getUserProfile(
                                                              userCredential
                                                                  .user!.uid);
                                                  if (userModel != null) {
                                                    if (userModel.isActive ==
                                                        true) {
                                                      Get.offAll(
                                                          const DashBoardScreen());
                                                    /*  Get.offAll(
                                                          const DummayScreen(),
                                                          arguments: {
                                                            'userModel':
                                                                userModel
                                                          });*/
                                                    } else {
                                                      await FirebaseAuth
                                                          .instance
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
                                                      'This account is already registered with a different role.'
                                                          .tr);
                                                }
                                              });
                                            }
                                          }
                                        });
                                      },
                                      child: Image.asset(
                                        'assets/icons/ic_apple.png',
                                        color: themeChange.getThem()
                                            ? AppColors.darksecondprimary
                                            : AppColors.lightsecondprimary,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Footer
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Text.rich(
                            textAlign: TextAlign.center,
                            TextSpan(
                              text: 'Agreement on '.tr,
                              style: GoogleFonts.poppins(
                                  color: Colors.grey, fontSize: 13),
                              children: [
                                TextSpan(
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {},
                                  text: 'Terms'.tr,
                                  style: GoogleFonts.poppins(
                                      color: AppColors.moroccoRed,
                                      fontWeight: FontWeight.bold),
                                ),
                                TextSpan(text: ' & '.tr),
                                TextSpan(
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {},
                                  text: 'Privacy'.tr,
                                  style: GoogleFonts.poppins(
                                      color: AppColors.moroccoGreen,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
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

  Widget _buildSocialButton(
      {required VoidCallback onTap, required Widget child}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.moroccoGreen.withOpacity(0.2)),
        ),
        child: child,
      ),
    );
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
