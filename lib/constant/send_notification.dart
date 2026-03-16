// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'dart:developer';
import 'package:customer/constant/constant.dart';
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
    final serviceAccountCredentials = ServiceAccountCredentials.fromJson(jsonData);

    final client = await clientViaServiceAccount(serviceAccountCredentials, _scopes);
    return client.credentials.accessToken.data;
  }

  static Future<bool> sendOneNotification({required String token, required String title, required String body, required Map<String, dynamic> payload}) async {
    try {
      log("Attempting to send notification to $token");
      log("Current SenderId: '${Constant.senderId}'");
      
      final String accessToken = await getAccessToken();
      log("Access Token Obtained: ${accessToken.substring(0, 5)}...");
      log("FCM URL: https://fcm.googleapis.com/v1/projects/${Constant.senderId}/messages:send");
      log("FCM Token: $token");
      log("FCM Payload: ${jsonEncode(payload)}");

      final response = await http.post(
        Uri.parse('https://fcm.googleapis.com/v1/projects/${Constant.senderId}/messages:send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(
          <String, dynamic>{
            'message': {
              'token': token,
              'notification': {'body': body, 'title': title},
              'data': payload,
            }
          },
        ),
      );

      log("FCM Response Status: ${response.statusCode}");
      log("FCM Response Body: ${response.body}");
      return response.statusCode == 200;
    } catch (e) {
      log("FCM Error: ${e.toString()}");
      return false;
    }
  }
}
