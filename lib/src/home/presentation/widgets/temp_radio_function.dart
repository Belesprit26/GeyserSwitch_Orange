import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:gs_orange/core/res/colours.dart';
import 'package:gs_orange/core/utils/core_utils.dart';

class TempRadio extends StatefulWidget {
  @override
  State<TempRadio> createState() => _TempRadioState();
}

class _TempRadioState extends State<TempRadio> {
  int _value = 0;
  int? _setTemp;

  // Firebase Authentication & Database Reference
  static final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  static final user = _firebaseAuth.currentUser!;
  final DatabaseReference _firebaseDB =
  FirebaseDatabase.instance.ref().child('GeyserSwitch');

  @override
  void initState() {
    super.initState();
    _loadCurrentTemp();
  }

  // Load current max_temp from Firebase
  Future<void> _loadCurrentTemp() async {
    try {
      DataSnapshot snapshot = await _firebaseDB
          .child(user.uid)
          .child("Geysers")
          .child("geyser_1")
          .child("max_temp")
          .get();

      if (snapshot.exists) {
        setState(() {
          _setTemp = snapshot.value as int?;
          _value = _getRadioValueFromTemp(_setTemp);
        });
      }
    } catch (e) {
      CoreUtils.showSnackBar(context, 'Failed to load temperature: $e');
    }
  }

  // Get the radio group value from the current temperature
  int _getRadioValueFromTemp(int? temp) {
    if (temp == 65) return 1;
    if (temp == 60) return 2;
    if (temp == 50) return 3;
    return 0; // Default to 0 if none match
  }

  // Update the temperature in Firebase and show feedback
  Future<void> _updateTemp(int temp, int radioValue, String message) async {
    setState(() {
      _value = radioValue;
    });

    try {
      await _firebaseDB.child(user.uid).child("Geysers").child("geyser_1").update({
        "max_temp": temp,
      });
      CoreUtils.showSnackBar(context, message);
    } catch (e) {
      CoreUtils.showSnackBar(context, 'Failed to update temperature: $e');
    }

    // Close the screen after a short delay
    Future.delayed(const Duration(milliseconds: 300), () {
      Navigator.pop(context, true);
    });
  }

  // Reusable method for building radio rows
  Widget _buildRadioRow(int value, String label, int temp, Color color, String message) {
    return Row(
      children: [
        Radio(
          activeColor: color,
          value: value,
          groupValue: _value,
          onChanged: (newValue) {
            if (newValue != null) {
              _updateTemp(temp, newValue, message);
            }
          },
        ),
        const SizedBox(width: 6),
        Text(label),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildRadioRow(
            1,
            '65°C (Winter)',
            65,
            Colours.redColour,
            'Your geyser will now turn off at 65°C.',
          ),
          _buildRadioRow(
            2,
            '60°C',
            60,
            Colours.secondaryColour,
            'Your geyser will now turn off at 60°C.',
          ),
          _buildRadioRow(
            3,
            '50°C (Summer)',
            50,
            Colours.greenColour,
            'Your geyser will now turn off at 50°C.',
          ),
        ],
      ),
    );
  }
}