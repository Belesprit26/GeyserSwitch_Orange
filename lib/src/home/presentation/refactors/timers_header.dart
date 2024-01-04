import 'package:flutter/material.dart';
import 'package:gs_orange/core/common/app/providers/user_provider.dart';
import 'package:provider/provider.dart';

class TimersHeader extends StatelessWidget {
  const TimersHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(builder: (_, provider, __) {
      final user = provider.user;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Please note ${user!.fullName.split(' ').first}:' ??
                    'Please note',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 21),
              ),
            ],
          ),
          SizedBox(
            height: 6,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "All timers run automatically\n"
                "and are set to Eskom's Off \n"
                "-Peak hours to maximize \nsavings.",
                textAlign: TextAlign.start,
                style: TextStyle(fontWeight: FontWeight.w400, fontSize: 15.5),
              ),
            ],
          )
        ],
      );
    });
  }
}
