class BleAck {
  final int cmdEcho;
  final bool success;
  final int? errorCode;

  const BleAck({required this.cmdEcho, required this.success, this.errorCode});
}

class BleTemperature {
  final double tempC;
  const BleTemperature(this.tempC);
}

class BleState {
  final bool isOn;
  final double maxTempC;
  final int timerMask;
  final bool customEnabled;
  final int customMinutes;

  const BleState({
    required this.isOn,
    required this.maxTempC,
    required this.timerMask,
    required this.customEnabled,
    required this.customMinutes,
  });
}

class BleAlert {
  final bool triggered;
  final double tempC;
  const BleAlert({required this.triggered, required this.tempC});
}

class BleHeartbeat {
  final DateTime receivedAt;
  const BleHeartbeat(this.receivedAt);
}


