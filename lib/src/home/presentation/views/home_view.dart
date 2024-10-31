import 'package:flutter/material.dart';
import 'package:gs_orange/src/home/presentation/refactors/home_body.dart';
import 'package:gs_orange/src/home/presentation/widgets/glowy_ui/animated_glowing_border.dart';
import 'package:gs_orange/src/home/presentation/widgets/home_app_bar.dart';
import '../refactors/home_providers/presentation/home_button_view.dart';
import '../refactors/home_upper_text.dart';

class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isGeyserOn = false;

    return SafeArea(
      child: Scaffold(
        extendBodyBehindAppBar: false,
        backgroundColor: Colors.white,
        appBar: const HomeAppBar(),
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            SizedBox(
              height: 33,
            ),
            //Glowy Border widget
            AnimatedGlowingBorder(
              duration: const Duration(seconds: 3),
              isActive: isGeyserOn,
              glowWidth: 1.2,
              borderRadius: 21.0,
              glowColors: [Colors.black26, Colors.blueAccent, Colors.red],
              child: Column(
                children: [
                  GeyserStatus(),
                  HomeBody(),
                  SizedBox(height: 55,),
                  HomeButton1(),
                  SizedBox(height: 45,),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
