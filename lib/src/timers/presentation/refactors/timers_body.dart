import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:gs_orange/core/res/colours.dart';
import 'package:gs_orange/core/utils/core_utils.dart';

class TimersBody extends StatefulWidget {
  const TimersBody({Key? key}) : super(key: key);

  @override
  State<TimersBody> createState() => _TimersBodyState();
}

class _TimersBodyState extends State<TimersBody> {
  var is4AM = false;
  var is6AM = false;
  var is8AM = false;

  var is4PM = false;
  var is6PM = false;

  final animationDuration = const Duration(milliseconds: 300);

  @override
  void initState() {
    super.initState();
    onUpdate();
  }

  static final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  static final user = _firebaseAuth.currentUser!;
  get userID => user.uid;

  final _firebaseDB = FirebaseDatabase.instance.ref().child('GeyserSwitch');

  Future<void> onUpdate() async {
    await _updateTimerState("04:00", (value) => setState(() => is4AM = value));
    await _updateTimerState("06:00", (value) => setState(() => is6AM = value));
    await _updateTimerState("08:00", (value) => setState(() => is8AM = value));
    await _updateTimerState("16:00", (value) => setState(() => is4PM = value));
    await _updateTimerState("18:00", (value) => setState(() => is6PM = value));
  }

  Future<void> _updateTimerState(String timeKey, Function(bool) setStateCallback) async {
    await _firebaseDB.child(userID).child("Timers").child(timeKey).get().then((DataSnapshot snapshot) {
      bool? spot = snapshot.value as bool?;
      setStateCallback(spot ?? false);
    });
  }

  Widget buildTimerSwitch(String time, bool isOn, Function toggle) {
    return Container(
      width: MediaQuery.of(context).size.width * .93,
      height: MediaQuery.of(context).size.height * .07,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: isOn
            ? LinearGradient(
          colors: [
            Colours.primaryOrange.withOpacity(0.99),
            Colors.blueAccent.withOpacity(0.6),
            Colors.redAccent.withOpacity(0.7),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        )
            : null, // Apply gradient when ON
        color: isOn ? null : Colors.white70, // White70 when OFF
        border: Border.all(color: Colors.white, width: 1), // Thin white border
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade400.withOpacity(0.7),
            spreadRadius: 2,
            blurRadius: 10,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 40.0, right: 15.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              time,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 27,
                color: isOn ? Colors.white : Colors.black87,
              ),
            ),
            GestureDetector(
              onTap: () async {
                await toggle();
              },
              child: AnimatedContainer(
                duration: animationDuration,
                height: 30,
                width: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: isOn
                      ? Colors.black.withOpacity(0.5)
                      : Colours.secondaryColour,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: isOn
                          ? Colours.primaryOrange.withOpacity(0.2)
                          : Colors.grey.shade400.withOpacity(0.7),
                      spreadRadius: 2,
                      blurRadius: isOn ? 10 : 2,
                    ),
                  ],
                ),
                child: AnimatedAlign(
                  duration: animationDuration,
                  alignment: isOn
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0),
          child: const Text(
            'Early Birds',
            style: TextStyle(fontWeight: FontWeight.w400, fontSize: 18),
          ),
        ),
        const SizedBox(height: 15),

        // 04:00 Timer
        buildTimerSwitch("04:00", is4AM, () async {
          setState(() => is4AM = !is4AM);
          await _firebaseDB.child(userID).child("Timers").update({"04:00": is4AM});
          CoreUtils.showSnackBar(context, is4AM
              ? 'Your 4AM Timer has been turned ON Successfully.'
              : 'Your 4AM Timer has been turned OFF Successfully.');
        }),

        const SizedBox(height: 15),

        // 06:00 Timer
        buildTimerSwitch("06:00", is6AM, () async {
          setState(() => is6AM = !is6AM);
          await _firebaseDB.child(userID).child("Timers").update({"06:00": is6AM});
          CoreUtils.showSnackBar(context, is6AM
              ? 'Your 6AM Timer has been turned ON Successfully.'
              : 'Your 6AM Timer has been turned OFF Successfully.');
        }),

        const SizedBox(height: 15),

        // 08:00 Timer
        buildTimerSwitch("08:00", is8AM, () async {
          setState(() => is8AM = !is8AM);
          await _firebaseDB.child(userID).child("Timers").update({"08:00": is8AM});
          CoreUtils.showSnackBar(context, is8AM
              ? 'Your 8AM Timer has been turned ON Successfully.'
              : 'Your 8AM Timer has been turned OFF Successfully.');
        }),

        const SizedBox(height: 30),

        Padding(
          padding: const EdgeInsets.only(left: 4.0),
          child: const Text(
            'Evening Owls',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w400, fontSize: 18),
          ),
        ),
        const SizedBox(height: 15),

        // 16:00 Timer
        buildTimerSwitch("16:00", is4PM, () async {
          setState(() => is4PM = !is4PM);
          await _firebaseDB.child(userID).child("Timers").update({"16:00": is4PM});
          CoreUtils.showSnackBar(context, is4PM
              ? 'Your 4PM Timer has been turned ON Successfully.'
              : 'Your 4PM Timer has been turned OFF Successfully.');
        }),

        const SizedBox(height: 15),

        // 18:00 Timer
        buildTimerSwitch("18:00", is6PM, () async {
          setState(() => is6PM = !is6PM);
          await _firebaseDB.child(userID).child("Timers").update({"18:00": is6PM});
          CoreUtils.showSnackBar(context, is6PM
              ? 'Your 6PM Timer has been turned ON Successfully.'
              : 'Your 6PM Timer has been turned OFF Successfully.');
        }),

        const SizedBox(height: 15),
      ],
    );
  }
}