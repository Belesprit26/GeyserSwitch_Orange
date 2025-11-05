import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:gs_orange/core/services/injection_container_exports.dart';
import 'package:gs_orange/src/ble/ble_uuids.dart';
import 'package:gs_orange/src/ble/domain/repos/ble_repo.dart';
import 'package:gs_orange/src/ble/presentation/providers/mode_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:device_info_plus/device_info_plus.dart';

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
    await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();
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
            _isPhysicalDevice = android.isPhysicalDevice ?? true;
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
      return;
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
    await FlutterBluePlus.startScan(withServices: [Guid(BleUuids.service)]);
    setState(() => _scanning = true);
  }

  Future<void> _connect(ScanResult r) async {
    try {
      await FlutterBluePlus.stopScan();
      setState(() => _scanning = false);
      final ble = sl<BleRepo>();
      await ble.connect(deviceId: r.device.remoteId.str);
      await ble.subscribeToNotifications();
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
            child: _results.isEmpty
                ? const Center(child: Text('No devices found'))
                : ListView.builder(
                    itemCount: _results.length,
                    itemBuilder: (context, index) {
                      final r = _results[index];
                      final name = r.device.platformName.isNotEmpty
                          ? r.device.platformName
                          : r.advertisementData.advName;
                      return ListTile(
                        title: Text(name.isEmpty ? 'Unnamed' : name),
                        subtitle: Text(r.device.remoteId.str),
                        trailing: const Icon(Icons.bluetooth_connected),
                        onTap: () => _connect(r),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}


