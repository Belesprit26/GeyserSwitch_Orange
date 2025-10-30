import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:gs_orange/core/services/injection_container_exports.dart';

class ConnectionLinkProvider with ChangeNotifier {
  String updateDate = "";
  String updateTime = "";
  bool isLoading = true;

  final FirebaseAuth _firebaseAuth = sl<FirebaseAuth>();
  final _firebaseDB = sl<FirebaseDatabase>().ref().child('GeyserSwitch');

  ConnectionLinkProvider() {
    _listenToStateChanges();
  }

  // Listen to live updates for both date and time from Firebase Realtime Database
  void _listenToStateChanges() {
    final user = _firebaseAuth.currentUser!;

    // Listen for updateDate
    _firebaseDB
        .child(user.uid)
        .child("Records")
        .child("LastUpdate")
        .child("updateDate")
        .onValue
        .listen((event) {
      final newDateState = event.snapshot.value as String? ?? "";
      updateDate = newDateState;
      notifyListeners();
    });

    // Listen for updateTime
    _firebaseDB
        .child(user.uid)
        .child("Records")
        .child("LastUpdate")
        .child("updateTime")
        .onValue
        .listen((event) {
      final newTimeState = event.snapshot.value as String? ?? "";
      updateTime = newTimeState;
      isLoading = false;
      notifyListeners();
    });
  }

  // Update the geyser state for date
  Future<void> updateDateState(String newDate) async {
    setLoading(true);
    try {
      final user = _firebaseAuth.currentUser!;
      updateDate = newDate;
      await _firebaseDB
          .child(user.uid)
          .child("Records")
          .child("LastUpdate")
          .update({"updateDate": updateDate});
    } catch (error) {
      print("Error updating date: $error");
    } finally {
      setLoading(false);
    }
    notifyListeners();
  }

  // Update the geyser state for time
  Future<void> updateTimeState(String newTime) async {
    setLoading(true);
    try {
      final user = _firebaseAuth.currentUser!;
      updateTime = newTime;
      await _firebaseDB
          .child(user.uid)
          .child("Records")
          .child("LastUpdate")
          .update({"updateTime": updateTime});
    } catch (error) {
      print("Error updating time: $error");
    } finally {
      setLoading(false);
    }
    notifyListeners();
  }

  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }
}