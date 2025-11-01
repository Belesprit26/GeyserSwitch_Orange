import 'package:flutter/material.dart';
import 'package:gs_orange/src/home/domain/entities/geyser_entity.dart';
import 'package:provider/provider.dart';
import 'package:gs_orange/core/res/colours.dart';
import 'package:gs_orange/core/utils/core_utils.dart';
import 'package:gs_orange/src/home/presentation/providers/geyser_provider.dart';

class GeyserToggleButton extends StatelessWidget {
  final Geyser geyser;

  const GeyserToggleButton({Key? key, required this.geyser}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GeyserProvider>(context, listen: false);

    return Center(
      child: GestureDetector(
        onTap: () {
          provider.toggleGeyser(geyser);

          if (geyser.isOn) {
            CoreUtils.showSnackBar(context, '${geyser.name} has been turned ON successfully');
          } else {
            CoreUtils.showSnackBar(context, '${geyser.name} has been turned OFF successfully');
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 40,
          width: 70,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: geyser.isOn
                ? Colours.primaryOrange.withOpacity(.5)
                : Colours.secondaryColour,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: geyser.isOn
                    ? Colours.primaryOrange.withOpacity(.2)
                    : Colors.grey.shade400.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: geyser.isOn ? 10 : 3,
              ),
            ],
          ),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 300),
            alignment: geyser.isOn ? Alignment.centerRight : Alignment.centerLeft,
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
  }
}

