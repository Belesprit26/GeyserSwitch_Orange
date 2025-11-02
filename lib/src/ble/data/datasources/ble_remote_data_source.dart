import 'dart:async';
import 'dart:typed_data';

/// Abstraction over the platform BLE adapter.
///
/// This interface exposes raw characteristic streams for the BLE service:
/// - control (WriteWithResponse) is written via [writeControl]
/// - status (Notify) emits ACKs and state snapshots as raw frames
/// - temperature (Notify) emits raw frames with temperature data
/// - alert (Notify) emits raw frames when max temperature thresholds are hit
/// - heartbeat (Notify) emits keepalive signals
///
/// Implementations are responsible for scanning, connecting, service discovery,
/// and subscribing to the notify characteristics.
abstract class BleRemoteDataSource {
  /// Emits true when connected, false when disconnected.
  Stream<bool> get connected$;

  /// Raw frames from the 'status' characteristic (Notify).
  Stream<Uint8List> get status$;

  /// Raw frames from the 'temperature' characteristic (Notify).
  Stream<Uint8List> get temperature$;

  /// Raw frames from the 'alert' characteristic (Notify).
  Stream<Uint8List> get alert$;

  /// Heartbeat pings from device. Payload-free; values indicate receipt time.
  Stream<DateTime> get heartbeat$;

  /// Start scanning for devices that advertise the given service UUID.
  Future<void> startScan({required String serviceUuid});

  /// Stop any active scan.
  Future<void> stopScan();

  /// Connect to a device by its identifier (e.g., MAC/ID).
  Future<void> connect({required String deviceId});

  /// Disconnect from the current device (if any).
  Future<void> disconnect();

  /// Discover services and subscribe to the notify characteristics.
  Future<void> subscribeToNotifications();

  /// Write a frame to the 'control' characteristic (WriteWithResponse).
  Future<void> writeControl(Uint8List frame);
}


