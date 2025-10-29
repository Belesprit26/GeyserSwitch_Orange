import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:gs_orange/src/home/presentation/refactors/home_providers/presentation/geyser_entity.dart';
import 'package:gs_orange/src/home/presentation/widgets/display_card.dart';
import 'package:gs_orange/src/home/presentation/widgets/temperature_settings_dialog.dart';
import 'package:gs_orange/core/services/injection_container.dart';

class HomeBody extends StatefulWidget {
  final Geyser geyser;

  const HomeBody({Key? key, required this.geyser}) : super(key: key);

  @override
  _HomeBodyState createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> {
  final _firebaseDB = FirebaseDatabase.instance.ref().child('GeyserSwitch');
  late Stream<DatabaseEvent> _temperatureStream;
  final _firebaseAuth = sl<FirebaseAuth>();
  late String _userID;

  @override
  void initState() {
    super.initState();
    // Get the userID from FirebaseAuth
    _userID = _firebaseAuth.currentUser!.uid;

    // Initialize the temperature stream
    _temperatureStream = _firebaseDB
        .child(_userID)
        .child("Geysers")
        .child(widget.geyser.id)
        .child(widget.geyser.sensorKey)
        .onValue;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DatabaseEvent>(
      stream: _temperatureStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const DisplayCard(
            value: 0,
            unit: 'Celsius',
            isLoading: true,
          );
        }

        if (!snapshot.hasData ||
            snapshot.data == null ||
            snapshot.data!.snapshot.value == null) {
          return const DisplayCard(
            value: 0,
            unit: 'No data',
            isLoading: false,
          );
        }

        // Safely handle the data conversion
        double temperature;
        try {
          final value = snapshot.data!.snapshot.value;
          if (value is num) {
            temperature = value.toDouble();
          } else if (value is Map) {
            // Handle case where value is a map
            return const DisplayCard(
              value: 0,
              unit: 'Celsius',
              isLoading: false,
            );
          } else {
            // Handle any other unexpected data type
            return const DisplayCard(
              value: 0,
              unit: 'Celsius',
              isLoading: false,
            );
          }
        } catch (e) {
          return const DisplayCard(
            value: 0,
            unit: 'Celsius',
            isLoading: false,
          );
        }

        if (temperature == -127) {
          return const DisplayCard(
            value: 0,
            unit: 'Disconnected',
            isLoading: false,
          );
        }

        return GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => TempSettingDialog(geyser: widget.geyser),
            );
          },
          child: DisplayCard(
            value: temperature,
            unit: 'Celsius',
            isLoading: false,
          ),
        );
      },
    );
  }
}