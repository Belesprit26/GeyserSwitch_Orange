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
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        color: Colors.transparent,
        border: Border.all(color: Colors.transparent, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(.6),
            spreadRadius: 2,
            blurRadius: 10,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(80),
        ),
        shadowColor: Colors.white70,
        elevation: 1,
        color: Colors.white70, //For color change use: getColor(),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image(
                    width: 24,
                    image: assetImage,
                  ),
                  const SizedBox(
                    height: 3,
                  ),
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w400,
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
    );
  }
}
