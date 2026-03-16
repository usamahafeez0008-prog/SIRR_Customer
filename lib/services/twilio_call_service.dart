/*
import 'dart:io';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_callkit_incoming/entities/call_event.dart' show Event;
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:uuid/uuid.dart';

class CallService {
  static final CallService _instance = CallService._internal();

  factory CallService() => _instance;

  CallService._internal();

  // On Android, Firebase is initialized with a named app 'customer'.
  // Using FirebaseFunctions.instance would reference the default (uninitialized)
  // app and cause an [unauthenticated] error. We must use the named app instead.
  FirebaseFunctions get functions {
    if (Platform.isAndroid) {
      print('[CallService] Using named Firebase app: customer');
      return FirebaseFunctions.instanceFor(app: Firebase.app('customer'));
    } else {
      print('[CallService] Using default Firebase app (iOS)');
      return FirebaseFunctions.instance;
    }
  }

  Future<void> initialize() async {
    print('[CallService] initialize() called');
    await FirebaseMessaging.instance.requestPermission();
    print('[CallService] FCM permission requested');

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('[CallService] FCM message received — type: ${message.data['type']}');
      if (message.data['type'] == 'incoming_call') {
        showIncomingCall(
          callerName: message.data['callerName'] ?? 'User',
          callId: message.data['callId'],
        );
      }
    });

    FlutterCallkitIncoming.onEvent.listen((event) {
      switch (event!.event) {
        case Event.actionCallAccept:
          print("Accepted");
          break;

        case Event.actionCallDecline:
          print("Declined");
          break;

        case Event.actionCallEnded:
          print("Ended");
          break;
        case Event.actionDidUpdateDevicePushTokenVoip:
          // TODO: Handle this case.
          throw UnimplementedError();
        case Event.actionCallIncoming:
          // TODO: Handle this case.
          throw UnimplementedError();
        case Event.actionCallStart:
          // TODO: Handle this case.
          throw UnimplementedError();
        case Event.actionCallTimeout:
          // TODO: Handle this case.
          throw UnimplementedError();
        case Event.actionCallConnected:
          // TODO: Handle this case.
          throw UnimplementedError();
        case Event.actionCallCallback:
          // TODO: Handle this case.
          throw UnimplementedError();
        case Event.actionCallToggleHold:
          // TODO: Handle this case.
          throw UnimplementedError();
        case Event.actionCallToggleMute:
          // TODO: Handle this case.
          throw UnimplementedError();
        case Event.actionCallToggleDmtf:
          // TODO: Handle this case.
          throw UnimplementedError();
        case Event.actionCallToggleGroup:
          // TODO: Handle this case.
          throw UnimplementedError();
        case Event.actionCallToggleAudioSession:
          // TODO: Handle this case.
          throw UnimplementedError();
        case Event.actionCallCustom:
          // TODO: Handle this case.
          throw UnimplementedError();
      }
    });
  }

  Future<String> getTwilioToken() async {
    print('[CallService] getTwilioToken() — calling getTwilioAccessToken function...');
    final callable = functions.httpsCallable('getTwilioAccessToken');

    final result = await callable.call();
    print('[CallService] getTwilioToken() — token received successfully');

    return result.data['token'];
  }

  Future<void> placeCall({
    required String receiverUid,
    required String callerName,
  }) async {
    final callId = const Uuid().v4();
    print('[CallService] placeCall() — receiverUid: $receiverUid | callerName: $callerName | callId: $callId');

    final callable = functions.httpsCallable('sendCallNotification');
    print('[CallService] placeCall() — calling sendCallNotification cloud function...');

    try {
      await callable.call({
        "receiverUid": receiverUid,
        "callerName": callerName,
        "callId": callId,
      });
      print('[CallService] placeCall() — sendCallNotification SUCCESS ✓');

      print('[CallService] placeCall() — showing outgoing call UI...');
      await showOutgoingCall(
        callerName: callerName,
        callId: callId,
      );
    } catch (e) {
      print('[CallService] placeCall() — ERROR: $e');
    }
  }

  Future<void> showIncomingCall({
    required String callerName,
    required String callId,
  }) async {
    print('[CallService] showIncomingCall() — callerName: $callerName | callId: $callId');
    final params = {
      'id': callId,
      'nameCaller': callerName,
      'appName': 'SIIR',
      'avatar': '',
      'handle': 'Voice Call',
      'type': 0,
      'duration': 30000,
      'textAccept': 'Accept',
      'textDecline': 'Decline',
      'extra': {
        'callId': callId,
      },
      'android': {
        'isCustomNotification': true,
        'isShowLogo': false,
        'ringtonePath': 'system_ringtone_default',
      },
      'ios': {
        'iconName': 'CallKitLogo',
      }
    };

    await FlutterCallkitIncoming.showCallkitIncoming(params as CallKitParams);
  }

  Future<void> showOutgoingCall({
    required String callerName,
    required String callId,
  }) async {
    print('[CallService] showOutgoingCall() — callerName: $callerName | callId: $callId');
    final params = {
      'id': callId,
      'nameCaller': callerName,
      'appName': 'SIIR',
      'avatar': '',
      'handle': 'Calling...',
      'type': 0,
      'duration': 30000,
      'textAccept': '',
      'textDecline': 'End',
      'extra': {
        'callId': callId,
      },
      'android': {
        'isCustomNotification': true,
        'isShowLogo': false,
      },
      'ios': {
        'iconName': 'CallKitLogo',
      }
    };

    await FlutterCallkitIncoming.showCallkitIncoming(params as CallKitParams);
  }

  Future<void> endCall(String callId) async {
    print('[CallService] endCall() — callId: $callId');
    await FlutterCallkitIncoming.endCall(callId);
    print('[CallService] endCall() — call ended');
  }
}*/
