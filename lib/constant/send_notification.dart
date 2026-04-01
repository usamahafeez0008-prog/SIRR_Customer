// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'dart:developer';
import 'package:customer/constant/constant.dart';
import 'package:flutter/foundation.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:http/http.dart' as http;

class SendNotification {
  static final _scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

  static Future getCharacters() {
    log("Fetching Service Account from: '${Constant.jsonNotificationFileURL}'");
    return http.get(Uri.parse(Constant.jsonNotificationFileURL.toString()));
  }

  static Future<String> getAccessToken() async {
    Map<String, dynamic> jsonData = {};
    log("Getting Access Token...");

    await getCharacters().then((response) {
      log("Service Account JSON Response: ${response.statusCode}");
      jsonData = json.decode(response.body);
    });
    final serviceAccountCredentials =
        ServiceAccountCredentials.fromJson(jsonData);

    final client =
        await clientViaServiceAccount(serviceAccountCredentials, _scopes);
    return client.credentials.accessToken.data;
  }

  static Future<bool> sendOneNotification(
      {required String token,
      required String title,
      required String body,
      required Map<String, dynamic> payload}) async {
    if (token.isEmpty || token == "null") {
      debugPrint("FCM Error: Token is empty or null.");
      return false;
    }
    try {
      debugPrint("Attempting to send notification to $token");
      debugPrint("Current SenderId (Project ID): '${Constant.senderId}'");

      final String accessToken = await getAccessToken();
      debugPrint("Access Token Obtained: ${accessToken.substring(0, 5)}...");
      debugPrint(
          "FCM URL: https://fcm.googleapis.com/v1/projects/${Constant.senderId}/messages:send");

      // Ensure all values in payload are strings for FCM v1
      Map<String, String> stringPayload = {};
      payload.forEach((key, value) {
        stringPayload[key] = value.toString();
      });

      Map<String, dynamic> message = {
        'token': token,
        'notification': {'body': body, 'title': title},
      };

      if (stringPayload.isNotEmpty) {
        message['data'] = stringPayload;
      }

      final response = await http.post(
        Uri.parse(
            'https://fcm.googleapis.com/v1/projects/${Constant.senderId}/messages:send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(
          <String, dynamic>{
            'message': message,
          },
        ),
      );

      debugPrint("FCM Response Status: ${response.statusCode}");
      debugPrint("FCM Response Body: ${response.body}");
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("FCM Error: ${e.toString()}");
      return false;
    }
  }
}
