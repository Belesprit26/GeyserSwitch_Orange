import 'dart:async';
import 'dart:typed_data';

import 'package:gs_orange/src/ble/data/datasources/ble_remote_data_source.dart';

/// Minimal in-memory stub implementation to allow compilation and wiring.
///
/// A platform-backed implementation that uses flutter_blue_plus can replace this class 
/// without changing call sites. For now, methods are no-ops and streams are broadcast controllers 
/// that emit when relevant methods are called.
class BleRemoteDataSourceImpl implements BleRemoteDataSource {
  final StreamController<bool> _connectedCtrl = StreamController<bool>.broadcast();
  final StreamController<Uint8List> _statusCtrl = StreamController<Uint8List>.broadcast();
  final StreamController<Uint8List> _temperatureCtrl = StreamController<Uint8List>.broadcast();
  final StreamController<Uint8List> _alertCtrl = StreamController<Uint8List>.broadcast();
  final StreamController<DateTime> _heartbeatCtrl = StreamController<DateTime>.broadcast();

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
    // No-op in stub. Real impl should start scanning and surface results elsewhere.
    return;
  }

  @override
  Future<void> stopScan() async {
    return;
  }

  @override
  Future<void> connect({required String deviceId}) async {
    _connectedCtrl.add(true);
  }

  @override
  Future<void> disconnect() async {
    _connectedCtrl.add(false);
  }

  @override
  Future<void> subscribeToNotifications() async {
    // No-op in stub. Real impl should discover and subscribe to Notify chars.
    return;
  }

  @override
  Future<void> writeControl(Uint8List frame) async {
    // No-op in stub. Real impl should write frame via WriteWithResponse.
    return;
  }
}


