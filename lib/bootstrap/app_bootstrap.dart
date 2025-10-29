import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:gs_orange/core/services/push_notifications/notification_service.dart';

/// Central place to initialize app-wide bootstrapped services.
///
/// Usage pattern:
/// 1) Call AppBootstrap.preRun() after Firebase.initializeApp and before runApp
/// 2) Call AppBootstrap.postRun(context) early after app start (e.g., in root widget)
class AppBootstrap {
  const AppBootstrap._();

  static bool _postRunInitialized = false;
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  static Future<void> preRun() async {
    // Android 13+ notifications permission
    if (Platform.isAndroid) {
      final status = await Permission.notification.status;
      if (status.isDenied || status.isRestricted) {
        await Permission.notification.request();
      }
    }

    // Ensure iOS displays notifications in foreground
    if (Platform.isIOS) {
      // Request iOS notification permission
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      // Ensure notifications show in foreground
      await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    // Enable analytics collection (toggle here if needed)
    await _analytics.setAnalyticsCollectionEnabled(true);

    // Global error handlers (toggle or extend to Crashlytics if added)
    _configureGlobalErrorHandlers();
  }

  static Future<void> postRun(BuildContext context) async {
    if (_postRunInitialized) return;
    _postRunInitialized = true;

    final notificationService = NotificationService();
    notificationService.initLocalNotifications(context);
    await notificationService.getDeviceToken();
    notificationService.firebaseInit(context);

    // Log app open
    await _analytics.logAppOpen();
  }

  static void _configureGlobalErrorHandlers() {
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      debugPrint('FlutterError: \\n${details.exceptionAsString()}');
    };
    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      debugPrint('Uncaught zone error: $error');
      return false; // allow default behavior
    };
  }
}


