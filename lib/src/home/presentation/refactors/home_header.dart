import 'package:flutter/material.dart';
import 'package:gs_orange/core/common/app/providers/user_provider.dart';
import 'package:gs_orange/core/utils/time-helper.dart';
import 'package:provider/provider.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(builder: (_, provider, __) {
      final user = provider.user;
      return Column(
        children: [
          Text(
            'Good ${TimeHelper.getTimeOfTheDay()} ${user!.fullName.split(' ').first}' ??
                'Good Morning',
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 21),
          ),
          const SizedBox(
            height: 10,
          ),
          const Center(
            child: Image(
              image: AssetImage('assets/images/GSLogo-07.png'),
              height: 160,
              width: 300,
            ),
          ),
        ],
      );
    });
  }
}
