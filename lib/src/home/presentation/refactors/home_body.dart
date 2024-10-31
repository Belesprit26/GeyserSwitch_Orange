import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:gs_orange/src/home/presentation/refactors/home_providers/presentation/geyser_entity.dart';
import 'package:gs_orange/src/home/presentation/widgets/display_card.dart';
import 'package:gs_orange/src/home/presentation/widgets/temperature_settings_dialog.dart';

class HomeBody extends StatefulWidget {
  final Geyser geyser;

  const HomeBody({Key? key, required this.geyser}) : super(key: key);

  @override
  _HomeBodyState createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> {
  final _firebaseDB = FirebaseDatabase.instance.ref().child('GeyserSwitch');
  late Stream<DatabaseEvent> _temperatureStream;
  final _firebaseAuth = FirebaseAuth.instance;
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
          return DisplayCard(
            value: 0, // Placeholder value for loading state
            unit: 'Celsius',
            isLoading: true, // Show loading indicator
          );
        }

        if (!snapshot.hasData ||
            snapshot.data == null ||
            snapshot.data!.snapshot.value == null) {
          return const Text('No data available');
        }

        double temperature =
        (snapshot.data!.snapshot.value as num).toDouble();

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
            isLoading: false, // Data is available, no loading indicator
          ),
        );
      },
    );
  }
}