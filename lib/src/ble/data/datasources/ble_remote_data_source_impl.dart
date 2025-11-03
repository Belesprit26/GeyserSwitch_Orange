import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:gs_orange/src/ble/ble_uuids.dart';
import 'package:gs_orange/src/ble/data/datasources/ble_remote_data_source.dart';

/// flutter_blue_plus-backed implementation of the BLE data source.
class BleRemoteDataSourceImpl implements BleRemoteDataSource {
  final StreamController<bool> _connectedCtrl = StreamController<bool>.broadcast();
  final StreamController<Uint8List> _statusCtrl = StreamController<Uint8List>.broadcast();
  final StreamController<Uint8List> _temperatureCtrl = StreamController<Uint8List>.broadcast();
  final StreamController<Uint8List> _alertCtrl = StreamController<Uint8List>.broadcast();
  final StreamController<DateTime> _heartbeatCtrl = StreamController<DateTime>.broadcast();

  BluetoothDevice? _device;
  BluetoothCharacteristic? _controlC;
  BluetoothCharacteristic? _statusC;
  BluetoothCharacteristic? _temperatureC;
  BluetoothCharacteristic? _alertC;
  BluetoothCharacteristic? _heartbeatC;

  StreamSubscription<List<int>>? _statusSub;
  StreamSubscription<List<int>>? _tempSub;
  StreamSubscription<List<int>>? _alertSub;
  StreamSubscription<List<int>>? _hbSub;

  @override
  Stream<bool> get connected$ => _connectedCtrl.stream;

  @override
  Stream<Uint8List> get status$ => _statusCtrl.stream;

  @override
  Stream<Uint8List> get temperature$ => _temperatureCtrl.stream;

  @override
  Stream<Uint8List> get alert$ => _alertCtrl.stream;

  @override
  Stream<DateTime> get heartbeat$ => _heartbeatCtrl.stream;

  @override
  Future<void> startScan({required String serviceUuid}) async {
    final filter = Guid(serviceUuid);
    await FlutterBluePlus.startScan(withServices: [filter]);
  }

  @override
  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
  }

  @override
  Future<void> connect({required String deviceId}) async {
    final device = BluetoothDevice.fromId(deviceId);
    _device = device;
    await device.connect(autoConnect: false, timeout: const Duration(seconds: 15));
    try {
      await device.requestMtu(185);
    } catch (_) {}
    _connectedCtrl.add(true);
  }

  @override
  Future<void> disconnect() async {
    await _teardownNotifications();
    final d = _device;
    _device = null;
    if (d != null) {
      try {
        await d.disconnect();
      } catch (_) {}
    }
    _connectedCtrl.add(false);
  }

  @override
  Future<void> subscribeToNotifications() async {
    final d = _device;
    if (d == null) {
      throw StateError('Device not connected');
    }

    final services = await d.discoverServices();
    final targetService = services.firstWhere(
      (s) => s.uuid.toString().toLowerCase() == BleUuids.service,
      orElse: () => throw StateError('Target BLE service not found'),
    );

    BluetoothCharacteristic? findChar(String uuid) {
      for (final c in targetService.characteristics) {
        if (c.uuid.toString().toLowerCase() == uuid) {
          return c;
        }
      }
      return null;
    }

    _controlC = findChar(BleUuids.control);
    _statusC = findChar(BleUuids.status);
    _temperatureC = findChar(BleUuids.temperature);
    _alertC = findChar(BleUuids.alert);
    _heartbeatC = findChar(BleUuids.heartbeat);

    if (_controlC == null || _statusC == null || _temperatureC == null || _alertC == null || _heartbeatC == null) {
      throw StateError('One or more required characteristics are missing');
    }

    await _statusC!.setNotifyValue(true);
    await _temperatureC!.setNotifyValue(true);
    await _alertC!.setNotifyValue(true);
    await _heartbeatC!.setNotifyValue(true);

    _statusSub = _statusC!.onValueReceived.listen((value) {
      _statusCtrl.add(Uint8List.fromList(value));
    });
    _tempSub = _temperatureC!.onValueReceived.listen((value) {
      _temperatureCtrl.add(Uint8List.fromList(value));
    });
    _alertSub = _alertC!.onValueReceived.listen((value) {
      _alertCtrl.add(Uint8List.fromList(value));
    });
    _hbSub = _heartbeatC!.onValueReceived.listen((_) {
      _heartbeatCtrl.add(DateTime.now());
    });
  }

  Future<void> _teardownNotifications() async {
    await _statusSub?.cancel();
    await _tempSub?.cancel();
    await _alertSub?.cancel();
    await _hbSub?.cancel();
    _statusSub = null;
    _tempSub = null;
    _alertSub = null;
    _hbSub = null;

    try {
      await _statusC?.setNotifyValue(false);
      await _temperatureC?.setNotifyValue(false);
      await _alertC?.setNotifyValue(false);
      await _heartbeatC?.setNotifyValue(false);
    } catch (_) {}

    _controlC = null;
    _statusC = null;
    _temperatureC = null;
    _alertC = null;
    _heartbeatC = null;
  }

  @override
  Future<void> writeControl(Uint8List frame) async {
    final c = _controlC;
    if (c == null) {
      throw StateError('Control characteristic not ready');
    }
    await c.write(frame, withoutResponse: false);
  }
}


