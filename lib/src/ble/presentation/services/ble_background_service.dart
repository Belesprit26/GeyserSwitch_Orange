import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:gs_orange/core/services/injection_container_exports.dart';
import 'package:gs_orange/src/ble/domain/repos/ble_repo.dart';
import 'package:gs_orange/src/ble/domain/events/ble_events.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages BLE background service for Android foreground service and iOS background handling.
/// 
/// Android: Runs as a foreground service with persistent notification to keep BLE alive.
/// iOS: Relies on CoreBluetooth background mode and heartbeat watchdog for auto-reconnect.
class BleBackgroundService {
  static BleBackgroundService? _instance;
  static BleBackgroundService get instance => _instance ??= BleBackgroundService._();
  
  BleBackgroundService._();

  FlutterBackgroundService? _service;
  StreamSubscription<BleHeartbeat>? _heartbeatSub;
  StreamSubscription<bool>? _connectedSub;
  StreamSubscription<BleAlert>? _alertSub;
  Timer? _heartbeatWatchdog;
  DateTime? _lastHeartbeat;
  bool _isServiceRunning = false;

  /// Initialize and start the background service (Android only).
  Future<void> initialize() async {
    if (Platform.isAndroid) {
      await _initializeAndroidService();
    } else if (Platform.isIOS) {
      await _initializeIOSWatchdog();
    }
  }

  /// Start the background service when BLE connects in Local Mode.
  Future<void> start() async {
    if (_isServiceRunning) return;
    
    if (Platform.isAndroid) {
      await _startAndroidService();
    } else if (Platform.isIOS) {
      await _startIOSWatchdog();
    }
    
    _isServiceRunning = true;
  }

  /// Stop the background service when switching to Remote Mode or disconnecting.
  Future<void> stop() async {
    if (!_isServiceRunning) return;
    
    _heartbeatWatchdog?.cancel();
    _heartbeatWatchdog = null;
    _heartbeatSub?.cancel();
    _heartbeatSub = null;
    _connectedSub?.cancel();
    _connectedSub = null;
    _alertSub?.cancel();
    _alertSub = null;
    _lastHeartbeat = null;

    if (Platform.isAndroid && _service != null) {
      final service = FlutterBackgroundService();
      final isRunning = await service.isRunning();
      if (isRunning) {
        service.invoke('stop');
      }
    }
    
    _isServiceRunning = false;
  }

