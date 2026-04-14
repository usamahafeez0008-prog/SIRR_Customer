import 'package:customer/model/order_model.dart';
import 'package:customer/model/user_model.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:get/get.dart';

class OrderDetailsController extends GetxController {
  Rx<UserModel> userModel = UserModel().obs;
  Rx<OrderModel> orderModel = OrderModel().obs;
  RxBool isReady = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initData();
  }

  Future<void> _initData() async {
    try {
      final dynamic argumentData = Get.arguments;

      if (argumentData != null && argumentData['orderModel'] != null) {
        orderModel.value = argumentData['orderModel'] as OrderModel;
      }

      final value = await FireStoreUtils.getUserProfile(FireStoreUtils.getCurrentUid());
      if (value != null) {
        userModel.value = value;
      }
    } catch (e) {
      print("OrderDetailsController init error: $e");
    } finally {
      isReady.value = true;
      update();
    }
  }
}

/*
import 'package:customer/model/order_model.dart';
import 'package:customer/model/user_model.dart';
import 'package:customer/utils/fire_store_utils.dart';
import 'package:get/get.dart';

class OrderDetailsController extends GetxController {

  Rx<UserModel> userModel = UserModel().obs;
  Rx<OrderModel> orderModel = OrderModel().obs;

  @override
  void onInit() {
    // TODO: implement onInit
    getArgument();
    getUser();
    super.onInit();
  }



  getArgument() async {
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      orderModel.value = argumentData['orderModel'];
    }
    update();
  }

  getUser() async {
    await FireStoreUtils.getUserProfile(FireStoreUtils.getCurrentUid()).then((value) {
      if (value != null) {
        userModel.value = value;
      }
    });
  }
}
*/
