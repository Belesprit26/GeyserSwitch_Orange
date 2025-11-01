import 'package:gs_orange/src/home/domain/entities/geyser_entity.dart';

/// Data model for Geyser, handles conversion between Firebase data and domain entity
class GeyserModel {
  final String id;
  final String name;
  final String sensorKey;
  final bool isOn;
  final double temperature;
  final double maxTemp;

  const GeyserModel({
    required this.id,
    required this.name,
    required this.sensorKey,
    required this.isOn,
    required this.temperature,
    required this.maxTemp,
  });

  /// Create GeyserModel from Firebase Realtime Database map
  /// 
  /// [geyserId] is the key (e.g., "geyser_1")
  /// [geyserData] is the map containing geyser fields (name, state, max_temp, sensor_*, etc.)
  factory GeyserModel.fromMap(String geyserId, Map<dynamic, dynamic> geyserData) {
    // Extract the sensor key and temperature value
    String sensorKey = '';
    double temperatureValue = 0.0;

    geyserData.forEach((dataKey, dataValue) {
      if (dataKey.toString().startsWith('sensor_')) {
        sensorKey = dataKey.toString();
        // Handle temperature conversion
        if (dataValue is num) {
          temperatureValue = dataValue.toDouble();
        } else {
          temperatureValue = 0.0;
        }
      }
    });

    return GeyserModel(
      id: geyserId,
      name: geyserData['name'] as String? ?? geyserId,
      sensorKey: sensorKey,
      isOn: geyserData['state'] as bool? ?? false,
      temperature: temperatureValue,
      maxTemp: (geyserData['max_temp'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Convert GeyserModel to Firebase Realtime Database map format
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'state': isOn,
      'max_temp': maxTemp,
      sensorKey: temperature,
    };
  }

  /// Convert GeyserModel to domain entity Geyser
  /// 
  /// Note: The domain entity extends ChangeNotifier for UI state management.
  /// This conversion creates a new Geyser entity instance.
  GeyserEntity toEntity() {
    return GeyserEntity(
      id: id,
      name: name,
      sensorKey: sensorKey,
      isOn: isOn,
      temperature: temperature,
      maxTemp: maxTemp,
    );
  }

  /// Create GeyserModel from domain entity
  factory GeyserModel.fromEntity(GeyserEntity geyser) {
    return GeyserModel(
      id: geyser.id,
      name: geyser.name,
      sensorKey: geyser.sensorKey,
      isOn: geyser.isOn,
      temperature: geyser.temperature,
      maxTemp: geyser.maxTemp,
    );
  }

  /// Create a copy with updated fields
  GeyserModel copyWith({
    String? id,
    String? name,
    String? sensorKey,
    bool? isOn,
    double? temperature,
    double? maxTemp,
  }) {
    return GeyserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      sensorKey: sensorKey ?? this.sensorKey,
      isOn: isOn ?? this.isOn,
      temperature: temperature ?? this.temperature,
      maxTemp: maxTemp ?? this.maxTemp,
    );
  }
}

