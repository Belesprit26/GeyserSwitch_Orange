class BleDeviceModel {
  final String id;
  final String name;
  final int? rssi;

  const BleDeviceModel({required this.id, required this.name, this.rssi});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BleDeviceModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}


