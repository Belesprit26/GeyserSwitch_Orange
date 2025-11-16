import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:gs_orange/core/services/injection_container_exports.dart';
import 'package:gs_orange/src/ble/ble_uuids.dart';
import 'package:gs_orange/src/ble/domain/repos/ble_repo.dart';
import 'package:gs_orange/src/ble/presentation/providers/mode_provider.dart';
import 'package:gs_orange/src/ble/presentation/services/ble_sync_service.dart';
import 'package:gs_orange/src/ble/presentation/services/ble_background_service.dart';
import 'package:app_settings/app_settings.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BleScanConnectView extends StatefulWidget {
  const BleScanConnectView({super.key});

  @override
  State<BleScanConnectView> createState() => _BleScanConnectViewState();
}

class _BleScanConnectViewState extends State<BleScanConnectView> {
  bool _scanning = false;
  late final StreamSubscription<List<ScanResult>> _scanSub;
  final List<ScanResult> _results = [];
  bool _isPhysicalDevice = true;
  String? _unsupportedReason;
  Timer? _scanTimeout;

  @override
  void initState() {
    super.initState();
    _checkEnvironment();
    _scanSub = FlutterBluePlus.scanResults.listen((list) {
      final filtered = list.where((r) {
        final adv = r.advertisementData;
        final uuids = adv.serviceUuids.map((g) => g.toString().toLowerCase()).toList();
        return uuids.contains(BleUuids.service);
      }).toList();
      setState(() {
        _results
          ..clear()
          ..addAll(filtered);
      });
    });
  }

  @override
  void dispose() {
    _scanSub.cancel();
    FlutterBluePlus.stopScan();
    super.dispose();
  }

  Future<void> _requestPermissions() async {
    // Request Bluetooth + location (legacy) permissions as needed
    final statuses = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();
    final anyPermanentlyDenied = statuses.values.any((s) => s.isPermanentlyDenied);
    if (anyPermanentlyDenied && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bluetooth permissions denied. Please enable in Settings.')),
      );
      await openAppSettings();
    }
  }

  Future<void> _checkEnvironment() async {
    try {
      if (!(Platform.isAndroid || Platform.isIOS)) {
        setState(() {
          _isPhysicalDevice = false;
          _unsupportedReason = 'BLE scanning requires Android/iOS physical device';
        });
        return;
      }
      final info = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final android = await info.androidInfo;
        if (mounted) {
          setState(() {
            _isPhysicalDevice = android.isPhysicalDevice;
            _unsupportedReason = _isPhysicalDevice ? null : 'Android emulator does not support Bluetooth';
          });
        }
      } else if (Platform.isIOS) {
        final ios = await info.iosInfo;
        if (mounted) {
          setState(() {
            _isPhysicalDevice = ios.isPhysicalDevice;
            _unsupportedReason = _isPhysicalDevice ? null : 'iOS Simulator does not support Bluetooth';
          });
        }
      }
    } catch (_) {
      // If detection fails, default to physical allowed
    }
  }

  Future<void> _toggleScan() async {
    if (_scanning) {
      await FlutterBluePlus.stopScan();
      setState(() => _scanning = false);
      _scanTimeout?.cancel();
      return;
    }
    // Ensure adapter is ON
    final state = await FlutterBluePlus.adapterState.first;
    if (state == BluetoothAdapterState.off) {
      await _ensureBluetoothOn();
      final newState = await FlutterBluePlus.adapterState.first;
      if (newState == BluetoothAdapterState.off) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please turn on Bluetooth to scan')),
          );
        }
        return;
      }
    }
    if (!_isPhysicalDevice) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_unsupportedReason ?? 'BLE not supported on this device')),
        );
      }
      return;
    }
    await _requestPermissions();
    // Prefer filtered scan, but some devices don't advertise service UUIDs.
    // Start an unfiltered scan and filter in UI by name/UUID.
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 0));
    setState(() => _scanning = true);
    _scanTimeout?.cancel();
    _scanTimeout = Timer(const Duration(seconds: 10), () async {
      if (!mounted) return;
      await FlutterBluePlus.stopScan();
      setState(() => _scanning = false);
      if (_results.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No devices found. Ensure the device is powered and advertising.')),
        );
      }
    });
  }

  Future<void> _ensureBluetoothOn() async {
    try {
      // Android can request programmatic enable
      if (Platform.isAndroid) {
        await FlutterBluePlus.turnOn();
        return;
      }
    } catch (_) {
      // Fallback to settings
    }
    // iOS and fallback: open Bluetooth settings
    try {
      await AppSettings.openAppSettings(type: AppSettingsType.bluetooth);
    } catch (_) {}
  }

  Future<void> _connect(ScanResult r) async {
    try {
      await FlutterBluePlus.stopScan();
      setState(() => _scanning = false);
      final ble = sl<BleRepo>();
      await ble.connect(deviceId: r.device.remoteId.str);
      await ble.subscribeToNotifications();
      // Persist last connected device for auto-reconnect
      final prefs = sl<SharedPreferences>();
      await prefs.setString('last_ble_device_id', r.device.remoteId.str);
      // Start BLE → Providers synchronization for Local Mode
      sl<BleSyncService>().start(context);
      // Start background service (Android foreground service, iOS watchdog)
      await BleBackgroundService.instance.start();
      if (!mounted) return;
      context.read<ModeProvider>().setLocal();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connected via BLE. Local Mode active.')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to connect: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BLE Scan & Connect')),
      body: Column(
        children: [
          if (_scanning) const LinearProgressIndicator(minHeight: 2),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isPhysicalDevice ? _toggleScan : null,
                    child: Text(_isPhysicalDevice
                        ? (_scanning ? 'Stop Scan' : 'Start Scan')
                        : (_unsupportedReason ?? 'Unsupported on emulator')),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isPhysicalDevice
                ? (_results.isEmpty
                    ? const Center(child: Text('Tap Start Scan to search for devices'))
                    : ListView.builder(
                        itemCount: _results.length,
                        itemBuilder: (context, index) {
                          final r = _results[index];
                          final adv = r.advertisementData;
                          final uuids = adv.serviceUuids.map((g) => g.toString().toLowerCase()).toList();
                          final name = r.device.platformName.isNotEmpty
                              ? r.device.platformName
                              : adv.advName;
                          final matchesService = uuids.contains(BleUuids.service);
                          final display = matchesService || name.toLowerCase().contains('geyser');
                          if (!display) return const SizedBox.shrink();
                          return ListTile(
                            title: Text(name.isEmpty ? 'Unnamed' : name),
                            subtitle: Text(r.device.remoteId.str),
                            trailing: const Icon(Icons.bluetooth_connected),
                            onTap: () => _connect(r),
                          );
                        },
                      ))
                : Center(
                    child: Text(_unsupportedReason ?? 'BLE not supported on this device'),
                  ),
          ),
        ],
      ),
    );
  }
}


