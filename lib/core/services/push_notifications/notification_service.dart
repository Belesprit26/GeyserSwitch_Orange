import 'dart:io';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:gs_orange/core/services/injection_container.dart';

class NotificationService {
  // Firebase Messaging instance
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Flutter Local Notifications Plugin
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  // Reference to the current user
  final User? _currentUser = sl<FirebaseAuth>().currentUser;

  // Reference to the database path for storing tokens
  late DatabaseReference databaseReference;

  NotificationService() {
    if (_currentUser != null) {
      databaseReference = FirebaseDatabase.instance
          .ref()
          .child("GeyserSwitch")
          .child(_currentUser!.uid)
          .child("ServiceInfo");
    }
  }

  // Request notification permissions
  static Future<void> requestNotificationPermissions(BuildContext context) async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: false,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );

    if (settings.authorizationStatus != AuthorizationStatus.authorized) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Notification permissions are denied')),
      );
    }
  }

  // Fetch and store the device token
  Future<void> getDeviceToken() async {
    try {
      // Check platform
      if (Platform.isIOS) {
        // Request provisional authorization for iOS
        await messaging.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
      }

      String? token;
      try {
        token = await messaging.getToken(
          vapidKey: Platform.isIOS ? null : 'YOUR_VAPID_KEY', // Only for web
        );
      } catch (e) {
        if (kDebugMode) {
          print('Error getting FCM token: $e');
        }
        // Return early if we can't get the token
        return;
      }

      if (kDebugMode) {
        print('FCM Token: $token');
      }

      if (token != null && _currentUser != null) {
        try {
          // Store the token in the database under 'notificationTokens'
          await databaseReference.child('notificationTokens').update({
            token: true,
          });

          // Listen for token refresh
          messaging.onTokenRefresh.listen((newToken) async {
            if (kDebugMode) {
              print('Token refreshed: $newToken');
            }
            try {
              await databaseReference.child('notificationTokens').update({
                newToken: true,
              });
            } catch (e) {
              if (kDebugMode) {
                print('Error storing refreshed token: $e');
              }
            }
          });
        } catch (e) {
          if (kDebugMode) {
            print('Error storing FCM token: $e');
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Fatal error in getDeviceToken: $e');
      }
    }
  }

  // Initialize local notifications
  void initLocalNotifications(BuildContext context) {
    const AndroidInitializationSettings androidInitializationSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosInitializationSettings =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
    );

    _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap when the app is in the foreground
        print('Notification tapped with payload: ${response.payload}');
        // Open the app normally
      },
    );

    // Ensure Android notification channel exists
    _ensureAndroidHighImportanceChannel();
  }

  // Set up Firebase messaging listeners
  void firebaseInit(BuildContext context) {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('Received a message while in the foreground!');
        print('Message data: ${message.data}');
      }

      if (message.notification != null) {
        // Show a local notification
        showNotification(message);
      }
    });

    // Handle background and terminated state messages
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Open the app normally;
      print('Notification opened from background state.');
    });

    // For handling when the app is terminated
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        // Open the app normally
        print('Notification opened from terminated state.');
      }
    });
  }

  // Show a local notification
  Future<void> showNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'high_importance_channel',
        'High Importance Notifications',
        channelDescription: 'This channel is used for important notifications.',
        importance: Importance.max,
        priority: Priority.high,
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
      );

      await _flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        notificationDetails,
        payload: 'Default_Sound',
      );
    }
  }

  // Create the high importance channel on Android (O+)
  Future<void> _ensureAndroidHighImportanceChannel() async {
    if (!Platform.isAndroid) return;
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.max,
    );
    final androidPlugin = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(channel);
  }

  Future<void> sendNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    if (_currentUser == null) {
      return;
    }

    // Fetch all device tokens for the current user
    DataSnapshot snapshot = await databaseReference.child('notificationTokens').get();

    if (snapshot.exists) {
      Map<dynamic, dynamic> tokensMap = snapshot.value as Map<dynamic, dynamic>;
      List<String> tokens = tokensMap.keys.cast<String>().toList();

      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('sendNotification');

      try {
        final response = await callable.call({
          'tokens': tokens,
          'title': title,
          'body': body,
          'data': data,
        });
        if (kDebugMode) {
          print('Notification sent successfully: ${response.data}');
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error sending notification: $e');
        }
      }
    } else {
      if (kDebugMode) {
        print('No tokens found for user.');
      }
    }
  }
}