import 'package:customer/constant/zego_config.dart';
import 'package:get/get.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

class ZegoCallService {
  static final ZegoCallService _instance = ZegoCallService._internal();

  factory ZegoCallService() {
    return _instance;
  }

  ZegoCallService._internal();

  void initZego(String userId, String userName) {
    ZegoUIKitPrebuiltCallInvitationService().init(
      appID: ZegoConfig.appId,
      appSign: ZegoConfig.appSign,
      userID: userId,
      userName: userName,
      plugins: [ZegoUIKitSignalingPlugin()],
    );
  }

  void uninitZego() {
    ZegoUIKitPrebuiltCallInvitationService().uninit();
  }
}
