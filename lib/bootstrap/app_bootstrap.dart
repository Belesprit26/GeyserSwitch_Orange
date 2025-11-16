import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gs_orange/core/services/push_notifications/notification_service.dart';
import 'package:gs_orange/bootstrap/device_info_service.dart';
import 'package:gs_orange/core/services/injection_container_exports.dart';
import 'package:gs_orange/core/utils/last_updated_store.dart';
import 'package:gs_orange/src/ble/domain/repos/ble_repo.dart';
import 'package:gs_orange/src/ble/presentation/services/ble_sync_service.dart';
import 'package:gs_orange/src/ble/presentation/services/ble_background_service.dart';
import 'package:gs_orange/src/ble/presentation/providers/mode_provider.dart';

/// Central place to initialize app-wide bootstrapped services.
///
/// Usage pattern:
/// 1) Call AppBootstrap.preRun() after Firebase.initializeApp and before runApp
/// 2) Call AppBootstrap.postRun(context) early after app start (e.g., in root widget)
class AppBootstrap {
  const AppBootstrap._();

  static bool _postRunInitialized = false;
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  static bool _authListenerBound = false;

  static Future<void> preRun() async {
    // Enable analytics collection (toggle here if needed)
    await _analytics.setAnalyticsCollectionEnabled(true);

    // Global error handlers (toggle or extend to Crashlytics if added)
    _configureGlobalErrorHandlers();
    
    // Note: Permission requests moved to postRun() to avoid blocking app initialization
    // This prevents stalling when user takes time to respond to permission dialogs
  }

  static Future<void> postRun(BuildContext context) async {
    if (_postRunInitialized) return;
    _postRunInitialized = true;

    // Request permissions AFTER app is initialized to avoid blocking startup
    // Use a small delay to ensure the UI is ready before showing permission dialogs
    Future.delayed(const Duration(milliseconds: 300), () async {
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
    });

    final notificationService = NotificationService();
    notificationService.initLocalNotifications(context);
    await notificationService.getDeviceToken();
    notificationService.firebaseInit(context);
    await notificationService.resetIOSBadge();

    // Initialize BLE background service (Android foreground service, iOS watchdog)
    await BleBackgroundService.instance.initialize();

    // Log app open
    await _analytics.logAppOpen();

    // Attempt BLE auto-reconnect if a device was previously paired
    try {
      final prefs = sl<SharedPreferences>();
      final lastId = prefs.getString('last_ble_device_id');
      if (lastId != null && lastId.isNotEmpty) {
        final ble = sl<BleRepo>();
        await ble.connect(deviceId: lastId);
        await ble.subscribeToNotifications();
        sl<BleSyncService>().start(context);
        await BleBackgroundService.instance.start();
        if (context.mounted) {
          context.read<ModeProvider>().setLocal();
        }
      }
    } catch (_) {
      // Ignore auto-reconnect failures
    }

    // Upsert device info now and on login changes (max once per 7 days)
    final deviceInfoService = DeviceInfoService();
    if (await LastUpdatedStore.isStale('device_info', const Duration(days: 1))) {
      await deviceInfoService.upsertForCurrentUser();
      await LastUpdatedStore.setNow('device_info');
    }
    if (!_authListenerBound) {
      _authListenerBound = true;
      final auth = sl<FirebaseAuth>();
      auth.authStateChanges().listen((User? user) async {
        if (user != null) {
          if (await LastUpdatedStore.isStale('device_info', const Duration(days: 1))) {
            await deviceInfoService.upsertForCurrentUser();
            await LastUpdatedStore.setNow('device_info');
          }
        }
      });
    }
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


