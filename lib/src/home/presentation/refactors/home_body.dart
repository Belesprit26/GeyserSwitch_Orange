import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gs_orange/core/common/app/providers/user_provider.dart';
import 'package:gs_orange/core/res/colours.dart';
import 'package:gs_orange/src/home/presentation/widgets/alert_popup.dart';
import 'package:gs_orange/src/home/presentation/widgets/display_card.dart';
import 'package:provider/provider.dart';

class HomeBody extends StatelessWidget {
  const HomeBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(builder: (_, provider, __) {
      final user = provider.user;
      return Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width * .3,
            height: MediaQuery.of(context).size.height * .05,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: Colors.white70,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade400.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 3,
                ),
              ],
            ),
            child: FittedBox(
              child: FloatingActionButton.extended(
                splashColor: Colours.primaryOrange,
                label: Text(
                  "Max Temp",
                  style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 21,
                      color: Colors.black),
                ),
                onPressed: () => showDialog(
                  context: context,
                  builder: (BuildContext context) => AlertDialogPopUp(),
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
            ),
          ),
          SizedBox(
            height: 18,
          ),
          DisplayCard(
            value: user!.temperature.toDouble(),
            name: 'Temperature',
            unit: ' °C',
            assetImage: const AssetImage('assets/images/temperature_icon.png'),
          ),
        ],
      );
    });
  }
}
