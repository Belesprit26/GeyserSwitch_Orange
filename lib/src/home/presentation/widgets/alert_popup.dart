import 'package:flutter/material.dart';
import 'package:gs_orange/src/home/presentation/widgets/temp_radio_function.dart';

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
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Desired Temperature',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 21),
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
