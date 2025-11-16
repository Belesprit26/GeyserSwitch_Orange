import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:gs_orange/core/services/injection_container_exports.dart';
import 'package:provider/provider.dart';
import 'package:gs_orange/src/ble/presentation/providers/mode_provider.dart';
import 'package:gs_orange/src/ble/domain/repos/ble_repo.dart';
import 'package:gs_orange/src/timers/presentation/refactors/timers_providers/timer_provider.dart';

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

  // Convert time string (HH:MM) to minutes since midnight
  int _timeStringToMinutes(String? timeString) {
    if (timeString == null || !timeString.contains(':')) return 0;
    final parts = timeString.split(':');
    final hh = int.tryParse(parts[0]) ?? 0;
    final mm = int.tryParse(parts[1]) ?? 0;
    return (hh * 60 + mm).clamp(0, 1439);
  }

  // Update the custom timer in Firebase or BLE based on mode
  Future<void> updateCustomTime(BuildContext context, String newTime) async {
    customTime = newTime;  // Keep the custom time in memory
    isCustom = true;
    notifyListeners(); // Update the UI immediately

    final isLocal = context.read<ModeProvider>().isLocal;
    if (isLocal) {
      // Local Mode: send to BLE
      try {
        final timerProvider = context.read<TimerProvider>();
        final mask = _computeMask(timerProvider);
        final customMinutes = _timeStringToMinutes(newTime);
        final ble = sl<BleRepo>();
        await ble.setTimers(mask: mask, customEnabled: true, customMinutes: customMinutes);
      } catch (_) {
        // Revert on error
        customTime = null;
        isCustom = false;
        notifyListeners();
        rethrow;
      }
    } else {
      // Remote Mode: update Firebase
      await _firebaseDB
          .child(userID)
          .child("Timers")
          .update({"CUSTOM": newTime});
    }
  }

  // Compute timer mask from TimerProvider
  int _computeMask(TimerProvider timerProvider) {
    int mask = 0;
    if (timerProvider.is4AM) mask |= 1 << 0;   // 04:00
    if (timerProvider.is6AM) mask |= 1 << 1;   // 06:00
    if (timerProvider.is8AM) mask |= 1 << 2;   // 08:00
    if (timerProvider.is4PM) mask |= 1 << 3;   // 16:00
    if (timerProvider.is6PM) mask |= 1 << 4;   // 18:00
    return mask;
  }

  // Toggle the custom timer on/off
  Future<void> toggleCustomTimer(BuildContext context) async {
    final wasCustom = isCustom;
    isCustom = !isCustom;

    final isLocal = context.read<ModeProvider>().isLocal;
    if (isLocal) {
      // Local Mode: send to BLE
      try {
        final timerProvider = context.read<TimerProvider>();
        final mask = _computeMask(timerProvider);
        int customMinutes = 0;
        if (isCustom && customTime != null) {
          customMinutes = _timeStringToMinutes(customTime);
        }
        final ble = sl<BleRepo>();
        await ble.setTimers(mask: mask, customEnabled: isCustom, customMinutes: customMinutes);
      } catch (_) {
        // Revert on error
        isCustom = wasCustom;
        notifyListeners();
        rethrow;
      }
    } else {
      // Remote Mode: update Firebase
      if (isCustom) {
        // If turning on, use the stored customTime
        await _firebaseDB.child(userID).child("Timers").update({"CUSTOM": customTime});
      } else {
        // If turning off, send an empty string but keep the customTime stored
        await _firebaseDB.child(userID).child("Timers").update({"CUSTOM": ""});
        // Do not clear the customTime in memory, just send the empty string to Firebase
      }
    }
    notifyListeners(); // Update the UI after the change
  }
}