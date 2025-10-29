import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:gs_orange/core/services/push_notifications/notification_service.dart';

/// Central place to initialize app-wide bootstrapped services.
///
/// Usage pattern (proposed):
/// 1) Call AppBootstrap.preRun() after Firebase.initializeApp and before runApp
/// 2) Call AppBootstrap.postRun(context) early after app start (e.g., in root widget)
class AppBootstrap {
  const AppBootstrap._();

  static bool _postRunInitialized = false;

  static Future<void> preRun() async {
    if (Platform.isAndroid) {
      final status = await Permission.notification.status;
      if (status.isDenied || status.isRestricted) {
        await Permission.notification.request();
      }
    }

    if (Platform.isIOS) {
      // Ensure iOS displays notifications in foreground
      await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  static Future<void> postRun(BuildContext context) async {
    if (_postRunInitialized) return;
    _postRunInitialized = true;

    final notificationService = NotificationService();
    notificationService.initLocalNotifications(context);
    notificationService.firebaseInit(context);
    // Optionally: NotificationService.requestNotificationPermissions(context);
  }
}


