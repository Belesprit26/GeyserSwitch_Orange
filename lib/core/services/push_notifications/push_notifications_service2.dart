import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:permission_handler/permission_handler.dart';

class PushNotificationService2 {
  final _currentUser = FirebaseAuth.instance.currentUser;
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  DatabaseReference databaseReference = FirebaseDatabase.instance
      .ref()
      .child("GeyserSwitch")
      .child(FirebaseAuth.instance.currentUser!.uid)
      .child("ServiceInfo");

  // Initialize Firebase messaging and request necessary permissions
  Future<void> initialize() async {
    await Firebase.initializeApp();
    await init(); // Initialize local notifications
    await askNotificationsPermissions();

    // Handle when app is terminated and opened from a notification
    RemoteMessage? initialMessage =
    await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    // Handle background notifications (when app is opened from notification)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleMessage(message);
    });

    // Handle foreground notifications
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Foreground notification received: ${message.notification?.title}');
      showNotification(message);
    });
  }

  // Function to request permissions for iOS and check permissions for Android
  Future<void> askNotificationsPermissions() async {
    // Check and request notification permission using permission_handler for Android/iOS
    if (await Permission.notification.isGranted) {
      print('Notification permission already granted.');
    } else {
      // Request notification permission
      PermissionStatus status = await Permission.notification.request();
      if (status.isGranted) {
        print('Notification permission granted.');
      } else {
        print('Notification permission denied.');
      }
    }

    // For iOS, use Firebase Messaging to request permissions
    await requestIOSPermissions();
  }

  // Request iOS-specific permissions using Firebase Messaging
  Future<void> requestIOSPermissions() async {
    NotificationSettings settings = await firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission for notifications.');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('User granted provisional permission for notifications.');
    } else {
      print('User declined notification permissions.');
    }
  }

  // Function to generate a device recognition token and store it in Firebase Realtime Database
  Future<String?> generateDeviceRecognitionToken() async {
    try {
      await firebaseMessaging.getToken().then((token) async {
        print("Device Token: $token");
        await databaseReference.set({
          'notificationToken': token,
          'email': _currentUser!.email,
          'name': _currentUser!.displayName,
        });
      });

      await firebaseMessaging.onTokenRefresh.listen((token) async {
        print("Token refreshed: $token");
        await databaseReference.set({
          'notificationToken': token,
          'email': _currentUser!.email,
          'name': _currentUser!.displayName,
        });
      });
    } catch (e) {
      print(e.toString());
    }
  }

  // Function to initialize local notifications for Android and iOS
  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS (Darwin) settings for version ^17.2.2
    final DarwinInitializationSettings initializationSettingsDarwin =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification: onDidReceiveLocalNotification,
    );

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin, // Corrected for iOS
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse, // Updated method
    );

    // Create Android Notification Channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'com.google.firebase.messaging.default_notification_channel_id',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.max,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    print('Notification Channel created!');
  }

  // Handle what happens when a notification is received in foreground (iOS-specific)
  Future onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) async {
    print("Received Local Notification: $title");
  }

  // Handle what happens when the user taps on a notification (Updated for v17.x)
  Future<void> onDidReceiveNotificationResponse(
      NotificationResponse notificationResponse) async {
    print("Notification tapped: ${notificationResponse.payload}");
  }

  // Function to show notification
  Future<void> showNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails(
      'channel_id',
      'Channel Name',
      channelDescription: 'Channel Description',
      icon: '@mipmap/ic_launcher',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const DarwinNotificationDetails iosNotificationDetails =
    DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      message.hashCode,
      message.notification?.title ?? 'Notification',
      message.notification?.body ?? 'You have received a notification',
      platformChannelSpecifics,
    );
  }

  // Function to handle message when app is opened from a notification
  void _handleMessage(RemoteMessage message) {
    print('Message data: ${message.data}');
    if (message.notification != null) {
      print('Notification Title: ${message.notification!.title}');
      print('Notification Body: ${message.notification!.body}');
    }
    // Handle navigation or specific logic based on message data
  }

  // Background message handler
  static Future<void> firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    await Firebase.initializeApp();
    print('Handling a background message: ${message.messageId}');
  }
}