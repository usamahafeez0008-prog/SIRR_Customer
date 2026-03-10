import 'dart:io';
import 'dart:math' as math;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/controller/information_controller.dart';
import 'package:customer/model/referral_model.dart';
import 'package:customer/model/user_model.dart';
import 'package:customer/themes/app_colors.dart';
import 'package:customer/ui/auth_screen/dummay_screen.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../dashboard_screen.dart';

class InformationScreen extends StatelessWidget {
  const InformationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<InformationController>(
        init: InformationController(),
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
                        // Logo
                        Hero(
                          tag: 'app_logo',
                          child: Image.asset(
                            "assets/images/splash_image.png",
                            width: 170,
                            fit: BoxFit.contain,
                          ),
                        ),

                        // Title Text
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [
                              AppColors.moroccoRed,
                              AppColors.moroccoGreen
                            ],
                          ).createShader(bounds),
                          child: Text(
                            "Sign up".tr,
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
                          "Create your account to start using SIIR".tr,
                          style: GoogleFonts.outfit(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Main Form Card
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
                              // Profile Image Selector
                              _buildProfileImageSelector(context, controller),
                              const SizedBox(height: 24),

                              // Title Dropdown
                              Obx(() => Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade50,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                          color: Colors.grey.shade200),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: controller.userTitle.value,
                                        isExpanded: true,
                                        icon: Icon(Icons.keyboard_arrow_down,
                                            color: AppColors.moroccoGreen
                                                .withOpacity(0.6),
                                            size: 20),
                                        elevation: 16,
                                        style: GoogleFonts.poppins(
                                            color: Colors.black),
                                        onChanged: (String? newValue) {
                                          controller.userTitle.value =
                                              newValue!;
                                        },
                                        items: controller.titles
                                            .map<DropdownMenuItem<String>>(
                                                (String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Row(
                                              children: [
                                                Icon(Icons.person_outline,
                                                    color: AppColors
                                                        .moroccoGreen
                                                        .withOpacity(0.6)),
                                                const SizedBox(width: 12),
                                                Text(value.tr),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  )),
                              const SizedBox(height: 16),

                              // First Name
                              _buildThemedTextField(
                                context,
                                hintText: 'First Name'.tr,
                                controller: controller.firstNameController,
                                icon: Icons.person_outline,
                              ),
                              const SizedBox(height: 16),

                              // Last Name
                              _buildThemedTextField(
                                context,
                                hintText: 'Last Name'.tr,
                                controller: controller.lastNameController,
                                icon: Icons.person_outline,
                              ),
                              const SizedBox(height: 16),

                              // Phone Number
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(20),
                                  border:
                                      Border.all(color: Colors.grey.shade200),
                                ),
                                child: TextFormField(
                                  validator: (value) =>
                                      value != null && value.isNotEmpty
                                          ? null
                                          : 'Required',
                                  keyboardType: TextInputType.number,
                                  controller: controller.phoneNumberController,
                                  enabled: controller.loginType.value !=
                                      Constant.phoneLoginType,
                                  style:
                                      GoogleFonts.poppins(color: Colors.black),
                                  decoration: InputDecoration(
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    hintText: "Phone number".tr,
                                    hintStyle: GoogleFonts.poppins(
                                        color: Colors.grey.shade400),
                                    border: InputBorder.none,
                                    prefixIcon: CountryCodePicker(
                                      onChanged: (value) {
                                        controller.countryCode.value =
                                            value.dialCode.toString();
                                      },
                                      enabled: controller.loginType.value !=
                                          Constant.phoneLoginType,
                                      initialSelection:
                                          controller.countryCode.value,
                                      showDropDownButton: true,
                                      padding: EdgeInsets.zero,
                                      dialogBackgroundColor: Colors.white,
                                      textStyle: GoogleFonts.poppins(
                                          color: AppColors.moroccoGreen,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Email
                              _buildThemedTextField(
                                context,
                                hintText: 'Email'.tr,
                                controller: controller.emailController,
                                icon: Icons.email_outlined,
                                enabled: controller.loginType.value !=
                                    Constant.googleLoginType,
                              ),
                              const SizedBox(height: 16),

                              // Password
                              Obx(() => _buildThemedTextField(
                                    context,
                                    hintText: 'Password'.tr,
                                    controller: controller.passwordController,
                                    icon: Icons.lock_outline,
                                    obscureText:
                                        !controller.isPasswordVisible.value,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        controller.isPasswordVisible.value
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        color: AppColors.moroccoGreen
                                            .withOpacity(0.6),
                                      ),
                                      onPressed: () {
                                        controller.isPasswordVisible.value =
                                            !controller.isPasswordVisible.value;
                                      },
                                    ),
                                  )),
                              const SizedBox(height: 16),

                              // Referral Code
                              /*  _buildThemedTextField(
                                context,
                                hintText: 'Referral Code (Optional)'.tr,
                                controller: controller.referralCodeController,
                                icon: Icons.card_giftcard_outlined,
                              ),*/
                              const SizedBox(height: 40),

                              // Create Account Button
                              SizedBox(
                                width: double.infinity,
                                height: 55,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    if (controller
                                        .firstNameController.text.isEmpty) {
                                      ShowToastDialog.showToast(
                                          "Please enter first name".tr);
                                    } else if (controller
                                        .lastNameController.text.isEmpty) {
                                      ShowToastDialog.showToast(
                                          "Please enter last name".tr);
                                    } else if (controller
                                        .emailController.text.isEmpty) {
                                      ShowToastDialog.showToast(
                                          "Please enter email".tr);
                                    } else if (controller
                                        .phoneNumberController.text.isEmpty) {
                                      ShowToastDialog.showToast(
                                          "Please enter phone".tr);
                                    } else if (controller
                                        .passwordController.text.isEmpty) {
                                      ShowToastDialog.showToast(
                                          "Please enter password".tr);
                                    } else if (Constant.validateEmail(
                                            controller.emailController.text) ==
                                        false) {
                                      ShowToastDialog.showToast(
                                          "Please enter valid email".tr);
                                    } else {
                                      String fullName =
                                          "${controller.firstNameController.text.trim()} ${controller.lastNameController.text.trim()}";

                                      if (controller.referralCodeController.text
                                          .isNotEmpty) {
                                        FireStoreUtils
                                                .checkReferralCodeValidOrNot(
                                                    controller
                                                        .referralCodeController
                                                        .text)
                                            .then((value) async {
                                          if (value == true) {
                                            ShowToastDialog.showLoader(
                                                "Please wait".tr);
                                            UserModel userModel =
                                                controller.userModel.value;

                                            if (controller.profileImage.value
                                                .isNotEmpty) {
                                              controller.profileImage.value =
                                                  await Constant
                                                      .uploadUserImageToFireStorage(
                                                          File(
                                                              controller
                                                                  .profileImage
                                                                  .value),
                                                          "profileImage/${FireStoreUtils.getCurrentUid()}",
                                                          File(controller
                                                                  .profileImage
                                                                  .value)
                                                              .path
                                                              .split('/')
                                                              .last);
                                              userModel.profilePic =
                                                  controller.profileImage.value;
                                            }

                                            userModel.userTitle =
                                                controller.userTitle.value;
                                            userModel.fullName = fullName;
                                            userModel.email =
                                                controller.emailController.text;
                                            userModel.countryCode =
                                                controller.countryCode.value;
                                            userModel.phoneNumber = controller
                                                .phoneNumberController.text;
                                            userModel.password = controller
                                                .passwordController.text;
                                            userModel.isActive = true;
                                            userModel.createdAt =
                                                Timestamp.now();

                                            await FireStoreUtils
                                                    .getReferralUserByCode(
                                                        controller
                                                            .referralCodeController
                                                            .text)
                                                .then((value) async {
                                              if (value != null) {
                                                ReferralModel ownReferralModel =
                                                    ReferralModel(
                                                  id: FireStoreUtils
                                                      .getCurrentUid(),
                                                  referralBy: value.id,
                                                  referralCode: Constant
                                                      .getReferralCode(),
                                                );
                                                await FireStoreUtils
                                                    .referralAdd(
                                                        ownReferralModel);
                                              } else {
                                                ReferralModel referralModel =
                                                    ReferralModel(
                                                  id: FireStoreUtils
                                                      .getCurrentUid(),
                                                  referralBy: "",
                                                  referralCode: Constant
                                                      .getReferralCode(),
                                                );

                                                await FireStoreUtils
                                                    .referralAdd(referralModel);
                                              }
                                            });

                                            await FireStoreUtils.updateUser(
                                                    userModel)
                                                .then((value) {
                                              ShowToastDialog.closeLoader();

                                              if (value == true) {
                                                Get.offAll(
                                                    const DashBoardScreen());
                                              }
                                            /*  Get.to(const DummayScreen(),
                                                  arguments: {
                                                    'userModel': userModel
                                                  });*/
                                            });
                                          } else {
                                            ShowToastDialog.showToast(
                                                "Referral code Invalid".tr);
                                          }
                                        });
                                      } else {
                                        ShowToastDialog.showLoader(
                                            "Please wait".tr);
                                        UserModel userModel =
                                            controller.userModel.value;

                                        if (controller
                                            .profileImage.value.isNotEmpty) {
                                          controller.profileImage.value =
                                              await Constant
                                                  .uploadUserImageToFireStorage(
                                                      File(
                                                          controller
                                                              .profileImage
                                                              .value),
                                                      "profileImage/${FireStoreUtils.getCurrentUid()}",
                                                      File(controller
                                                              .profileImage
                                                              .value)
                                                          .path
                                                          .split('/')
                                                          .last);
                                          userModel.profilePic =
                                              controller.profileImage.value;
                                        }

                                        userModel.userTitle =
                                            controller.userTitle.value;
                                        userModel.fullName = fullName;
                                        userModel.email =
                                            controller.emailController.text;
                                        userModel.countryCode =
                                            controller.countryCode.value;
                                        userModel.phoneNumber = controller
                                            .phoneNumberController.text;
                                        userModel.password =
                                            controller.passwordController.text;
                                        userModel.isActive = true;
                                        userModel.createdAt = Timestamp.now();

                                        ReferralModel referralModel =
                                            ReferralModel(
                                          id: FireStoreUtils.getCurrentUid(),
                                          referralBy: "",
                                          referralCode:
                                              Constant.getReferralCode(),
                                        );
                                        await FireStoreUtils.referralAdd(
                                            referralModel);

                                        await FireStoreUtils.updateUser(
                                                userModel)
                                            .then((value) {
                                          ShowToastDialog.closeLoader();
                                          if (value == true) {
                                            Get.offAll(const DashBoardScreen());
                                          }
                                         /* Get.to(const DummayScreen(),
                                              arguments: {
                                                'userModel': userModel
                                              });*/
                                        });
                                      }
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
                                    "Create account".tr,
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
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  Widget _buildThemedTextField(BuildContext context,
      {required String hintText,
      required TextEditingController controller,
      required IconData icon,
      bool enabled = true,
      bool obscureText = false,
      Widget? suffixIcon}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        obscureText: obscureText,
        style: GoogleFonts.poppins(color: Colors.black),
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          hintText: hintText,
          hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400),
          border: InputBorder.none,
          prefixIcon:
              Icon(icon, color: AppColors.moroccoGreen.withOpacity(0.6)),
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }

  Widget _buildProfileImageSelector(
      BuildContext context, InformationController controller) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Obx(() => Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
                border: Border.all(
                    color: AppColors.moroccoGreen.withOpacity(0.3), width: 2),
              ),
              child: controller.profileImage.value.isEmpty
                  ? (controller.userModel.value.profilePic != null &&
                          controller.userModel.value.profilePic!.isNotEmpty
                      ? ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: controller.userModel.value.profilePic!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator()),
                            errorWidget: (context, url, error) => Icon(
                                Icons.person,
                                size: 50,
                                color: Colors.grey.shade400),
                          ),
                        )
                      : Icon(Icons.person,
                          size: 50, color: Colors.grey.shade400))
                  : ClipOval(
                      child: Image.file(
                        File(controller.profileImage.value),
                        fit: BoxFit.cover,
                      ),
                    ),
            )),
        Positioned(
          bottom: 0,
          right: 0,
          child: InkWell(
            onTap: () {
              buildBottomSheet(context, controller);
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.moroccoRed,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child:
                  const Icon(Icons.camera_alt, color: Colors.white, size: 18),
            ),
          ),
        ),
      ],
    );
  }

  buildBottomSheet(BuildContext context, InformationController controller) {
    return showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (context) {
          return SizedBox(
            height: 220,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text(
                    "Select Image Source".tr,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    InkWell(
                      onTap: () =>
                          controller.pickFile(source: ImageSource.camera),
                      child: Column(
                        children: [
                          Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.moroccoRed.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.camera_alt,
                                  color: AppColors.moroccoRed, size: 30)),
                          const SizedBox(height: 8),
                          Text("Camera".tr, style: GoogleFonts.poppins()),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () =>
                          controller.pickFile(source: ImageSource.gallery),
                      child: Column(
                        children: [
                          Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.moroccoGreen.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.photo_library,
                                  color: AppColors.moroccoGreen, size: 30)),
                          const SizedBox(height: 8),
                          Text("Gallery".tr, style: GoogleFonts.poppins()),
                        ],
                      ),
                    ),
                  ],
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
