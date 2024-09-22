import 'package:flutter/material.dart';
import 'package:gs_orange/src/timers/presentation/refactors/timers_header.dart';
import 'package:gs_orange/src/timers/presentation/widgets/timers_appbar.dart';
import '../refactors/custom_timer_provider/presentation/custom_timer.dart';
import '../refactors/timers_providers/presentation/timer_body.dart';

class TimersPage extends StatelessWidget {
  const TimersPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: const TimersAppBar(),
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: const [
            SizedBox(
              height: 21,
            ),
            CustomTimer(),
            SizedBox(
              height: 30,
            ),
            TimersHeader(),
            SizedBox(
              height: 21,
            ),
            TimersBody1(),
            SizedBox(
              height: 30,
            ),
          ],
        ),
      ),
    );
  }
}
