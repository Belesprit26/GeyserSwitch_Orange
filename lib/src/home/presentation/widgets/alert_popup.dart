import 'package:flutter/material.dart';
import 'package:gs_orange/core/res/colours.dart';
import 'package:gs_orange/core/utils/core_utils.dart';
import 'package:gs_orange/src/home/presentation/widgets/temperature_radio_function.dart';

class AlertDialogPopUp extends StatelessWidget {
  const AlertDialogPopUp({
    this.text,
    this.onPressed,
    super.key,
  });

  final String? text;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: const Text('Max Temp Settings.'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Desired Temperature',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w400, fontSize: 18),
          ),
          SizedBox(
            height: 10,
          ),
          TempRadio(),
        ],
      ),
    );
  }
}
