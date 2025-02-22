import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class TimerProvider extends ChangeNotifier {
  var is4AM = false;
  var is6AM = false;
  var is8AM = false;
  var is4PM = false;
  var is6PM = false;

  bool isLoading = true;

  Map<String, bool> timerLoadingStates = {
    "04:00": false,
    "06:00": false,
    "08:00": false,
    "16:00": false,
    "18:00": false,
  };

  List<String> getActiveTimers() {
    List<String> activeTimers = [];
    if (is4AM) activeTimers.add("04:00");
    if (is6AM) activeTimers.add("06:00");
    if (is8AM) activeTimers.add("08:00");
    if (is4PM) activeTimers.add("16:00");
    if (is6PM) activeTimers.add("18:00");
    return activeTimers;
  }


  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final _firebaseDB = FirebaseDatabase.instance.ref().child('GeyserSwitch');

  TimerProvider() {
    initTimers();
  }

  Future<void> initTimers() async {
    final userID = _firebaseAuth.currentUser!.uid;
    await _updateTimerState("04:00", (value) => is4AM = value, userID);
    await _updateTimerState("06:00", (value) => is6AM = value, userID);
    await _updateTimerState("08:00", (value) => is8AM = value, userID);
    await _updateTimerState("16:00", (value) => is4PM = value, userID);
    await _updateTimerState("18:00", (value) => is6PM = value, userID);
    isLoading = false;
    notifyListeners(); // Notify UI about data changes
  }

  Future<void> _updateTimerState(String timeKey, Function(bool) setStateCallback, String userID) async {
    await _firebaseDB.child(userID).child("Timers").child(timeKey).get().then((DataSnapshot snapshot) {
      bool? spot = snapshot.value as bool?;
      setStateCallback(spot ?? false);
    });
  }

  Future<void> toggleTimer(String timeKey, bool currentState) async {
    timerLoadingStates[timeKey] = true; // Set loading state to true for the specific timer
    notifyListeners(); // Notify UI that the timer is loading

    final userID = _firebaseAuth.currentUser!.uid;
    await _firebaseDB.child(userID).child("Timers").update({timeKey: !currentState});
    switch (timeKey) {
      case "04:00":
        is4AM = !is4AM;
        break;
      case "06:00":
        is6AM = !is6AM;
        break;
      case "08:00":
        is8AM = !is8AM;
        break;
      case "16:00":
        is4PM = !is4PM;
        break;
      case "18:00":
        is6PM = !is6PM;
        break;
    }

    timerLoadingStates[timeKey] = false; // Set loading state to false after the operation
    notifyListeners(); // Notify UI that the loading is complete
  }
}