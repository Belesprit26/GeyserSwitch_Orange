import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:gs_orange/core/services/injection_container_exports.dart';

class CustomTimerProvider extends ChangeNotifier {
  bool isCustom = false;
  String? customTime;
  bool isLoading = true;

  // Firebase references
  final FirebaseAuth _firebaseAuth = sl<FirebaseAuth>();
  final _firebaseDB = sl<FirebaseDatabase>().ref().child('GeyserSwitch');

  // Get userID from FirebaseAuth
  String get userID => _firebaseAuth.currentUser!.uid;

  CustomTimerProvider() {
    // Call the function to load the initial data
    fetchCustomTime();
  }

  // Fetch the custom timer value from Firebase
  Future<void> fetchCustomTime() async {
    try {
      final DataSnapshot snapshot = await _firebaseDB
          .child(userID)
          .child("Timers")
          .child("CUSTOM")
          .get();

      customTime = snapshot.value as String?;
      isCustom = customTime != null && customTime!.isNotEmpty;
      isLoading = false;
    } catch (error) {
      isLoading = false;
      // Handle error, like logging or displaying error messages
    }
    notifyListeners(); // Notify listeners after data fetch
  }

  // Update the custom timer in Firebase
  Future<void> updateCustomTime(String newTime) async {
    customTime = newTime;  // Keep the custom time in memory
    isCustom = true;
    notifyListeners(); // Update the UI immediately

    await _firebaseDB
        .child(userID)
        .child("Timers")
        .update({"CUSTOM": newTime});
  }

  // Toggle the custom timer on/off
  Future<void> toggleCustomTimer() async {
    isCustom = !isCustom;

    if (isCustom) {
      // If turning on, use the stored customTime
      await _firebaseDB.child(userID).child("Timers").update({"CUSTOM": customTime});
    } else {
      // If turning off, send an empty string but keep the customTime stored
      await _firebaseDB.child(userID).child("Timers").update({"CUSTOM": ""});
      // Do not clear the customTime in memory, just send the empty string to Firebase
    }
    notifyListeners(); // Update the UI after the change
  }
}