import 'package:flutter/material.dart';
import 'package:gs_orange/core/res/colours.dart';
import 'package:provider/provider.dart';

import 'home_providers/home_button_provider.dart';

class HomeButton extends StatelessWidget {
  const HomeButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeButtonProvider>(
      builder: (context, homeButtonProvider, child) {
        final isEnabled = homeButtonProvider.isEnabled;
        final isLoading = homeButtonProvider.isLoading;

        return Center(
          child: GestureDetector(
            onTap: isLoading
                ? null // Disable tap if it's loading
                : () {
              homeButtonProvider.toggleGeyser(); // Toggle the geyser state
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 40,
              width: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: isEnabled
                    ? Colours.primaryOrange.withOpacity(.5)
                    : Colours.secondaryColour,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: isEnabled
                        ? Colours.primaryOrange.withOpacity(.2)
                        : Colors.grey.shade400.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: isEnabled ? 10 : 3,
                  ),
                ],
              ),
              child: isLoading
                  ? const Center(child: CircularProgressIndicator()) // Show loading spinner
                  : AnimatedAlign(
                duration: const Duration(milliseconds: 300),
                alignment: isEnabled
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}