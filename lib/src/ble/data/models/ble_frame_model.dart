import 'dart:typed_data';

class BleCmd {
  static const int auth = 0x10;
  static const int toggle = 0x01;
  static const int setMaxTemp = 0x02;
  static const int setTimers = 0x03;
  static const int getState = 0x20;

  static const int ack = 0x80;
  static const int temperature = 0x81;
  static const int state = 0x82;
  static const int alertMaxTemp = 0x83;
  static const int heartbeat = 0xFF;
}

class BleFrame {
  final int cmd;
  final int seq;
  final Uint8List payload;

  const BleFrame({required this.cmd, required this.seq, required this.payload});
}

class BleFrameEncoder {
  /// Encodes a frame as [CMD][SEQ][LEN][PAYLOAD]
  static Uint8List encode(int cmd, int seq, List<int> payload) {
    final int len = payload.length;
    final bytes = Uint8List(3 + len);
    final b = bytes.buffer.asByteData();
    b.setUint8(0, cmd & 0xFF);
    b.setUint8(1, seq & 0xFF);
    b.setUint8(2, len & 0xFF);
    bytes.setRange(3, 3 + len, payload);
    return bytes;
  }
}

class BleFrameDecoder {
  /// Parses a frame of the form [CMD][SEQ][LEN][PAYLOAD]
  static BleFrame? tryDecode(Uint8List data) {
    if (data.length < 3) return null;
    final bd = data.buffer.asByteData();
    final int cmd = bd.getUint8(0);
    final int seq = bd.getUint8(1);
    final int len = bd.getUint8(2);
    if (data.length != 3 + len) return null;
    final payload = Uint8List.sublistView(data, 3);
    return BleFrame(cmd: cmd, seq: seq, payload: payload);
  }
}

class BlePacking {
  static Uint8List float32ToBytes(double value) {
    final data = ByteData(4);
    data.setFloat32(0, value, Endian.little);
    return data.buffer.asUint8List();
  }

  static double bytesToFloat32(Uint8List bytes) {
    final data = ByteData.sublistView(bytes);
    return data.getFloat32(0, Endian.little);
  }

  static Uint8List uint16ToBytes(int value) {
    final data = ByteData(2);
    data.setUint16(0, value, Endian.little);
    return data.buffer.asUint8List();
  }

  static int bytesToUint16(Uint8List bytes) {
    final data = ByteData.sublistView(bytes);
    return data.getUint16(0, Endian.little);
  }
}


