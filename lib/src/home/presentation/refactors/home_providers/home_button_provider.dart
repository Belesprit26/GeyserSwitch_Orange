import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class HomeButtonProvider with ChangeNotifier {
  bool isEnabled = false;
  bool isLoading = true;

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final _firebaseDB = FirebaseDatabase.instance.ref().child('GeyserSwitch');

  HomeButtonProvider() {
    _listenToStateChanges();
  }

  // Method to listen to live updates from Firebase Realtime Database
  void _listenToStateChanges() {
    final user = _firebaseAuth.currentUser!;
    _firebaseDB
        .child(user.uid)
        .child("Geysers")
        .child("geyser_1")
        .child("state")
        .onValue
        .listen((event) {
      final newState = event.snapshot.value as bool? ?? false;
      isEnabled = newState;
      isLoading = false;
      notifyListeners();
    });
  }

  // Toggle the geyser state
  Future<void> toggleGeyser() async {
    setLoading(true);
    try {
      final user = _firebaseAuth.currentUser!;
      isEnabled = !isEnabled;
      await _firebaseDB
          .child(user.uid)
          .child("Geysers")
          .child("geyser_1")
          .update({"state": isEnabled});
    } catch (error) {
      print("Error toggling geyser state: $error");
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