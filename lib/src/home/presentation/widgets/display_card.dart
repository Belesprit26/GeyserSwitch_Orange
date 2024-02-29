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
    return Container(
      height: 180,
      alignment: Alignment.center,
      child: ClipRRect(
        child: BackdropFilter(
          filter: new ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: SizedBox(
            width: 180,
            height: 180,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
              shadowColor: Colors.white,
              elevation: 3,
              color: Colors.white
                  .withOpacity(0.8), //For color change use: getColor(),
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
