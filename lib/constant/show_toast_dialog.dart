import 'dart:developer';

import 'package:customer/themes/app_colors.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/route_manager.dart';

class ShowToastDialog {
  static void showToast(String? message, {Duration? duration}) {
    log("Get.isDarkMode :: ${Get.isDarkMode}");
    EasyLoading.instance.backgroundColor = Get.isDarkMode ? AppColors.moroccoGreen : AppColors.moroccoGreen;
    EasyLoading.showToast(message!, duration: duration);
  }

  static void showLoader(String message) {
    log("Get.isDarkMode :: ${Get.isDarkMode}");
    EasyLoading.instance.backgroundColor = Get.isDarkMode ? AppColors.moroccoGreen : AppColors.moroccoGreen;
    EasyLoading.show(status: message);
  }

  static void closeLoader() {
    EasyLoading.dismiss();
  }
}
