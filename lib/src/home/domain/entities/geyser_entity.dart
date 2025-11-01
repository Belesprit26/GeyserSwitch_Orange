import 'package:flutter/material.dart';

class Geyser extends ChangeNotifier {
  final String id;
  final String name;
  final String sensorKey; // e.g., 'sensor_1' or 'sensor_2'
  bool _isOn;
  double _temperature;
  double maxTemp;

  Geyser({
    required this.id,
    required this.name,
    required this.sensorKey,
    required bool isOn,
    required double temperature,
    required this.maxTemp,
  })  : _isOn = isOn,
        _temperature = temperature;

  bool get isOn => _isOn;
  double get temperature => _temperature;

  set isOn(bool value) {
    if (_isOn != value) {
      _isOn = value;
      notifyListeners();
    }
  }

  set temperature(double value) {
    if (_temperature != value) {
      _temperature = value;
      notifyListeners();
    }
  }
}

