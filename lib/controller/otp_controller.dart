import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OtpController extends GetxController {
  late TextEditingController otpController;

  RxString countryCode = "".obs;
  RxString phoneNumber = "".obs;
  RxString verificationId = "".obs;

  @override
  void onInit() {
    otpController = TextEditingController();
    getArgument();
    super.onInit();
  }

  @override
  void onClose() {
    otpController.dispose();
    super.onClose();
  }

  getArgument() async {
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      countryCode.value = argumentData['countryCode'] ?? "";
      phoneNumber.value = argumentData['phoneNumber'] ?? "";
      verificationId.value = argumentData['verificationId'] ?? "";
    }
    update();
  }
}
