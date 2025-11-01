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

  // Track pending state updates to prevent race conditions
  // Key: geyserId, Value: pending state we're writing
  final Map<String, bool> _pendingStateUpdates = {};
  
  // Track which geysers are currently being toggled (to prevent double-taps)
  final Set<String> _togglingGeysers = {};

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
      
      // RACE CONDITION MITIGATION:
      // If we have a pending update for this geyser, ignore listener updates
      // that don't match our pending state (they're likely stale or from conflicts)
      if (_pendingStateUpdates.containsKey(geyser.id)) {
        final pendingState = _pendingStateUpdates[geyser.id];
        // Only apply if it matches what we're trying to write
        // This prevents stale listener updates from overwriting our optimistic update
        if (newState == pendingState) {
          // Our write succeeded, remove from pending
          _pendingStateUpdates.remove(geyser.id);
          geyser.isOn = newState;
        } else {
          // This update doesn't match what we're writing - it's likely stale
          // Ignore it and wait for our write to complete
          return;
        }
      } else {
        // No pending update, safe to apply this change
        // This handles updates from other devices or initial sync
        geyser.isOn = newState;
      }
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
    // Prevent double-taps and concurrent toggles
    if (_togglingGeysers.contains(geyser.id)) {
      return; // Already toggling this geyser
    }

    final user = _firebaseAuth.currentUser!;
    final previousState = geyser.isOn;
    final newState = !previousState;

    try {
      // Mark as toggling
      _togglingGeysers.add(geyser.id);
      
      // Track pending update to prevent race conditions
      _pendingStateUpdates[geyser.id] = newState;
      
      // Optimistic update - update UI immediately
      geyser.isOn = newState;
      notifyListeners();

      // Write to Firebase
      await _firebaseDB
          .child(user.uid)
          .child("Geysers")
          .child(geyser.id)
          .update({"state": newState});

      // Success - pending update will be cleared by listener when it receives confirmation
      // Return success (no error rollback needed since listener will handle it)
      
    } catch (error) {
      // ERROR ROLLBACK: Revert optimistic update
      geyser.isOn = previousState;
      _pendingStateUpdates.remove(geyser.id);
      notifyListeners();
      
      // Re-throw so caller can handle the error (e.g., show error snackbar)
      throw Exception('Failed to toggle geyser: $error');
    } finally {
      // Always remove from toggling set
      _togglingGeysers.remove(geyser.id);
    }
  }
}

