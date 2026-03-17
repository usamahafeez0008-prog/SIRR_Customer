import 'package:flutter/foundation.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

import '../constant/zego_config.dart';

class ZegoCallService {
  static final ZegoCallService _instance = ZegoCallService._internal();

  factory ZegoCallService() {
    return _instance;
  }

  ZegoCallService._internal();

  bool _initialized = false;
  String? _currentUserId;

  Future<void> initZego(String userId, String userName) async {
    if (userId.isEmpty) return;

    // Avoid duplicate init for same user
    if (_initialized && _currentUserId == userId) {
      debugPrint('Zego already initialized for user: $userId');
      return;
    }

    // If switching users on same device, clear old session first
    if (_initialized && _currentUserId != userId) {
      await ZegoUIKitPrebuiltCallInvitationService().uninit();
      _initialized = false;
      _currentUserId = null;
    }

    await ZegoUIKitPrebuiltCallInvitationService().init(
      appID: ZegoConfig.appId,
      appSign: ZegoConfig.appSign,
      userID: userId,
      userName: userName,
      plugins: [ZegoUIKitSignalingPlugin()],
      notificationConfig: ZegoCallInvitationNotificationConfig(
        androidNotificationConfig: ZegoAndroidNotificationConfig(
          channelID: "zego_call",
          channelName: "Call",
          sound: "zego_incoming",
          icon: "ic_launcher",
        ),
        iOSNotificationConfig: ZegoIOSNotificationConfig(),
      ),
      invitationEvents: ZegoUIKitPrebuiltCallInvitationEvents(
        onIncomingCallReceived: (callID, inviter, type, invitees, customData) {
          debugPrint(
            'Incoming call received => callID: $callID, inviter: ${inviter.id}, type: $type',
          );
        },
        onIncomingCallAcceptButtonPressed: () {
          debugPrint('Incoming call accept button pressed');
        },
        onIncomingCallDeclineButtonPressed: () {
          debugPrint('Incoming call decline button pressed');
        },
        onOutgoingCallAccepted: (callID, callee) {
          debugPrint('Outgoing call accepted => callID: $callID, callee: ${callee.id}');
        },
        onOutgoingCallRejectedCauseBusy: (callID, callee, customData) {
          debugPrint('Outgoing call busy => callID: $callID, callee: ${callee.id}');
        },
        onOutgoingCallDeclined: (callID, callee, customData) {
          debugPrint('Outgoing call declined => callID: $callID, callee: ${callee.id}');
        },
      ),
    );

    _initialized = true;
    _currentUserId = userId;

    debugPrint('Zego initialized successfully for user: $userId');
  }

  Future<void> uninitZego() async {
    await ZegoUIKitPrebuiltCallInvitationService().uninit();
    _initialized = false;
    _currentUserId = null;
    debugPrint('Zego uninitialized');
  }
}

/*// import 'package:customer/constant/show_toast_dialog.dart';
// import 'package:customer/constant/zego_config.dart';
// import 'package:get/get.dart';
// import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
// import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';
//
// class ZegoCallService {
//   static final ZegoCallService _instance = ZegoCallService._internal();
//
//   factory ZegoCallService() {
//     return _instance;
//   }
//
//   ZegoCallService._internal();
//
//   void initZego(String userId, String userName) {
//     ZegoUIKitPrebuiltCallInvitationService().uninit(); // Clear previous session if any
//     ZegoUIKitPrebuiltCallInvitationService().init(
//       appID: ZegoConfig.appId,
//       appSign: ZegoConfig.appSign,
//       userID: userId,
//       userName: userName,
//       plugins: [ZegoUIKitSignalingPlugin()],
//       notificationConfig: ZegoCallInvitationNotificationConfig(
//         androidNotificationConfig: ZegoAndroidNotificationConfig(
//           channelID: "zego_call",
//           channelName: "Call",
//           sound: "zego_incoming",
//           icon: "ic_launcher",
//         ),
//         iOSNotificationConfig: ZegoIOSNotificationConfig(),
//       ),
//       invitationEvents: ZegoUIKitPrebuiltCallInvitationEvents(
//         onIncomingCallReceived: (callID, inviter, type, invitees, customData) {
//           // Handle incoming call if needed
//         },
//         onIncomingCallDeclineButtonPressed: () {},
//         onIncomingCallAcceptButtonPressed: () {},
//         onOutgoingCallAccepted: (callID, callee) {},
//         onOutgoingCallRejectedCauseBusy: (callID, callee, customData) {
//           ShowToastDialog.showToast("Recipient is busy");
//         },
//         onOutgoingCallDeclined: (callID, callee, customData) {
//           ShowToastDialog.showToast("Call declined");
//         },
//       ),
//     );
//   }
//
//   void uninitZego() {
//     ZegoUIKitPrebuiltCallInvitationService().uninit();
//   }
// }*/
