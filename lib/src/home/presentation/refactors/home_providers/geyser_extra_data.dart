import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gs_orange/core/services/injection_container.dart';
import 'package:gs_orange/src/home/presentation/widgets/home_info_card.dart';
import 'package:iconly/iconly.dart';
import '../../../../../core/res/colours.dart';

class GeyserExtraDataWidgets extends StatelessWidget {
  const GeyserExtraDataWidgets({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = sl<FirebaseAuth>().currentUser;
    if (user == null) {
      return const Center(child: Text('No user is currently signed in.'));
    }

    final userID = user.uid;
    final DatabaseReference _firebaseDB = FirebaseDatabase.instance.ref().child('GeyserSwitch');

    return StreamBuilder<DatabaseEvent>(
      stream: _firebaseDB
          .child(userID)
          .child("Records")
          .child("GeyserDuration")
          .onValue,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.data == null){
          return const Center(child: Text('No geyser records found.'));
        }

        final rawData = snapshot.data?.snapshot.value;
        if (rawData == null) {
          return const Center(child: Text('No geyser records found.'));
        }

        double totalDurationSeconds = 0.0;

        // Recursive function to accumulate total duration
        void accumulateDurations(dynamic data) {
          if (data is Map) {
            data.forEach((key, value) {
              if (value is Map && value.containsKey('Duration')) {
                final durationSeconds = value['Duration'] ?? 0;
                totalDurationSeconds += (durationSeconds is num) ? durationSeconds.toDouble() : 0.0;
              } else {
                accumulateDurations(value);
              }
            });
          } else if (data is List) {
            for (var element in data) {
              accumulateDurations(element);
            }
          }
        }

        // Accumulate total duration from all records
        accumulateDurations(rawData);

        // Convert total duration seconds into minutes/seconds for display
        final totalMins = totalDurationSeconds ~/ 60;
        final totalSecs = (totalDurationSeconds % 60).toInt();

        // Normal scenario assumptions:
        // - 150L geyser, 3kW element, ~3 hours = 8.72kWh normal consumption
        const double normalConsumptionKWh = 8.72;

        // Actual consumption calculation:
        // E(kWh) = Rated Capacity (3kW) * Total Operating Hours
        double totalHours = totalDurationSeconds / 3600.0;
        double actualConsumptionKWh = 3.0 * totalHours; // 3kW * hours
        double differenceKWh = actualConsumptionKWh - normalConsumptionKWh;

        // Updated cost per kWh
        const double costPerKWh = 2.72;

        // Calculate savings:
        // If differenceKWh < 0, user saved (-differenceKWh) kWh * costPerKWh Rands
        // If differenceKWh >= 0, no savings
        double savings_in_Rands = 0.0;
        if (differenceKWh < 0) {
          savings_in_Rands = (-differenceKWh) * costPerKWh;
        }

        return Center(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE4E6EA)),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, right: 6.0, left: 6.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 3.0),
                  Center(child: const Text('Geyser Stats', style: TextStyle(fontWeight: FontWeight.w400, fontSize: 18),
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  HomerInfoCard(
                    infoThemeColour: Colours.neutralTextColour,
                    infoIcon: const Icon(
                      IconlyLight.wallet,
                      color: Colors.white,
                      size: 21,
                    ),
                    infoTitle: 'Estimated Daily Saving: R${savings_in_Rands.toStringAsFixed(2)}',
                    infoTitleTextStyle: TextStyle(fontWeight: FontWeight.w500,),
                  ),
                  const SizedBox(height: 3),
                  HomerInfoCard(
                      infoThemeColour: Colours.neutralTextColour,
                      infoIcon: const Icon(
                        IconlyLight.time_square,
                        color: Colors.white,
                        size: 21,
                      ),
                      infoTitle: "Today's Total Runtime: ${totalMins}mins ${totalSecs}secs",
                      infoTitleTextStyle: TextStyle(fontWeight: FontWeight.w500,),
                  ),
                  const SizedBox(height: 3),
                  HomerInfoCard(
                      infoThemeColour: Colours.neutralTextColour,
                      infoIcon: const Icon(
                        IconlyLight.chart,
                        color: Colors.white,
                        size: 21,
                      ),
                      infoTitle: 'Expected Normal Daily Usage: $normalConsumptionKWh kWh.'
                          '\n\nYour Estimated Usage: ${actualConsumptionKWh.toStringAsFixed(2)} kWh.'
                          '\n\nDifference: ${differenceKWh.toStringAsFixed(2)} kWh.',
                    infoTitleTextStyle: TextStyle(fontWeight: FontWeight.w500,),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}