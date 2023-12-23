import 'package:flutter/material.dart';
import 'package:gs_orange/core/common/app/providers/user_provider.dart';
import 'package:provider/provider.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(builder: (_, provider, __) {
      final user = provider.user;
      return Column(
        children: [
          SizedBox(
            height: 10,
          ),
          Text(
            'Good Morning ${user!.fullName.split(' ').first}' ?? 'Good Morning',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 21),
          ),
          SizedBox(
            height: 10,
          ),
          Center(
            child: Image(
              image: AssetImage('assets/images/gs.png'),
              height: 180,
              width: 300,
            ),
          ),
          SizedBox(
            height: 10,
          ),
        ],
      );
    });
  }
}
