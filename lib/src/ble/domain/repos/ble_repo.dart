import 'dart:async';

import 'package:gs_orange/src/ble/domain/events/ble_events.dart';

/// Domain-facing BLE repository.
///
/// Methods map to application intents; underlying transport is handled by the
/// data source (GATT characteristics). All streams are broadcast.
abstract class BleRepo {
  Stream<bool> get connected$;

  Stream<BleAck> get ack$;
  Stream<BleTemperature> get temperature$;
  Stream<BleState> get state$;
  Stream<BleAlert> get alert$;
  Stream<BleHeartbeat> get heartbeat$;

  Future<void> startScan({required String serviceUuid});
  Future<void> stopScan();

  Future<void> connect({required String deviceId});
  Future<void> subscribeToNotifications();
  Future<void> disconnect();

  Future<void> authenticate(String password);
  Future<void> sendToggle(bool on);
  Future<void> setMaxTemp(double tempC);
  Future<void> setTimers({required int mask, required bool customEnabled, required int customMinutes});
  Future<void> requestState();
}


