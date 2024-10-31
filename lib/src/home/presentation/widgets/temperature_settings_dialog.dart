import 'package:flutter/material.dart';
import 'package:gs_orange/core/res/colours.dart';
import 'package:gs_orange/core/utils/core_utils.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class TempSettingDialog extends StatefulWidget {
  @override
  _TempSettingDialogState createState() => _TempSettingDialogState();
}

class _TempSettingDialogState extends State<TempSettingDialog>
    with SingleTickerProviderStateMixin {
  double _maxTemp = 55;
  late AnimationController _animationController;
  late Animation<double> _animation;

  static final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  static final user = _firebaseAuth.currentUser!;
  final DatabaseReference _firebaseDB =
  FirebaseDatabase.instance.ref().child('GeyserSwitch');

  @override
  void initState() {
    super.initState();
    _fetchMaxTemp();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );
    _animation = Tween<double>(begin: 0, end: _maxTemp).animate(_animationController)
      ..addListener(() {
        setState(() {});
      });
    _animationController.forward();
  }

  Future<void> _fetchMaxTemp() async {
    try {
      DataSnapshot snapshot = await _firebaseDB
          .child(user.uid)
          .child("Geysers")
          .child("geyser_1")
          .child("max_temp")
          .get();
      if (snapshot.exists && snapshot.value != null) {
        _maxTemp = double.parse(snapshot.value.toString());
        _updateAnimation(_maxTemp);
      }
    } catch (error) {
      print("Error fetching max temperature: $error");
    }
  }

  void _updateAnimation(double newTemp) {
    _animation = Tween<double>(begin: _animation.value, end: newTemp)
        .animate(_animationController);
    _animationController.forward(from: 0);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Temperature Setting",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          SfRadialGauge(
            axes: <RadialAxis>[
              RadialAxis(
                minimum: 0,
                maximum: 70,
                showTicks: false,
                showLabels: false,
                ranges: <GaugeRange>[
                  GaugeRange(
                    startValue: 0,
                    endValue: _animation.value,
                    startWidth: 6,
                    endWidth: 20,

                    gradient: SweepGradient(
                      colors: <Color>[
                        Colours.primaryOrange.withOpacity(0.8),
                        Colors.orange.withOpacity(0.6),
                        Colors.redAccent.withOpacity(0.6),
                      ],
                      stops: <double>[0.3, 0.6, 1.0],
                    ),
                  ),
                ],
                annotations: <GaugeAnnotation>[
                  GaugeAnnotation(
                    widget: Text(
                      "${_animation.value.toStringAsFixed(1)}°C",
                      style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                    ),
                    positionFactor: 0.1,
                    angle: 90,
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 20),
          Slider(
            activeColor: Colours.primaryOrange.withOpacity(0.9),
            value: _maxTemp,
            min: 0,
            max: 70,
            divisions: 70,
            label: _maxTemp.round().toString(),
            onChanged: (value) {
              setState(() {
                _maxTemp = value;
                _updateAnimation(_maxTemp);
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            _updateTemp(_maxTemp, "Temperature settings successfully updated to ${_maxTemp}°C");
          },
          child: Text(
            "Set Temperature",
            style: TextStyle(color: Colours.primaryColour),
          ),
        ),
      ],
    );
  }

  // Update the temperature in Firebase and show feedback
  Future<void> _updateTemp(double maxTemp, String message) async {
    try {
      await _firebaseDB.child(user.uid).child("Geysers").child("geyser_1").update({
        "max_temp": maxTemp,
      });
      CoreUtils.showSnackBar(context, message);
    } catch (e) {
      CoreUtils.showSnackBar(context, 'Failed to update temperature: $e');
    } finally {
      Navigator.pop(context, true);
      // Close the screen after a short delay
      Future.delayed(const Duration(milliseconds: 300), () {

      });
    }
  }
}

