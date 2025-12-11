import 'package:flutter/material.dart';

import '../../../../core/res/colours.dart';

Widget buildTimerSwitch(BuildContext context, String time, bool isOn, Function toggle, bool isLoading) {
  return Stack(
    children: [
      Container(
        width: MediaQuery.of(context).size.width * .93,
        height: MediaQuery.of(context).size.height * .07,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: isOn
              ? LinearGradient(
            colors: [
              Colours.primaryOrange.withValues(alpha:0.99),
              Colors.blueAccent.withValues(alpha:0.6),
              Colors.redAccent.withValues(alpha:0.7),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          )
              : null, // Apply gradient when ON
          color: isOn ? null : Colors.white70, // White70 when OFF
          border: Border.all(color: Colors.white, width: 1), // Thin white border
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade400.withValues(alpha:0.7),
              spreadRadius: 2,
              blurRadius: 10,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 40.0, right: 15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                time,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 27,
                  color: isOn ? Colors.white : Colors.black87,
                ),
              ),
              GestureDetector(
                onTap: () async {
                  await toggle();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 30,
                  width: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: isOn
                        ? Colors.black.withValues(alpha:0.5)
                        : Colours.secondaryColour,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: isOn
                            ? Colours.primaryOrange.withValues(alpha:0.2)
                            : Colors.grey.shade400.withValues(alpha:0.7),
                        spreadRadius: 2,
                        blurRadius: isOn ? 10 : 2,
                      ),
                    ],
                  ),
                  child: AnimatedAlign(
                    duration: const Duration(milliseconds: 300),
                    alignment: isOn ? Alignment.centerRight : Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // Show CircularProgressIndicator when loading
      if (isLoading)
        Positioned.fill(
          child: Container(
            decoration:  BoxDecoration(
                borderRadius: BorderRadius.circular(30),
            color: Colors.black.withValues(alpha:0.5), ),
            child: const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
          ),
        ),
    ],
  );
}