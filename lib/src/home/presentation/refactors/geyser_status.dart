import 'package:flutter/material.dart';
import 'package:gs_orange/src/home/presentation/refactors/home_providers/home_button_provider.dart';
import 'package:gs_orange/src/home/presentation/refactors/home_providers/presentation/geyser_entity.dart';
import 'package:provider/provider.dart';

class GeyserStatus extends StatelessWidget {
  final Geyser geyser;

  const GeyserStatus({Key? key, required this.geyser}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Access HomeButtonProvider to get the geyser list
    final homeButtonProvider = Provider.of<HomeButtonProvider>(context);
    final geyserCount = homeButtonProvider.geyserList.length;

    return ChangeNotifierProvider<Geyser>.value(
      value: geyser,
      child: Consumer<Geyser>(
        builder: (context, geyser, _) {
          final isGeyserOn = geyser.isOn;

          return Container(
            width: double.infinity,
            height: 120, // Adjusted height to accommodate additional text
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Display the number of geysers
                Text(
                  'Number of geysers: $geyserCount',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 10),
                // Existing geyser status text
                Text(
                  isGeyserOn ? "${geyser.name} is On" : "${geyser.name} is Off",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 19.5,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}