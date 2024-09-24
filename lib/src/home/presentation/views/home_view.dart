import 'package:flutter/material.dart';
import 'package:gs_orange/src/home/presentation/refactors/home_body.dart';
import 'package:gs_orange/src/home/presentation/widgets/home_app_bar.dart';
import '../refactors/home_providers/presentation/home_button_view.dart';
import '../refactors/home_upper_text.dart';

class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        extendBodyBehindAppBar: false,
        backgroundColor: Colors.white,
        appBar: const HomeAppBar(),
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            SizedBox(
              height: 60,
            ),
            // Display the Geyser status message
            GeyserStatus(),
            SizedBox(
              height: 45,
            ),
            HomeBody(),
            SizedBox(
              height: 55,
            ),
            //HomeButton(),
            HomeButton1(),
          ],
        ),
      ),
    );
  }
}
