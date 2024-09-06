import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../../../../core/res/colours.dart';
import '../../../../core/utils/core_utils.dart';

class CustomTimerleg extends StatefulWidget {
  const CustomTimerleg({super.key});

  @override
  State<CustomTimerleg> createState() => _CustomTimerlegState();
}

class _CustomTimerlegState extends State<CustomTimerleg> {
  var isCustom = false;
  String? customTime;
  bool isLoading = true;

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
    try {
      final DataSnapshot snapshot = await _firebaseDB
          .child(userID)
          .child("Timers")
          .child("CUSTOM")
          .get();

      String? fetchedTime = snapshot.value as String?;

      setState(() {
        customTime = fetchedTime ?? "";

        if (customTime != null && customTime!.isNotEmpty) {
          isCustom = true;
        } else {
          isCustom = false;
        }

        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      CoreUtils.showSnackBar(context, 'Failed to fetch custom time.');
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: customTime == null || customTime!.isEmpty
          ? TimeOfDay.now()
          : _convertStringToTimeOfDay(customTime!),
    );

    if (picked != null) {
      setState(() {
        customTime = _formatTime(picked);
        isCustom = true;
      });

      await _firebaseDB.child(userID).child("Timers").update({"CUSTOM": customTime});
    }
  }

  TimeOfDay _convertStringToTimeOfDay(String time) {
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return TimeOfDay(hour: hour, minute: minute);
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * .93,
      height: MediaQuery.of(context).size.height * .07,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: isCustom
            ? LinearGradient(
          colors: [
            Colours.primaryOrange.withOpacity(0.99), // Strong orange
            Colors.blueAccent.withOpacity(0.6),
            Colors.redAccent.withOpacity(0.7),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        )
            : null, // Apply gradient when custom timer is on
        color: isCustom ? null : Colors.white70, // White70 when custom timer is off
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
        padding: const EdgeInsets.only(left: 20.0, right: 15.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              onTap: () async {
                await _selectTime(context); // Open the time picker
              },
              child: isLoading
                  ? const CircularProgressIndicator()
                  : Text(
                customTime == "" || customTime == null
                    ? "Set Here"
                    : "$customTime",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 27,
                  color: isCustom ? Colors.white : Colors.black87, // Dynamic text color
                ),
              ),
            ),
            Row(
              children: [
                 Text(
                  "Custom Timer",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: isCustom ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(width: 5),
                GestureDetector(
                  onTap: () async {
                    setState(() {
                      isCustom = !isCustom;
                    });

                    if (isCustom) {
                      await _firebaseDB
                          .child(userID)
                          .child("Timers")
                          .update({"CUSTOM": customTime});
                      CoreUtils.showSnackBar(context,
                          'Your Custom Timer has been turned ON Successfully.');
                    } else {
                      await _firebaseDB
                          .child(userID)
                          .child("Timers")
                          .update({"CUSTOM": ""});
                      CoreUtils.showSnackBar(context,
                          'Your Custom Timer has been turned OFF Successfully.');
                    }
                  },
                  child: AnimatedContainer(
                    duration: animationDuration,
                    height: 30,
                    width: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: isCustom
                          ? Colors.black.withOpacity(0.5)
                          : Colours.secondaryColour,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: isCustom
                              ? Colours.primaryOrange.withOpacity(0.2)
                              : Colors.grey.shade400.withOpacity(0.7),
                          spreadRadius: 2,
                          blurRadius: isCustom ? 10 : 2,
                        ),
                      ],
                    ),
                    child: AnimatedAlign(
                      duration: animationDuration,
                      alignment: isCustom
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
          ],
        ),
      ),
    );
  }
}