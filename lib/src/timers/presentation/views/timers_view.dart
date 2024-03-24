import 'package:flutter/material.dart';
import 'package:gs_orange/core/common/widgets/gradient_background.dart';
import 'package:gs_orange/core/res/media_res.dart';
import 'package:gs_orange/src/timers/presentation/refactors/timers_body.dart';
import 'package:gs_orange/src/timers/presentation/refactors/timers_header.dart';
import 'package:gs_orange/src/timers/presentation/widgets/timers_appbar.dart';

class TimersPage extends StatelessWidget {
  const TimersPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      appBar: const TimersAppBar(),
      body: GradientBackground(
        image: MediaRes.onBoardingBackground,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            TimersHeader(),
            SizedBox(
              height: 21,
            ),
            TimersBody(),
            SizedBox(
              height: 30,
            ),
          ],
        ),
      ),
    );
  }
}
