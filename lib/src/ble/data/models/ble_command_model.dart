import 'dart:convert';
import 'dart:typed_data';

import 'package:gs_orange/src/ble/data/models/ble_frame_model.dart';

class BleCommandBuilder {
  static List<int> authPayload(String password) {
    final pwdBytes = ascii.encode(password);
    if (pwdBytes.length > 255) {
      throw ArgumentError('Password too long (max 255 bytes)');
    }
    return [pwdBytes.length, ...pwdBytes];
  }

  static List<int> togglePayload(bool on) {
    return [on ? 0x01 : 0x00];
  }

  static List<int> setMaxTempPayload(double tempC) {
    return BlePacking.float32ToBytes(tempC);
  }

  static List<int> setTimersPayload({required int mask, required bool customEnabled, required int customMinutes}) {
    if (mask < 0 || mask > 0xFF) {
      throw ArgumentError('Timer mask must be 0..255');
    }
    if (customMinutes < 0 || customMinutes > 1439) {
      throw ArgumentError('Custom minutes must be 0..1439');
    }
    final timeBytes = BlePacking.uint16ToBytes(customMinutes);
    return [mask & 0xFF, customEnabled ? 0x01 : 0x00, ...timeBytes];
  }

  static Uint8List frame(int cmd, int seq, List<int> payload) {
    return BleFrameEncoder.encode(cmd, seq, payload);
  }
}


