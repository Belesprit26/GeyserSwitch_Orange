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

        return Center(
          child: Text(
            isGeyserOn ? "Your Smart Geyser is On!" : "Your Smart Geyser is Off!",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        );
      },
    );
  }
}