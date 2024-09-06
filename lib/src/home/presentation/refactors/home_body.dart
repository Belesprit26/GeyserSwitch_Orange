import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:gs_orange/core/common/app/providers/user_provider.dart';
import 'package:gs_orange/core/res/colours.dart';
import 'package:gs_orange/src/home/presentation/widgets/alert_popup.dart';
import 'package:gs_orange/src/home/presentation/widgets/display_card.dart';
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
            Container(
              width: MediaQuery.of(context).size.width * .3,
              height: MediaQuery.of(context).size.height * .05,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Colors.white70,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade400.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 3,
                  ),
                ],
              ),
              child: FittedBox(
                child: FloatingActionButton.extended(
                  splashColor: Colours.primaryOrange,
                  label: const Text(
                    "Max Temp",
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 21,
                      color: Colors.black,
                    ),
                  ),
                  onPressed: () => showDialog(
                    context: context,
                    builder: (BuildContext context) => AlertDialogPopUp(),
                  ),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 18),

            // StreamBuilder for live temperature updates from Firebase Realtime Database
            StreamBuilder<DatabaseEvent>(
              stream: _firebaseDB
                  .child(userID)
                  .child("Geysers")
                  .child("geyser_1")
                  .child("sensor_1") // Path to the 'state' node in Realtime Database
                  .onValue, // Stream for live updates
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator(); // Show loading indicator
                }

                if (!snapshot.hasData || snapshot.data == null || snapshot.data!.snapshot.value == null) {
                  return const Text('No data available'); // Handle no data case
                }

                // Extract the temperature value from Realtime Database snapshot
                double temperature = (snapshot.data!.snapshot.value as num).toDouble();

                // Display the live temperature in DisplayCard
                return DisplayCard(
                  value: temperature,
                  unit: 'Celsius',
                );
              },
            ),
          ],
        );
      },
    );
  }
}