import 'package:flutter/material.dart';
import 'package:gs_orange/core/res/colours.dart';
import 'package:gs_orange/core/utils/core_utils.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:gs_orange/core/services/injection_container_exports.dart';
import 'package:provider/provider.dart';
import 'package:gs_orange/src/ble/presentation/providers/mode_provider.dart';
import 'package:gs_orange/src/ble/domain/repos/ble_repo.dart';

import 'package:gs_orange/src/home/domain/entities/geyser_entity.dart';

class TempSettingDialog extends StatefulWidget {
  final GeyserEntity geyser;

  TempSettingDialog({required this.geyser});

  @override
  _TempSettingDialogState createState() => _TempSettingDialogState();
}

class _TempSettingDialogState extends State<TempSettingDialog>
    with SingleTickerProviderStateMixin {
  double _maxTemp = 55;
  late AnimationController _animationController;
  late Animation<double> _animation;

  final FirebaseAuth _firebaseAuth = sl<FirebaseAuth>();
  late final User? _user;
  late final DatabaseReference _firebaseDB;

  @override
  void initState() {
    super.initState();
    _user = _firebaseAuth.currentUser;
    _firebaseDB = sl<FirebaseDatabase>().ref().child('GeyserSwitch');

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _animation = Tween<double>(begin: 0, end: _maxTemp).animate(_animationController)
      ..addListener(() {
        setState(() {});
      });

    _animationController.forward();
    // Decide initial source based on mode after the first frame (context available)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final isLocal = context.read<ModeProvider>().isLocal;
      if (isLocal) {
        // Use local value (from entity) as initial, then device stream will confirm
        setState(() {
          _maxTemp = widget.geyser.maxTemp;
          _updateAnimation(_maxTemp);
        });
      } else {
        _fetchMaxTemp();
      }
    });
  }

  Future<void> _fetchMaxTemp() async {
    if (_user == null) return;
    try {
      DataSnapshot snapshot = await _firebaseDB
          .child(_user!.uid)
          .child("Geysers")
          .child(widget.geyser.id)
          .child("max_temp")
          .get();

      if (snapshot.exists && snapshot.value != null) {
        double fetchedMaxTemp = double.parse(snapshot.value.toString());
        setState(() {
          _maxTemp = fetchedMaxTemp;
          _updateAnimation(_maxTemp);
        });
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
    // Adjust maximum values to accommodate higher temperatures
    const double maxTemperatureLimit = 75.0;

    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "${widget.geyser.name} - Max Temperature",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SfRadialGauge(
              axes: <RadialAxis>[
                RadialAxis(
                  minimum: 0,
                  maximum: maxTemperatureLimit, // Adjusted maximum
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
                        stops: const <double>[0.3, 0.6, 1.0],
                      ),
                    ),
                  ],
                  annotations: <GaugeAnnotation>[
                    GaugeAnnotation(
                      widget: Text(
                        "${_animation.value.toStringAsFixed(1)}°C",
                        style: const TextStyle(
                            fontSize: 21, fontWeight: FontWeight.bold),
                      ),
                      positionFactor: 0.1,
                      angle: 90,
                    ),
                  ],
                ),
              ],
            ),
            Slider(
              activeColor: Colours.primaryOrange.withOpacity(0.9),
              value: _maxTemp,
              min: 0,
              max: maxTemperatureLimit, // Adjusted maximum
              divisions: maxTemperatureLimit.toInt(),
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
      ),
      actions: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(textAlign: TextAlign.left,
              "Cancel",
              style: TextStyle(color: Colours.redColour),
            ),
          ),
          TextButton(
            onPressed: () {
              _updateTemp(
                _maxTemp,
                "Temperature settings for ${widget.geyser.name} successfully updated to ${_maxTemp.toStringAsFixed(1)}°C",
              );
            },
            child: Text(
              "Set",
              style: TextStyle(color: Colours.primaryColour),
            ),
          ),
        ],
        ),
      ],
    );
  }

  // Update the temperature in Firebase and show feedback
  Future<void> _updateTemp(double maxTemp, String message) async {
    final isLocal = context.read<ModeProvider>().isLocal;
    if (isLocal) {
      // Local Mode: push to device first using local value, then device stream confirms
      try {
        final ble = sl<BleRepo>();
        await ble.setMaxTemp(maxTemp);
        if (!mounted) return;
        CoreUtils.showSnackBar(context, message);
      } catch (e) {
        if (!mounted) return;
        CoreUtils.showSnackBar(context, 'Failed to update temperature: $e');
      } finally {
        if (mounted) Navigator.pop(context, true);
      }
    } else {
      // Remote Mode: update Firebase
      if (_user == null) return;
      try {
        await _firebaseDB
            .child(_user!.uid)
            .child("Geysers")
            .child(widget.geyser.id)
            .update({
          "max_temp": maxTemp,
        });
        if (!mounted) return;
        CoreUtils.showSnackBar(context, message);
      } catch (e) {
        if (!mounted) return;
        CoreUtils.showSnackBar(context, 'Failed to update temperature: $e');
      } finally {
        if (mounted) Navigator.pop(context, true);
      }
    }
  }
}