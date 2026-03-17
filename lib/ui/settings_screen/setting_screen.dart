import 'dart:convert';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/services/localization_service.dart';
import 'package:customer/themes/app_colors.dart';
import 'package:customer/ui/auth_screen/login_screen.dart';
import 'package:customer/utils/DarkThemeProvider.dart';
import 'package:customer/utils/Preferences.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../controller/setting_controller.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetBuilder<SettingController>(
        init: SettingController(),
        builder: (controller) {
          return Scaffold(
            backgroundColor: themeChange.getThem() ? AppColors.darkBackground : AppColors.moroccoBackground,
            body: controller.isLoading.value
                ? Constant.loader(isDarkTheme: themeChange.getThem())
                : Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                        decoration: BoxDecoration(
                          color: themeChange.getThem() ? AppColors.darkBackground : AppColors.moroccoRed,
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(30),
                            bottomRight: Radius.circular(30),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),
                            /*IconButton(
                              onPressed: () => Get.back(),
                              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              "Settings".tr,
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),*/
                            Text(
                              "Customize your app experience".tr,
                              style: GoogleFonts.outfit(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              _buildSettingCard(
                                themeChange,
                                icon: 'assets/icons/ic_language.svg',
                                title: "Language".tr,
                                trailing: SizedBox(
                                  width: 120,
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButtonFormField(
                                        isExpanded: true,
                                        alignment: Alignment.centerRight,
                                        decoration: const InputDecoration(
                                          contentPadding: EdgeInsets.zero,
                                          border: InputBorder.none,
                                          isDense: true,
                                        ),
                                        icon: Icon(Icons.keyboard_arrow_down_rounded, color: themeChange.getThem() ? Colors.white70 : Colors.black45),
                                        value: controller.selectedLanguage.value.id == null ? null : controller.selectedLanguage.value,
                                        onChanged: (value) {
                                          controller.selectedLanguage.value = value!;
                                          LocalizationService().changeLocale(value.code.toString());
                                          Preferences.setString(Preferences.languageCodeKey, jsonEncode(controller.selectedLanguage.value));
                                        },
                                        hint: Text("Select".tr, style: GoogleFonts.outfit(fontSize: 14)),
                                        items: controller.languageList.map((item) {
                                          return DropdownMenuItem(
                                            value: item,
                                            child: Text(item.name.toString(), 
                                              textAlign: TextAlign.end,
                                              style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w500)),
                                          );
                                        }).toList()),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildSettingCard(
                                themeChange,
                                icon: 'assets/icons/ic_light_drak.svg',
                                title: "Appearance".tr,
                                trailing: SizedBox(
                                  width: 120,
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButtonFormField<String>(
                                        isExpanded: true,
                                        alignment: Alignment.centerRight,
                                        decoration: const InputDecoration(
                                          contentPadding: EdgeInsets.zero,
                                          border: InputBorder.none,
                                          isDense: true,
                                        ),
                                        icon: Icon(Icons.keyboard_arrow_down_rounded, color: themeChange.getThem() ? Colors.white70 : Colors.black45),
                                        value: controller.selectedMode.isEmpty ? null : controller.selectedMode.value,
                                        onChanged: (value) {
                                          controller.selectedMode.value = value!;
                                          Preferences.setString(Preferences.themKey, value.toString());
                                          if (controller.selectedMode.value == "Dark mode") {
                                            themeChange.darkTheme = 0;
                                          } else if (controller.selectedMode.value == "Light mode") {
                                            themeChange.darkTheme = 1;
                                          } else {
                                            themeChange.darkTheme = 2;
                                          }
                                        },
                                        hint: Text("Select".tr, style: GoogleFonts.outfit(fontSize: 14)),
                                        items: controller.modeList.map((item) {
                                          return DropdownMenuItem(
                                            value: item,
                                            child: Text(item.toString().tr, 
                                              textAlign: TextAlign.end,
                                              style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w500)),
                                          );
                                        }).toList()),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildSettingCard(
                                themeChange,
                                icon: 'assets/icons/ic_support.svg',
                                title: "Support".tr,
                                onTap: () async {
                                  final Uri url = Uri.parse(Constant.supportURL.toString());
                                  if (!await launchUrl(url)) {
                                    throw Exception('Could not launch ${Constant.supportURL.toString()}'.tr);
                                  }
                                },
                                trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey[400]),
                              ),
                              const SizedBox(height: 16),
                            /*  _buildSettingCard(
                                themeChange,
                                icon: 'assets/icons/ic_delete.svg',
                                title: "Delete Account".tr,
                                isDestructive: true,
                                onTap: () {
                                  showAlertDialog(context, controller);
                                },
                                trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey[400]),
                              ),
                              const SizedBox(height: 40),*/
                             /* Text(
                                "V ${Constant.appVersion}".tr,
                                style: GoogleFonts.outfit(
                                  color: Colors.grey[500],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),*/
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
          );
        });
  }

  Widget _buildSettingCard(
    DarkThemeProvider themeChange, {
    required String icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: themeChange.getThem() ? AppColors.darkGray : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (isDestructive ? Colors.red : (themeChange.getThem() ? AppColors.moroccoGreen : AppColors.moroccoRed)).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: SvgPicture.asset(
                icon,
                width: 20,
                color: isDestructive ? Colors.red : (themeChange.getThem() ? AppColors.moroccoGreen : AppColors.moroccoRed),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDestructive 
                      ? Colors.red 
                      : (themeChange.getThem() ? Colors.white : Colors.black87),
                ),
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  void showAlertDialog(BuildContext context, SettingController controller) {
    Widget okButton = TextButton(
      child: Text("OK".tr, style: GoogleFonts.outfit(color: Colors.red, fontWeight: FontWeight.bold)),
      onPressed: () async {
        ShowToastDialog.showLoader("Please wait".tr);
        await FireStoreUtils.deleteUser().then((value) {
          ShowToastDialog.closeLoader();
          if (value == true) {
            ShowToastDialog.showToast("Account deleted".tr);
            Get.offAll(const LoginScreen());
          } else {
            ShowToastDialog.showToast("Please contact the administrator".tr);
          }
        });
      },
    );
    Widget cancelButton = TextButton(
      child: Text("Cancel".tr, style: GoogleFonts.outfit(color: Colors.grey)),
      onPressed: () {
        Get.back();
      },
    );

    AlertDialog alert = AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text("Account delete".tr, style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      content: Text("Are you sure want to delete Account.".tr, style: GoogleFonts.outfit()),
      actions: [
        cancelButton,
        okButton,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
