import 'package:flutter/material.dart';
import 'package:gs_orange/core/utils/core_utils.dart';
import 'package:provider/provider.dart';

import '../../../widgets/timer_switch.dart';
import '../timer_provider.dart';

class TimersBody1 extends StatelessWidget {
  const TimersBody1({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Consumer<TimerProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: const Text(
                'Early Birds',
                style: TextStyle(fontWeight: FontWeight.w400, fontSize: 18),
              ),
            ),
            const SizedBox(height: 15),

            // 04:00 Timer
            buildTimerSwitch(context, "04:00", provider.is4AM, () async {
              await provider.toggleTimer("04:00", provider.is4AM);
              CoreUtils.showSnackBar(context, provider.is4AM
                  ? 'Your 4AM Timer has been turned ON Successfully.'
                  : 'Your 4AM Timer has been turned OFF Successfully.');
            }, provider.timerLoadingStates["04:00"] ?? false),

            const SizedBox(height: 15),

            // 06:00 Timer
            buildTimerSwitch(context, "06:00", provider.is6AM, () async {
              await provider.toggleTimer("06:00", provider.is6AM);
              CoreUtils.showSnackBar(context, provider.is6AM
                  ? 'Your 6AM Timer has been turned ON Successfully.'
                  : 'Your 6AM Timer has been turned OFF Successfully.');
            }, provider.timerLoadingStates["06:00"] ?? false),

            const SizedBox(height: 15),

            // 08:00 Timer
            buildTimerSwitch(context, "08:00", provider.is8AM, () async {
              await provider.toggleTimer("08:00", provider.is8AM);
              CoreUtils.showSnackBar(context, provider.is8AM
                  ? 'Your 8AM Timer has been turned ON Successfully.'
                  : 'Your 8AM Timer has been turned OFF Successfully.');
            }, provider.timerLoadingStates["08:00"] ?? false),

            const SizedBox(height: 30),

            Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: const Text(
                'Evening Owls',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w400, fontSize: 18),
              ),
            ),
            const SizedBox(height: 15),

            // 16:00 Timer
            buildTimerSwitch(context, "16:00", provider.is4PM, () async {
              await provider.toggleTimer("16:00", provider.is4PM);
              CoreUtils.showSnackBar(context, provider.is4PM
                  ? 'Your 4PM Timer has been turned ON Successfully.'
                  : 'Your 4PM Timer has been turned OFF Successfully.');
            }, provider.timerLoadingStates["16:00"] ?? false),

            const SizedBox(height: 15),

            // 18:00 Timer
            buildTimerSwitch(context, "18:00", provider.is6PM, () async {
              await provider.toggleTimer("18:00", provider.is6PM);
              CoreUtils.showSnackBar(context, provider.is6PM
                  ? 'Your 6PM Timer has been turned ON Successfully.'
                  : 'Your 6PM Timer has been turned OFF Successfully.');
            }, provider.timerLoadingStates["18:00"] ?? false),

            const SizedBox(height: 15),
          ],
        );
      },
    );
  }
}