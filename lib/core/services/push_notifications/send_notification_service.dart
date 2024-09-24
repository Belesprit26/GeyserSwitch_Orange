// ignore_for_file: avoid_print
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;

class SendNotificationService {
  static Future<void> sendNotificationUsingApi({
    required String? token,
    required String? title,
    required String? body,
    required Map<String, dynamic>? data,
  }) async {
    final _currentUser = FirebaseAuth.instance.currentUser;
    String? serverToken;

    if (_currentUser != null) {
      try {
        // Define the reference to the 'serverToken' path
        DatabaseReference databaseReference = FirebaseDatabase.instance
            .ref()
            .child("GeyserSwitch")
            .child(_currentUser.uid)
            .child("ServiceInfo");

        // Fetch the server token from Firebase
        DataSnapshot snapshot = await databaseReference.child('serverToken').get();

        if (snapshot.exists) {
          serverToken = snapshot.value as String;
          print("Server Token: $serverToken");
        } else {
          print("No serverToken found.");
          return; // Exit if no server token is found
        }
      } catch (e) {
        print("Error fetching serverToken: $e");
        return; // Exit if there's an error fetching the server token
      }
    } else {
      print("Error: No authenticated user.");
      return; // Exit if no user is authenticated
    }

    // URL for FCM HTTP v1 API
    String url =
        "https://fcm.googleapis.com/v1/projects/geyserswitch-bloc/messages:send";

    // Prepare the headers
    var headers = <String, String>{
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $serverToken', // Use the fetched server token
    };

    // Message body
    Map<String, dynamic> message = {
      "message": {
        "token": token,
        "notification": {
          "body": body,
          "title": title,
        },
        "data": data,
        "android": {
          "notification": {
            "click_action": "TOP_STORY_ACTIVITY"
          }
        },
        "apns": {
          "headers": {
            "apns-priority": "10",
            "apns-push-type": "alert",
            "apns-topic": "com.geyserswitch.gsOrange",  // Your app's bundle identifier
            "apns-expiration": "0"
          },
          "payload": {
            "aps": {
              "category": "NEW_MESSAGE_CATEGORY",
              "alert": {
                "title": title,
                "body": body,
              }
            }
          }
        }
      }
    };

    try {
      // Send the POST request to the FCM API
      final http.Response response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(message),
      );

      // Check the response
      if (response.statusCode == 200) {
        print("Notification sent successfully!");
      } else {
        print("Failed to send notification. Status Code: ${response.statusCode}");
        print("Response: ${response.body}");
      }
    } catch (e) {
      print("Error sending notification: $e");
    }
  }
}