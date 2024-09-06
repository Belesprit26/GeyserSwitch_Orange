import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:gs_orange/core/res/colours.dart';

class DisplayCard extends StatelessWidget {
  const DisplayCard({
    Key? key,
    required this.value,
    required this.unit,
  }) : super(key: key);

  final double value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 217, // 5% increase from 207
      height: 217, // 5% increase from 207
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: SweepGradient(
          colors: [
            Colours.primaryOrange.withOpacity(0.8),
            Colors.redAccent.withOpacity(0.4),
            Colors.blueAccent.withOpacity(0.4),
          ],
          stops: const [0.25, 0.75, 1.0],
        ),
      ),
      child: Center(
        child: Container(
          width: 195, // 5% increase from 186
          height: 195, // 5% increase from 186
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Temperature value
              Text(
                '${value.toInt()}°',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 48,
                  color: Colors.black,
                ),
              ),
              // Unit below the temperature
              Text(
                unit,
                style: const TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 20,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}