import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:gs_orange/core/services/injection_container_exports.dart';
import 'package:gs_orange/src/home/domain/entities/geyser_entity.dart';

class GeyserProvider with ChangeNotifier {
  bool isLoading = true;
  List<GeyserEntity> geyserList = [];

  final FirebaseAuth _firebaseAuth = sl<FirebaseAuth>();
  final DatabaseReference _firebaseDB =
  sl<FirebaseDatabase>().ref().child('GeyserSwitch');

  GeyserProvider() {
    _fetchGeysers();
  }

  // Method to fetch the list of geysers and listen to their state changes
  void _fetchGeysers() {
    final user = _firebaseAuth.currentUser!;
    final userGeysersRef = _firebaseDB.child(user.uid).child("Geysers");

    userGeysersRef.onValue.listen((event) {
      final geysersData = event.snapshot.value as Map<dynamic, dynamic>?;

      if (geysersData != null) {
        geyserList.clear();

        geysersData.forEach((key, value) {
          final geyserId = key as String;
          final geyserData = value as Map<dynamic, dynamic>;

          // Extract the sensor key and temperature value
          String sensorKey = '';
          double temperatureValue = 0.0;

          geyserData.forEach((dataKey, dataValue) {
            if (dataKey.toString().startsWith('sensor_')) {
              sensorKey = dataKey.toString();
              temperatureValue = (dataValue as num).toDouble();
            }
          });

          final geyser = GeyserEntity(
            id: geyserId,
            name: geyserData['name'] ?? geyserId,
            sensorKey: sensorKey,
            isOn: geyserData['state'] as bool? ?? false,
            temperature: temperatureValue,
            maxTemp: (geyserData['max_temp'] as num?)?.toDouble() ?? 0.0,
          );

          if(geyser.temperature != -127){
            geyserList.add(geyser);
          }

          // Listen to state changes for each geyser
          _listenToGeyserStateChanges(userGeysersRef.child(geyserId), geyser);

          // Listen to sensor data changes for each geyser
          _listenToGeyserSensorChanges(userGeysersRef.child(geyserId), geyser);
        });

        // Sort the geyserList based on the geyser IDs
        geyserList.sort((a, b) {
          int aId = int.tryParse(a.id.replaceAll('geyser_', '')) ?? 0;
          int bId = int.tryParse(b.id.replaceAll('geyser_', '')) ?? 0;
          return aId.compareTo(bId);
        });

        isLoading = false;
        notifyListeners();
      }
    });
  }

  // Method to listen to state changes for a specific geyser
  void _listenToGeyserStateChanges(DatabaseReference geyserRef, GeyserEntity geyser) {
    geyserRef.child('state').onValue.listen((event) {
      final newState = event.snapshot.value as bool? ?? false;
      geyser.isOn = newState;
    });
  }

  // Method to listen to sensor data changes for a specific geyser
  void _listenToGeyserSensorChanges(DatabaseReference geyserRef, GeyserEntity geyser) {
    geyserRef.child(geyser.sensorKey).onValue.listen((event) {
      final value = event.snapshot.value;
      double newTemperature;
      
      if (value is num) {
        newTemperature = value.toDouble();
      } else if (value is Map) {
        // If the value is a map, try to extract the temperature value
        // You might need to adjust this depending on your data structure
        final tempValue = value.values.firstWhere(
          (v) => v is num,
          orElse: () => 0,
        );
        newTemperature = (tempValue as num).toDouble();
      } else {
        newTemperature = 0.0;
      }
      
      geyser.temperature = newTemperature;
    });
  }

  // Toggle the geyser state
  Future<void> toggleGeyser(GeyserEntity geyser) async {
    try {
      final user = _firebaseAuth.currentUser!;
      geyser.isOn = !geyser.isOn;
      await _firebaseDB
          .child(user.uid)
          .child("Geysers")
          .child(geyser.id)
          .update({"state": geyser.isOn});
    } catch (error) {
      print("Error toggling geyser state: $error");
    }
    notifyListeners();
  }
}

