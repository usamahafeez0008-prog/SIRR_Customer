import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/constant/collection_name.dart';
import 'package:customer/model/user_model.dart';
import 'package:customer/ui/auth_screen/dummay_screen.dart';
import 'package:customer/ui/dashboard_screen.dart';
import 'package:customer/utils/Preferences.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constant/show_toast_dialog.dart';

class LoginWithPasswordController extends GetxController {
  Rx<TextEditingController> phoneNumberController = TextEditingController().obs;
  RxString countryCode = "+212".obs;

  @override
  void onInit() {
    super.onInit();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    String savedPhone = Preferences.getString('savedPhone');
    String savedCountryCode = Preferences.getString('savedCountryCode');

    if (savedPhone.isNotEmpty) {
      phoneNumberController.value.text = savedPhone;
    }
    if (savedCountryCode.isNotEmpty) {
      countryCode.value = savedCountryCode;
    }
  }

  Future<void> loginWithPassword(String password) async {
    if (phoneNumberController.value.text.isEmpty || password.isEmpty) {
      ShowToastDialog.showToast(
          "Please enter both phone number and password".tr);
      return;
    }

    ShowToastDialog.showLoader("Logging in...".tr);
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection(CollectionName.users)
          .where('countryCode', isEqualTo: countryCode.value)
          .where('phoneNumber', isEqualTo: phoneNumberController.value.text)
          .where('password', isEqualTo: password)
          .get();

      ShowToastDialog.closeLoader();

      if (querySnapshot.docs.isNotEmpty) {
        var docData = querySnapshot.docs.first.data();
        UserModel userModel = UserModel.fromJson(docData);

        if (userModel.isActive == true) {
          Preferences.setString('userId', querySnapshot.docs.first.id);

          // Save credentials for autofill next time
          Preferences.setString('savedPhone', phoneNumberController.value.text);
          Preferences.setString('savedCountryCode', countryCode.value);
          Preferences.setString('savedPassword', password);

          ShowToastDialog.showToast("Login Successful".tr);
          Get.offAll(() => const DashBoardScreen(),
              arguments: {'userModel': userModel});
        } else {
          ShowToastDialog.showToast(
              'This account has been disabled. Please contact administrator.'
                  .tr);
        }
      } else {
        ShowToastDialog.showToast(
            "Incorrect credentials or account not found".tr);
      }
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast("Error: ${e.toString()}");
    }
  }
}
