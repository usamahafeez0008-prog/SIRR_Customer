import 'dart:developer';
import 'package:customer/constant/collection_name.dart';
import 'package:customer/constant/show_toast_dialog.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgotPasswordController extends GetxController {
  Rx<TextEditingController> phoneNumberController = TextEditingController().obs;
  Rx<TextEditingController> otpController = TextEditingController().obs;
  Rx<TextEditingController> newPasswordController = TextEditingController().obs;
  Rx<TextEditingController> confirmPasswordController =
      TextEditingController().obs;

  RxString countryCode = "+212".obs;
  RxString verificationId = "".obs;
  RxBool isOtpSent = false.obs;
  RxBool isOtpVerified = false.obs;

  Future<void> sendOtp() async {
    if (phoneNumberController.value.text.isEmpty) {
      ShowToastDialog.showToast("Please enter phone number".tr);
      return;
    }

    ShowToastDialog.showLoader("Verifying user...".tr);
    try {
      // 1. Check if user exists
      final querySnapshot = await FireStoreUtils.fireStore
          .collection(CollectionName.users)
          .where('countryCode', isEqualTo: countryCode.value)
          .where('phoneNumber', isEqualTo: phoneNumberController.value.text)
          .get();

      if (querySnapshot.docs.isEmpty) {
        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast("No account found with this phone number".tr);
        return;
      }

      // 2. Send OTP via Firebase Auth
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: countryCode.value + phoneNumberController.value.text,
        verificationCompleted: (PhoneAuthCredential credential) {},
        verificationFailed: (FirebaseAuthException e) {
          ShowToastDialog.closeLoader();
          ShowToastDialog.showToast("Verification failed: ${e.message}");
        },
        codeSent: (String vid, int? resendToken) {
          verificationId.value = vid;
          isOtpSent.value = true;
          ShowToastDialog.closeLoader();
          ShowToastDialog.showToast("OTP sent successfully".tr);
        },
        codeAutoRetrievalTimeout: (String vid) {
          verificationId.value = vid;
        },
      );
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast("Error: ${e.toString()}");
    }
  }

  Future<void> verifyOtp() async {
    if (otpController.value.text.isEmpty ||
        otpController.value.text.length < 6) {
      ShowToastDialog.showToast("Please enter a valid 6-digit OTP".tr);
      return;
    }

    ShowToastDialog.showLoader("Verifying OTP...".tr);
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId.value,
        smsCode: otpController.value.text,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      isOtpVerified.value = true;
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast("OTP Verified successfully".tr);
    } catch (e) {
      ShowToastDialog.closeLoader();
      ShowToastDialog.showToast("Invalid OTP. Please try again.".tr);
    }
  }

  Future<void> resetPassword() async {
    if (newPasswordController.value.text.isEmpty ||
        confirmPasswordController.value.text.isEmpty) {
      ShowToastDialog.showToast("Please fill all password fields".tr);
      return;
    }

    if (newPasswordController.value.text !=
        confirmPasswordController.value.text) {
      ShowToastDialog.showToast("Passwords do not match".tr);
      return;
    }

    ShowToastDialog.showLoader("Resetting password...".tr);
    try {
      final querySnapshot = await FireStoreUtils.fireStore
          .collection(CollectionName.users)
          .where('countryCode', isEqualTo: countryCode.value)
          .where('phoneNumber', isEqualTo: phoneNumberController.value.text)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        String docId = querySnapshot.docs.first.id;
        await FireStoreUtils.fireStore
            .collection(CollectionName.users)
            .doc(docId)
            .update({'password': newPasswordController.value.text.trim()});

        ShowToastDialog.closeLoader();
        ShowToastDialog.showToast("Password updated successfully".tr);
        Get.back(); // Go back to login
      }
    } catch (e) {
      ShowToastDialog.closeLoader();
      log("Error resetting password: $e");
      ShowToastDialog.showToast(
          "Failed to reset password. Please try again.".tr);
    }
  }
}
