import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:gs_orange/core/common/app/providers/user_provider.dart';
import 'package:gs_orange/core/res/colours.dart';
import 'package:gs_orange/src/home/presentation/widgets/display_card.dart';
import 'package:gs_orange/src/home/presentation/widgets/temperature_settings_dialog.dart';
import 'package:provider/provider.dart';

class HomeBody extends StatelessWidget {
   HomeBody({Key? key}) : super(key: key);

  // Firebase references
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final _firebaseDB = FirebaseDatabase.instance.ref().child('GeyserSwitch');

  // Get userID from FirebaseAuth
  String get userID => _firebaseAuth.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (_, provider, __) {
        final user = provider.user;

        return Column(
          children: [
            // StreamBuilder for live temperature updates from Firebase Realtime Database
            StreamBuilder<DatabaseEvent>(
              stream: _firebaseDB
                  .child(userID)
                  .child("Geysers")
                  .child("geyser_1")
                  .child("sensor_1")
                  .onValue,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return DisplayCard(
                    value: 0, // Placeholder value for loading state
                    unit: 'Celsius',
                    isLoading: true, // Show loading indicator
                  );
                }

                if (!snapshot.hasData || snapshot.data == null || snapshot.data!.snapshot.value == null) {
                  return const Text('No data available');
                }

                double temperature = (snapshot.data!.snapshot.value as num).toDouble();

                return GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => TempSettingDialog(),
                    );
                  },
                  child: DisplayCard(
                    value: temperature,
                    unit: 'Celsius',
                    isLoading: false, // Data is available, no loading indicator
                  ),
                );
              },
            )
          ],
        );
      },
    );
  }
}