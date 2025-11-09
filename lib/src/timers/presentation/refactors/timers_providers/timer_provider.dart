import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:gs_orange/core/services/injection_container_exports.dart';
import 'package:provider/provider.dart';
import 'package:gs_orange/src/ble/presentation/providers/mode_provider.dart';
import 'package:gs_orange/src/ble/domain/repos/ble_repo.dart';
import 'package:gs_orange/src/timers/presentation/refactors/custom_timer_provider/custom_timer_provider.dart';

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


  final FirebaseAuth _firebaseAuth = sl<FirebaseAuth>();
  final _firebaseDB = sl<FirebaseDatabase>().ref().child('GeyserSwitch');

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

  int _computeMask() {
    int mask = 0;
    if (is4AM) mask |= 1 << 0;   // 04:00
    if (is6AM) mask |= 1 << 1;   // 06:00
    if (is8AM) mask |= 1 << 2;   // 08:00
    if (is4PM) mask |= 1 << 3;   // 16:00
    if (is6PM) mask |= 1 << 4;   // 18:00
    return mask;
  }

  Future<void> toggleTimer(BuildContext context, String timeKey, bool currentState) async {
    timerLoadingStates[timeKey] = true;
    notifyListeners();

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

    final isLocal = context.read<ModeProvider>().isLocal;
    if (isLocal) {
      final mask = _computeMask();
      final custom = context.read<CustomTimerProvider>();
      final customEnabled = custom.isCustom;
      int customMinutes = 0;
      if (custom.customTime != null && custom.customTime!.contains(':')) {
        final parts = custom.customTime!.split(':');
        final hh = int.tryParse(parts[0]) ?? 0;
        final mm = int.tryParse(parts[1]) ?? 0;
        customMinutes = (hh * 60 + mm).clamp(0, 1439);
      }
      try {
        final ble = sl<BleRepo>();
        await ble.setTimers(mask: mask, customEnabled: customEnabled, customMinutes: customMinutes);
      } catch (_) {
        // Revert on error
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
      }
    } else {
      final userID = _firebaseAuth.currentUser!.uid;
      await _firebaseDB.child(userID).child("Timers").update({timeKey: !currentState});
    }

    timerLoadingStates[timeKey] = false;
    notifyListeners();
  }
}