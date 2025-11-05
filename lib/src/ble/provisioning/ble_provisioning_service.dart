import 'dart:async';

import 'package:gs_orange/src/ble/domain/events/ble_events.dart';
import 'package:gs_orange/src/ble/domain/repos/ble_repo.dart';

class BleProvisioningService {
  final BleRepo bleRepo;

  BleProvisioningService({required this.bleRepo});

  static void validateAsciiMax16(String value, {required String fieldName}) {
    if (value.isEmpty) {
      throw ArgumentError('$fieldName cannot be empty');
    }
    if (value.length > 16) {
      throw ArgumentError('$fieldName must be 16 characters or fewer');
    }
    final isAscii = value.codeUnits.every((c) => c >= 0x20 && c <= 0x7E);
    if (!isAscii) {
      throw ArgumentError('$fieldName must contain only ASCII printable characters');
    }
  }

  static void validateWifiCredentials({required String ssid, required String wifiPassword}) {
    validateAsciiMax16(ssid, fieldName: 'SSID');
    validateAsciiMax16(wifiPassword, fieldName: 'Wi‑Fi password');
  }

  Future<void> connectAndSubscribe(String deviceId) async {
    await bleRepo.connect(deviceId: deviceId);
    await bleRepo.subscribeToNotifications();
  }

  Future<void> authenticate(String password) {
    return bleRepo.authenticate(password);
  }

  /// Provision Wi‑Fi credentials to the device over BLE.
  ///
  /// Note: The BLE protocol for provisioning is not implemented yet.
  /// This method exists to stabilize call sites and will be wired when
  /// provisioning commands are added to the protocol.
  Future<void> sendWifiCredentials({
    required String ssid,
    required String wifiPassword,
    String? userEmail,
    String? userPassword,
  }) async {
    // Validate according to plan limits
    validateWifiCredentials(ssid: ssid, wifiPassword: wifiPassword);
    // Protocol commands will be wired when defined (SET_WIFI_CREDENTIALS)
    throw UnimplementedError('BLE provisioning protocol not wired yet');
  }

  /// Set or update the device password used for AUTH.
  Future<void> setDevicePassword(String newPassword) async {
    throw UnimplementedError('BLE provisioning protocol not wired yet');
  }

  /// Finalize provisioning and request device to persist settings.
  Future<void> commitProvisioning() async {
    throw UnimplementedError('BLE provisioning protocol not wired yet');
  }

  Stream<BleAck> get acks => bleRepo.ack$;
  Stream<BleAlert> get alerts => bleRepo.alert$;
  Stream<BleState> get states => bleRepo.state$;
}


