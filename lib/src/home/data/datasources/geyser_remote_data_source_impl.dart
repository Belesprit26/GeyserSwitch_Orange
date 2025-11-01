import 'package:firebase_database/firebase_database.dart';
import 'package:gs_orange/core/errors/exceptions.dart';
import 'package:gs_orange/src/home/data/datasources/geyser_remote_data_source.dart';

/// Implementation of GeyserRemoteDataSource using Firebase Realtime Database
class GeyserRemoteDataSourceImpl implements GeyserRemoteDataSource {
  const GeyserRemoteDataSourceImpl({
    required FirebaseDatabase database,
  })  : _database = database;

  final FirebaseDatabase _database;

  DatabaseReference get _rootRef => _database.ref().child('GeyserSwitch');

  DatabaseReference _userGeysersRef(String userId) =>
      _rootRef.child(userId).child('Geysers');

  DatabaseReference _geyserRef(String userId, String geyserId) =>
      _userGeysersRef(userId).child(geyserId);

  DatabaseReference _userStatsRef(String userId) =>
      _rootRef.child(userId).child('Records').child('GeyserDuration');

  @override
  Stream<Map<String, dynamic>> getGeysersStream(String userId) {
    final userGeysersRef = _userGeysersRef(userId);
    
    return userGeysersRef.onValue.map((event) {
      final geysersData = event.snapshot.value;
      
      if (geysersData == null) {
        return <String, dynamic>{};
      }
      
      if (geysersData is Map) {
        // Convert Map<dynamic, dynamic> to Map<String, dynamic>
        return geysersData.map((key, value) => MapEntry(key.toString(), value));
      }
      
      return <String, dynamic>{};
    });
  }

  @override
  Stream<DatabaseEvent> getGeyserTemperatureStream(
    String userId,
    String geyserId,
    String sensorKey,
  ) {
    return _geyserRef(userId, geyserId).child(sensorKey).onValue;
  }

  @override
  Stream<DatabaseEvent> getGeyserStateStream(
    String userId,
    String geyserId,
  ) {
    return _geyserRef(userId, geyserId).child('state').onValue;
  }

  @override
  Stream<DatabaseEvent> getGeyserSensorStream(
    String userId,
    String geyserId,
    String sensorKey,
  ) {
    return _geyserRef(userId, geyserId).child(sensorKey).onValue;
  }

  @override
  Future<void> updateGeyserState(
    String userId,
    String geyserId,
    bool state,
  ) async {
    try {
      await _geyserRef(userId, geyserId).update({'state': state});
    } catch (e) {
      throw ServerException(
        message: 'Failed to update geyser state: $e',
        statusCode: '500',
      );
    }
  }

  @override
  Future<void> updateGeyserName(
    String userId,
    String geyserId,
    String name,
  ) async {
    try {
      await _geyserRef(userId, geyserId).update({'name': name});
    } catch (e) {
      throw ServerException(
        message: 'Failed to update geyser name: $e',
        statusCode: '500',
      );
    }
  }

  @override
  Future<double?> getMaxTemperature(
    String userId,
    String geyserId,
  ) async {
    try {
      final snapshot = await _geyserRef(userId, geyserId)
          .child('max_temp')
          .get();

      if (snapshot.exists && snapshot.value != null) {
        if (snapshot.value is num) {
          return (snapshot.value as num).toDouble();
        }
        // Try parsing as string if needed
        return double.tryParse(snapshot.value.toString());
      }
      return null;
    } catch (e) {
      throw ServerException(
        message: 'Failed to get max temperature: $e',
        statusCode: '500',
      );
    }
  }

  @override
  Future<void> updateMaxTemperature(
    String userId,
    String geyserId,
    double maxTemp,
  ) async {
    try {
      await _geyserRef(userId, geyserId).update({'max_temp': maxTemp});
    } catch (e) {
      throw ServerException(
        message: 'Failed to update max temperature: $e',
        statusCode: '500',
      );
    }
  }

  @override
  Stream<DatabaseEvent> getGeyserStatsStream(String userId) {
    return _userStatsRef(userId).onValue;
  }
}

