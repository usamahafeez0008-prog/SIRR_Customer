import 'dart:developer';
import 'package:customer/constant/constant.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/model/user_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class InformationController extends GetxController {
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController referralCodeController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  RxBool isPasswordVisible = false.obs;
  RxString countryCode = "+212".obs;
  RxString loginType = "".obs;
  RxString userTitle = "Mr".obs;
  List<String> titles = ["Mr", "Mme"];

  final ImagePicker _imagePicker = ImagePicker();
  RxString profileImage = "".obs;

  Future pickFile({required ImageSource source}) async {
    try {
      XFile? image = await _imagePicker.pickImage(source: source);
      if (image == null) return;
      Get.back();
      profileImage.value = image.path;
      update();
    } catch (e) {
      ShowToastDialog.showToast("Failed to Pick : \n $e");
    }
  }

  @override
  void onInit() {
    getArgument();
    super.onInit();
  }

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneNumberController.dispose();
    referralCodeController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  Rx<UserModel> userModel = UserModel().obs;

  getArgument() async {
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      userModel.value = argumentData['userModel'];
      userTitle.value = userModel.value.userTitle ?? "Mr";
      loginType.value = userModel.value.loginType.toString();
      if (loginType.value == Constant.phoneLoginType) {
        phoneNumberController.text = userModel.value.phoneNumber.toString();
        countryCode.value = userModel.value.countryCode.toString();
      } else {
        emailController.text = userModel.value.email.toString();
        String full = userModel.value.fullName.toString();
        if (full.isNotEmpty && full != "null") {
          List<String> parts = full.split(" ");
          firstNameController.text = parts[0];
          if (parts.length > 1) {
            lastNameController.text = parts.sublist(1).join(" ");
          }
        }
      }
      log("------->${loginType.value}");
    }
    update();
  }
}