  Future<void> _initializeAndroidService() async {
    final service = FlutterBackgroundService();
    _service = service;

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'ble_background_channel',
      'BLE Background Service',
      description: 'Keeps Bluetooth connection alive for GeyserSwitch',
      importance: Importance.low,
    );

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: false,
        isForegroundMode: true,
        notificationChannelId: 'ble_background_channel',
        initialNotificationTitle: 'GeyserSwitch',
        initialNotificationContent: 'Connected to GeyserSwitch',
        foregroundServiceNotificationId: 888,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );
  }

  Future<void> _startAndroidService() async {
    if (_service == null) return;
    final isRunning = await _service!.isRunning();
    if (!isRunning) {
      await _service!.startService();
    }
    _service!.invoke('start');
  }

  Future<void> _initializeIOSWatchdog() async {
    // iOS relies on CoreBluetooth background mode (already configured in Info.plist)
    // We just need to set up heartbeat monitoring
  }

  Future<void> _startIOSWatchdog() async {
    final bleRepo = sl<BleRepo>();
    
    // Monitor heartbeat to detect disconnections
    _heartbeatSub = bleRepo.heartbeat$.listen((_) {
      _lastHeartbeat = DateTime.now();
    });

    // Monitor connection state
    _connectedSub = bleRepo.connected$.listen((isConnected) {
      if (isConnected) {
        _lastHeartbeat = DateTime.now();
        _startHeartbeatWatchdog();
      } else {
        _heartbeatWatchdog?.cancel();
        _heartbeatWatchdog = null;
      }
    });

    // Monitor alerts for background notifications
    _alertSub = bleRepo.alert$.listen((alert) {
      if (alert.triggered) {
        // Alert notifications are handled by BleSyncService
        // This is just for background state tracking
      }
    });

    // Start watchdog if already connected
    // Check connection state by listening to the stream briefly
    final connectedSub = bleRepo.connected$.listen((isConnected) {
      if (isConnected) {
        _lastHeartbeat = DateTime.now();
        _startHeartbeatWatchdog();
      }
    });
    
    // Cancel after getting initial state
    Future.delayed(const Duration(milliseconds: 500), () {
      connectedSub.cancel();
    });
  }

  void _startHeartbeatWatchdog() {
    _heartbeatWatchdog?.cancel();
    
    // Check every 10 seconds if heartbeat is stale (>60s)
    _heartbeatWatchdog = Timer.periodic(const Duration(seconds: 10), (_) async {
      if (_lastHeartbeat == null) return;
      
      final elapsed = DateTime.now().difference(_lastHeartbeat!);
      if (elapsed.inSeconds > 60) {
        // Heartbeat timeout - attempt reconnect
        debugPrint('BLE heartbeat timeout detected, attempting reconnect...');
        await _attemptReconnect();
      }
    });
  }

  Future<void> _attemptReconnect() async {
    try {
      final prefs = sl<SharedPreferences>();
      final lastDeviceId = prefs.getString('last_ble_device_id');
      
      if (lastDeviceId == null || lastDeviceId.isEmpty) {
        return;
      }

      final bleRepo = sl<BleRepo>();
      
      // Check if already connected by listening briefly
      bool? isConnected;
      final checkSub = bleRepo.connected$.listen((connected) {
        isConnected = connected;
      });
      
      await Future.delayed(const Duration(milliseconds: 500));
      checkSub.cancel();
      
      if (isConnected == true) {
        // Already connected, reset heartbeat
        _lastHeartbeat = DateTime.now();
        return;
      }

      // Attempt reconnect with exponential backoff
      await _reconnectWithBackoff(bleRepo, lastDeviceId);
    } catch (e) {
      debugPrint('BLE reconnect attempt failed: $e');
    }
  }

  Future<void> _reconnectWithBackoff(BleRepo bleRepo, String deviceId) async {
    const maxRetries = 5;
    const initialDelay = Duration(seconds: 2);
    
    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        final delay = Duration(
          seconds: (initialDelay.inSeconds * (1 << attempt)).clamp(2, 30),
        );
        
        if (attempt > 0) {
          await Future.delayed(delay);
        }

        await bleRepo.connect(deviceId: deviceId);
        await bleRepo.subscribeToNotifications();
        _lastHeartbeat = DateTime.now();
        debugPrint('BLE reconnected successfully after ${attempt + 1} attempts');
        return;
      } catch (e) {
        debugPrint('BLE reconnect attempt ${attempt + 1} failed: $e');
        if (attempt == maxRetries - 1) {
          debugPrint('BLE reconnect failed after $maxRetries attempts, giving up');
        }
      }
    }
  }

  void dispose() {
    stop();
    _service = null;
  }
}

/// Android foreground service entry point.
@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  if (service is AndroidServiceInstance) {
    service.on('stop').listen((_) {
      service.stopSelf();
    });

    service.on('start').listen((_) async {
      // Service started - BLE connection is managed by BleRepo
      // This service just keeps the process alive
      service.setForegroundNotificationInfo(
        title: 'GeyserSwitch',
        content: 'Connected to GeyserSwitch',
      );
    });
  }

  // Keep service alive - update notification periodically
  Timer.periodic(const Duration(seconds: 5), (timer) async {
    if (service is AndroidServiceInstance) {
      try {
        // Update notification to keep service alive
        service.setForegroundNotificationInfo(
          title: 'GeyserSwitch',
          content: 'Connected to GeyserSwitch',
        );
      } catch (_) {
        // Service stopped, cancel timer
        timer.cancel();
      }
    } else {
      timer.cancel();
    }
  });
}

/// iOS background handler.
@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  // iOS relies on CoreBluetooth background mode
  // This handler is called when app is backgrounded
  return true;
}

