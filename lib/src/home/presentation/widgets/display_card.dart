import 'package:flutter/material.dart';
import 'package:gs_orange/core/res/colours.dart';

class DisplayCard extends StatelessWidget {
  const DisplayCard({
    Key? key,
    required this.value,
    required this.unit,
    this.isLoading = false, // New parameter for loading indicator
  }) : super(key: key);

  final double value;
  final String unit;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 217,
      height: 217,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: SweepGradient(
          colors: [
            Colours.primaryOrange.withValues(alpha: 0.6),
            Colors.redAccent.withValues(alpha: .4),
            Colors.blueAccent.withValues(alpha:0.4),
          ],
          stops: const [0.25, 0.75, 1.0],
        ),
      ),
      child: Center(
        child: Container(
          width: 195,
          height: 195,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha:0.5),
                spreadRadius: 5,
                blurRadius: 7,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Display CircularProgressIndicator when loading
              if (isLoading)
                const CircularProgressIndicator()
              else
                Column(
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
            ],
          ),
        ),
      ),
    );
  }
}
