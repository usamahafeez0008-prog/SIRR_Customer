import 'package:customer/constant/constant.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/controller/contact_us_controller.dart';
import 'package:customer/themes/app_colors.dart';
import 'package:customer/themes/button_them.dart';
import 'package:customer/themes/text_field_them.dart';
import 'package:customer/utils/DarkThemeProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    return GetX<ContactUsController>(
        init: ContactUsController(),
        builder: (controller) {
          return Scaffold(
            backgroundColor: themeChange.getThem() ? AppColors.darkBackground : AppColors.moroccoBackground,
           /* appBar: AppBar(
              backgroundColor: themeChange.getThem() ? AppColors.darkBackground : AppColors.moroccoRed,
              elevation: 0,
              centerTitle: true,
              title: Text(
                "Contact Us".tr,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
              leading: IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
              ),
            ),*/
            body: controller.isLoading.value
                ? Constant.loader(isDarkTheme: themeChange.getThem())
                : Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 24),
                        decoration: BoxDecoration(
                          color: themeChange.getThem() ? AppColors.darkBackground : AppColors.moroccoRed,
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(30),
                            bottomRight: Radius.circular(30),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "How can we help you?".tr,
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Let us know your issue & feedback".tr,
                              style: GoogleFonts.outfit(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: DefaultTabController(
                          length: 2,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: themeChange.getThem() ? AppColors.darkGray : Colors.white,
                                    borderRadius: BorderRadius.circular(25),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: TabBar(
                                    indicator: BoxDecoration(
                                      borderRadius: BorderRadius.circular(25),
                                      color: themeChange.getThem() ? AppColors.moroccoGreen : AppColors.moroccoRed,
                                    ),
                                    labelColor: Colors.white,
                                    unselectedLabelColor: themeChange.getThem() ? Colors.white70 : Colors.black54,
                                    labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                                    tabs: [
                                      Tab(text: "Call Us".tr),
                                      Tab(text: "Email Us".tr),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: TabBarView(
                                  children: [
                                    _buildCallUsTab(context, controller, themeChange),
                                    _buildEmailUsTab(context, controller, themeChange),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
          );
        });
  }

  Widget _buildCallUsTab(BuildContext context, ContactUsController controller, DarkThemeProvider themeChange) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildContactCard(
            context,
            icon: Icons.phone_in_talk_rounded,
            title: "Phone Number".tr,
            subtitle: controller.phone.value,
            onTap: () => Constant.makePhoneCall(controller.phone.value),
            themeChange: themeChange,
          ),
          const SizedBox(height: 16),
          _buildContactCard(
            context,
            icon: Icons.location_on_rounded,
            title: "Our Address".tr,
            subtitle: controller.address.value,
            onTap: null,
            themeChange: themeChange,
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(BuildContext context, {required IconData icon, required String title, required String subtitle, VoidCallback? onTap, required DarkThemeProvider themeChange}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
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
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (themeChange.getThem() ? AppColors.moroccoGreen : AppColors.moroccoRed).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: themeChange.getThem() ? AppColors.moroccoGreen : AppColors.moroccoRed,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: themeChange.getThem() ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Colors.grey[400],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailUsTab(BuildContext context, ContactUsController controller, DarkThemeProvider themeChange) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Write us".tr,
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: themeChange.getThem() ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  "Describe your issue".tr,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 24),
                TextFieldThem.buildTextFiled(
                  context,
                  hintText: 'Email'.tr,
                  controller: controller.emailController.value,
                ),
                const SizedBox(height: 16),
                TextFieldThem.buildTextFiled(
                  context,
                  hintText: 'Describe your issue and feedback'.tr,
                  controller: controller.feedbackController.value,
                  maxLine: 5,
                ),
                const SizedBox(height: 24),
                ButtonThem.buildButton(
                  context,
                  title: "Submit".tr,
                  btnRadius: 30,
                  onPress: () async {
                    if (controller.emailController.value.text.isEmpty) {
                      ShowToastDialog.showToast("Please enter email".tr);
                    } else if (controller.feedbackController.value.text.isEmpty) {
                      ShowToastDialog.showToast("Please enter feedback".tr);
                    } else {
                      final Email email = Email(
                        body: controller.feedbackController.value.text,
                        subject: controller.subject.value,
                        recipients: [controller.email.value],
                        cc: [controller.emailController.value.text],
                        isHTML: false,
                      );
                      await FlutterEmailSender.send(email);
                      controller.emailController.value.clear();
                      controller.feedbackController.value.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
