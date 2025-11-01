import 'package:firebase_database/firebase_database.dart';

/// Abstract class defining the interface for geyser remote data operations
abstract class GeyserRemoteDataSource {
  const GeyserRemoteDataSource();

  /// Stream of all geysers for a given user
  /// Returns a stream that emits maps of geyser data
  Stream<Map<String, dynamic>> getGeysersStream(String userId);

  /// Stream of temperature readings for a specific geyser sensor
  /// Returns DatabaseEvent stream for temperature updates
  Stream<DatabaseEvent> getGeyserTemperatureStream(
    String userId,
    String geyserId,
    String sensorKey,
  );

  /// Stream of state changes (on/off) for a specific geyser
  /// Returns DatabaseEvent stream for state updates
  Stream<DatabaseEvent> getGeyserStateStream(
    String userId,
    String geyserId,
  );

  /// Stream of sensor data changes for a specific geyser
  /// Returns DatabaseEvent stream for sensor updates
  Stream<DatabaseEvent> getGeyserSensorStream(
    String userId,
    String geyserId,
    String sensorKey,
  );

  /// Update the on/off state of a geyser
  Future<void> updateGeyserState(
    String userId,
    String geyserId,
    bool state,
  );

  /// Update the name/label of a geyser
  Future<void> updateGeyserName(
    String userId,
    String geyserId,
    String name,
  );

  /// Get the maximum temperature setting for a geyser
  Future<double?> getMaxTemperature(
    String userId,
    String geyserId,
  );

  /// Update the maximum temperature setting for a geyser
  Future<void> updateMaxTemperature(
    String userId,
    String geyserId,
    double maxTemp,
  );

  /// Stream of geyser statistics/duration records
  /// Returns DatabaseEvent stream for stats updates
  Stream<DatabaseEvent> getGeyserStatsStream(String userId);
}

