import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gs_orange/core/common/app/providers/user_provider.dart';
import 'package:gs_orange/src/home/presentation/widgets/alert_popup.dart';
import 'package:gs_orange/src/home/presentation/widgets/display_card.dart';
import 'package:provider/provider.dart';

class HomeBody extends StatelessWidget {
  const HomeBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(builder: (_, provider, __) {
      final user = provider.user;
      return InkWell(
        onTap: () => showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialogPopUp(),
        ),
        child: DisplayCard(
          value: user!.temperature.toDouble(),
          name: 'Temperature',
          unit: ' °C',
          assetImage: const AssetImage('assets/images/temperature_icon.png'),
        ),
      );
    });
  }
}
