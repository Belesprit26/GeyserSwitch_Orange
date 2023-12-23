import 'package:flutter/material.dart';
import 'package:gs_orange/core/common/widgets/gradient_background.dart';
import 'package:gs_orange/core/res/media_res.dart';
import 'package:gs_orange/src/home/presentation/refactors/home_body.dart';
import 'package:gs_orange/src/home/presentation/refactors/home_button.dart';
import 'package:gs_orange/src/home/presentation/refactors/home_header.dart';
import 'package:gs_orange/src/home/presentation/widgets/home_app_bar.dart';

class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      appBar: const HomeAppBar(),
      body: GradientBackground(
        image: MediaRes.profileGradientBackground,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            HomeHeader(),
            SizedBox(
              height: 30,
            ),
            HomeBody(),
            SizedBox(
              height: 55,
            ),
            HomeButton(),
          ],
        ),
      ),
    );
    ;
  }
}
