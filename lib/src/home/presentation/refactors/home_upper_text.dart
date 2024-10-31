import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gs_orange/core/res/colours.dart';

import 'home_providers/home_button_provider.dart';

class GeyserStatus extends StatelessWidget {
  const GeyserStatus({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeButtonProvider>(
      builder: (context, provider, _) {
        final isGeyserOn = provider.isEnabled;

        return Container(
          width: double.infinity,
          height: 100,
          child: Center(
            child: Text(
              isGeyserOn ? "This Smart Geyser is On" : "This Smart Geyser is Off",
                style: TextStyle(color: Colors.black, fontSize: 19.5),
            ),
          ),
        );
      },
    );
  }
}