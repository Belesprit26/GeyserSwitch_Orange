import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:gs_orange/core/res/colours.dart';

class DisplayCard extends StatelessWidget {
  const DisplayCard({
    Key? key,
    required this.value,
    required this.name,
    required this.assetImage,
    required this.unit,
  }) : super(key: key);

  final double value;
  final String name;
  final String unit;
  final AssetImage assetImage;

  @override
  Widget build(BuildContext context) {
    Color getColor() {
      if (value >= 60.00) {
        return Colours.primaryColour;
      } else if (value >= 50.0) {
        return Colours.primaryColour.withOpacity(0.7);
      } else if (value >= 45.0) {
        return Colors.green.shade600;
      } else if (value >= 30.0) {
        return Colors.blue.withOpacity(.8);
      } else {
        return Colours.secondaryColour;
      }
    }

    return Container(
      height: 205,
      alignment: Alignment.center,
      child: ClipRRect(
        child: BackdropFilter(
          filter: new ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: SizedBox(
            width: 200,
            height: 200,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
              shadowColor: getColor(),
              elevation: 5.5,
              color: Colors.white
                  .withOpacity(0.6), //For color change use: getColor(),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image(
                          width: 25,
                          image: assetImage,
                        ),
                        const SizedBox(
                          height: 3,
                        ),
                        Text(
                          name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(
                          height: 3,
                        ),
                        Text(
                          '$value$unit',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
